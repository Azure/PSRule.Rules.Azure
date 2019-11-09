using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Management.Automation;
using static PSRule.Rules.Azure.Data.Template.DeploymentTemplate;

namespace PSRule.Rules.Azure.Data.Template
{
    public delegate T StringExpression<T>();

    /// <summary>
    /// The base class for a template visitor.
    /// </summary>
    internal abstract class TemplateVisitor
    {
        private readonly Subscription _Subscription;
        private readonly ResourceGroup _ResourceGroup;

        private TemplateContext _Context;

        internal TemplateVisitor(Subscription subscription, ResourceGroup resourceGroup)
        {
            _Subscription = subscription;
            _ResourceGroup = resourceGroup;
        }

        public sealed class TemplateContext
        {
            internal TemplateContext()
            {
                Resources = new List<JObject>();
                Parameters = new Dictionary<string, object>();
                Variables = new Dictionary<string, object>();
                CopyIndex = new CopyIndexStore();
                ResourceGroup = new ResourceGroup();
                Subscription = new Subscription();
            }

            internal TemplateContext(Subscription subscription, ResourceGroup resourceGroup)
                : this()
            {
                if (subscription != null)
                    Subscription = subscription;

                if (resourceGroup != null)
                    ResourceGroup = resourceGroup;
            }

            public List<JObject> Resources { get; }

            public Dictionary<string, object> Parameters { get; }

            public Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroup ResourceGroup { get; internal set; }

            public Subscription Subscription { get; internal set; }

            internal void Load(DeploymentParameters parameters)
            {
                foreach (var parameter in parameters.Parameters)
                {
                    if (parameter.Value.Reference != null)
                    {
                        Parameters.Add(parameter.Key, SecretPlaceholder(parameter.Value.Reference.SecretName));
                    }
                    else if (parameter.Value.Value != null)
                    {
                        Parameters.Add(parameter.Key, parameter.Value.Value);
                    }
                }
            }

            private string SecretPlaceholder(string secretName)
            {
                return string.Concat("{{SecretReference:", secretName, "}}");
            }

            public sealed class CopyIndexState
            {
                internal CopyIndexState()
                {
                    Index = -1;
                    Count = 1;
                    Input = null;
                    Name = null;
                }

                internal int Index { get; set; }

                internal int Count { get; set; }

                internal string Name { get; set; }

                internal JToken Input { get; set; }

                internal bool IsCopy()
                {
                    return Name != null;
                }

                internal bool Next()
                {
                    Index++;
                    return Index < Count;
                }
            }

            public sealed class CopyIndexStore
            {
                private readonly Dictionary<string, CopyIndexState> _Index;
                private readonly Stack<CopyIndexState> _Current;

                public CopyIndexStore()
                {
                    _Index = new Dictionary<string, CopyIndexState>();
                    _Current = new Stack<CopyIndexState>();
                }

                public CopyIndexState Current
                {
                    get { return _Current.Count > 0 ? _Current.Peek() : null; }
                }

                public void Push(CopyIndexState state)
                {
                    _Current.Push(state);
                    _Index[state.Name] = state;
                }

                public void Pop()
                {
                    var state = _Current.Pop();
                    _Index.Remove(state.Name);
                }

                public bool TryGetValue(string name, out CopyIndexState state)
                {
                    if (name == null)
                    {
                        state = Current;
                        return state != null;
                    }
                    return _Index.TryGetValue(name, out state);
                }
            }
        }

        public PSObject[] Visit(DeploymentTemplate template, DeploymentParameters parameters)
        {
            // Load context
            _Context = new TemplateContext(_Subscription, _ResourceGroup);
            _Context.Load(parameters);

            // Process template sections
            Schema(_Context, template.Schema);
            ContentVersion(_Context, template.ContentVersion);
            Parameters(_Context, template.Parameters);
            Variables(_Context, template.Variables);
            Resources(_Context, template.Resources);

            // Return results
            var results = new List<PSObject>();
            var serializer = new JsonSerializer();
            serializer.Converters.Add(new PSObjectJsonConverter());
            foreach (var resource in _Context.Resources)
            {
                results.Add(resource.ToObject<PSObject>(serializer));
            }
            return results.ToArray();
        }

        protected virtual void Schema(TemplateContext context, string schema)
        {

        }

        protected virtual void ContentVersion(TemplateContext context, string contentVersion)
        {

        }

        protected virtual void Parameters(TemplateContext context, Dictionary<string, TemplateParameter> parameters)
        {
            if (parameters == null || parameters.Count == 0)
                return;

            foreach (var parameter in parameters)
            {
                Parameter(context, parameter.Key, parameter.Value);
            }
        }

        protected virtual void Parameter(TemplateContext context, string parameterName, TemplateParameter parameter)
        {
            if (parameter.DefaultValue == null)
                return;

            if (!context.Parameters.ContainsKey(parameterName))
                context.Parameters.Add(parameterName, ExpandProperty<object>(context, parameter.DefaultValue));
        }

        protected virtual void Functions(TemplateContext context)
        {

        }

        protected virtual void Function(TemplateContext context)
        {

        }

        protected virtual void Resources(TemplateContext context, IEnumerable<JObject> resources)
        {
            foreach (var resource in resources)
            {
                Resource(context, resource);
            }
        }

        protected virtual void Resource(TemplateContext context, JObject resource)
        {
            var condition = !resource.ContainsKey("condition") || ExpandProperty<bool>(context, resource, "condition");
            if (!condition)
                return;

            var copyIndex = GetResourceIterator(context, resource);
            while (copyIndex.Next())
            {
                var instance = copyIndex.Input.DeepClone() as JObject;
                ResourceInstance(context, instance);
            }
            if (copyIndex.IsCopy())
                context.CopyIndex.Pop();
        }

        protected virtual void ResourceInstance(TemplateContext context, JObject resource)
        {
            // Expand resource properties
            foreach (var property in resource.Properties())
                ResolveProperty(context, resource, property.Name);

            Emit(context, resource);
        }

        #region Variables

        protected virtual void Variables(TemplateContext context, Dictionary<string, JToken> variables)
        {
            if (variables == null || variables.Count == 0)
                return;

            foreach (var variable in variables)
            {
                Variable(context, variable.Key, variable.Value);
            }
        }

        protected virtual void Variable(TemplateContext context, string variableName, JToken value)
        {
            if (value.Type == JTokenType.Object)
            {
                var jobj = value.Value<JObject>();
                if (TryArrayProperty(jobj, "copy", out JArray copyArray))
                {
                    var arrayValue = new List<JToken>();
                    foreach (var copy in copyArray)
                    {
                        var copyObject = copy.Value<JObject>();
                        var copyIndex = new TemplateContext.CopyIndexState();
                        copyIndex.Count = ExpandProperty<int>(context, copyObject, "count");
                        copyIndex.Name = ExpandProperty<string>(context, copyObject, "name");
                        copyIndex.Input = copyObject["input"];
                        context.CopyIndex.Push(copyIndex);
                        for (var i = 0; i < copyIndex.Count; i++)
                        {
                            copyIndex.Index = i;
                            var instance = copyIndex.Input.DeepClone();
                            arrayValue.Add(VariableInstance(context, instance));
                        }
                        context.CopyIndex.Pop();
                        jobj.Remove("copy");
                        jobj.Add(copyIndex.Name, new JArray(arrayValue.ToArray()));
                    }
                }
                context.Variables.Add(variableName, jobj);
                return;
            }
            context.Variables.Add(variableName, VariableInstance(context, value));
        }

        private bool TryArrayProperty(JObject obj, string propertyName, out JArray propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out JToken value) || value.Type != JTokenType.Array)
                return false;

            propertyValue = value.Value<JArray>();
            return true;
        }

        protected virtual JToken VariableInstance(TemplateContext context, JToken value)
        {
            if (value.Type == JTokenType.Object)
                return VariableObject(context, value.Value<JObject>());
            else if (value.Type == JTokenType.Array)
            {
                return VariableArray(context, value.Value<JArray>());
            }
            else
                return VariableSimple(context, value.Value<JValue>());
        }

        protected virtual JToken VariableObject(TemplateContext context, JObject value)
        {
            ExpandObjectInstance2(context, value);
            return value;
        }

        protected virtual JToken VariableArray(TemplateContext context, JArray value)
        {
            return ExpandArray(context, value);
        }

        protected virtual JToken VariableSimple(TemplateContext context, JValue value)
        {
            var result = ExpandProperty<object>(context, value.Value<string>());
            return result == null ? JValue.CreateNull() : JToken.FromObject(result);
        }

        #endregion Variables

        protected virtual void Outputs()
        {

        }

        protected StringExpression<T> Expression<T>(TemplateContext context, string s)
        {
            var builder = new ExpressionBuilder();
            return () => EvaluateExpression<T>(builder.Build(s));
        }

        private T EvaluateExpression<T>(ExpressionFnOuter fn)
        {
            return (T)fn(_Context);
        }

        private T ExpandProperty<T>(TemplateContext context, object value)
        {
            return value is string s && IsExpressionString(s) ? EvaluteExpression<T>(context, s) : (T)value;
        }

        private T ExpandProperty<T>(TemplateContext context, JToken value)
        {
            if (value.Type != JTokenType.String)
                return value.Value<T>();

            var svalue = value.Value<string>();
            return IsExpressionString(svalue) ? EvaluteExpression<T>(context, svalue) : value.Value<T>();
        }

        private JToken ExpandPropertyToken(TemplateContext context, JToken value)
        {
            if (!TryExpressionString(value, out string svalue))
                return value;

            return JToken.FromObject(EvaluteExpression<object>(context, svalue));
        }

        private T ExpandProperty<T>(TemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>().Value;
            return (propertyValue is string svalue) ? ExpandProperty<T>(context, propertyValue) : (T)propertyValue;
        }

        private void ResolvePropertyExpression(TemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return;
            
            value[propertyName] = ExpandProperty<string>(context, value, propertyName);
        }

        private void ResolveProperty(TemplateContext context, JObject obj, string propertyName)
        {
            if (!obj.ContainsKey(propertyName))
                return;

            var value = obj[propertyName];
            if (value is JObject jObject)
            {
                var copyIndex = GetPropertyIterator(context, jObject);
                if (copyIndex.IsCopy())
                {
                    while (copyIndex.Next())
                    {
                        var instance = copyIndex.Input.DeepClone();
                        jObject[copyIndex.Name] = ResolveToken(context, instance);
                    }
                    context.CopyIndex.Pop();
                }
                else
                {
                    obj[propertyName] = ResolveToken(context, jObject);
                }
            }
            else if (value is JArray jArray)
            {
                obj[propertyName] = ExpandArray(context, jArray);
            }
            else if (value is JToken jToken && jToken.Type == JTokenType.String)
            {
                obj[propertyName] = ExpandPropertyToken(context, jToken);
            }
        }

        private JToken ResolveToken(TemplateContext context, JToken token)
        {
            if (token is JObject jObject)
            {
                return ExpandObject2(context, jObject);
            }
            else if (token is JArray jArray)
            {
                return ExpandArray(context, jArray);
            }
            else
            {
                return ExpandPropertyToken(context, token);
            }
        }

        /// <summary>
        /// Get a property based iterator copy.
        /// </summary>
        private TemplateContext.CopyIndexState GetPropertyIterator(TemplateContext context, JObject value)
        {
            var result = new TemplateContext.CopyIndexState();
            result.Input = value;
            if (value.ContainsKey("copy"))
            {
                var copyObject = value["copy"].Value<JObject>();
                result.Name = ExpandProperty<string>(context, copyObject, "name");
                result.Input = copyObject["input"];
                result.Count = ExpandProperty<int>(context, copyObject, "count");
                context.CopyIndex.Push(result);
                value.Remove("copy");
            }
            return result;
        }

        /// <summary>
        /// Get a resource based iterator copy.
        /// </summary>
        private TemplateContext.CopyIndexState GetResourceIterator(TemplateContext context, JObject value)
        {
            var result = new TemplateContext.CopyIndexState();
            result.Input = value;
            if (value.ContainsKey("copy"))
            {
                var copyObject = value["copy"].Value<JObject>();
                result.Name = ExpandProperty<string>(context, copyObject, "name");
                result.Count = ExpandProperty<int>(context, copyObject, "count");
                context.CopyIndex.Push(result);
                value.Remove("copy");
            }
            return result;
        }

        private JToken ExpandObject2(TemplateContext context, JObject obj)
        {
            var copyIndex = GetPropertyIterator(context, obj);
            if (copyIndex.IsCopy())
            {
                var array = new JArray();
                while (copyIndex.Next())
                {
                    var instance = copyIndex.Input.DeepClone();
                    array.Add(ResolveToken(context, instance));
                }
                obj[copyIndex.Name] = array;
                context.CopyIndex.Pop();
            }
            else
            {
                foreach (var property in obj.Properties())
                {
                    ResolveProperty(context, obj, property.Name);
                }
            }
            return obj;
        }

        private void ExpandObjectInstance2(TemplateContext context, JObject obj)
        {
            foreach (var property in obj.Properties())
            {
                ResolveProperty(context, obj, property.Name);
            }
        }

        private JToken ExpandArray(TemplateContext context, JArray array)
        {
            var result = new JArray();
            
            for (var i = 0; i < array.Count; i++)
            {
                if (array[i] is JObject jObject)
                {
                    result.Add(ExpandObject2(context, jObject));
                }
                else if (array[i] is JArray jArray)
                {
                    result.Add(ExpandArray(context, jArray));
                }
                else if (array[i] is JToken jToken && jToken.Type == JTokenType.String)
                {
                    result.Add(ExpandPropertyToken(context, jToken));
                }
                else
                {
                    result.Add(array[i]);
                }
            }
            return result;
        }

        protected T EvaluteExpression<T>(TemplateContext context, string value)
        {
            var exp = Expression<T>(context, value);
            return exp();
        }

        protected bool IsExpressionString(string value)
        {
            return value != null &&
                value.Length >= 5 && // [f()]
                value[0] == '[' &&
                value[value.Length - 1] == ']';
        }

        protected bool TryExpressionString(JToken token, out string value)
        {
            value = null;
            if (token.Type != JTokenType.String)
                return false;

            value = token.Value<string>();
            return IsExpressionString(value);
        }

        /// <summary>
        /// Emit a resource object.
        /// </summary>
        protected void Emit(TemplateContext context, JObject resource)
        {
            context.Resources.Add(resource);
        }
    }

    /// <summary>
    /// A template visitor for generating rule data.
    /// </summary>
    internal sealed class RuleDataExportVisitor : TemplateVisitor
    {
        internal RuleDataExportVisitor(Subscription subscription, ResourceGroup resourceGroup)
            : base (subscription, resourceGroup) { }

        protected override void ResourceInstance(TemplateContext context, JObject resource)
        {
            // Remove resource properties that not required in rule data
            if (resource.ContainsKey("apiVersion"))
                resource.Remove("apiVersion");

            if (resource.ContainsKey("condition"))
                resource.Remove("condition");

            if (resource.ContainsKey("comments"))
                resource.Remove("comments");

            if (resource.ContainsKey("dependsOn"))
                resource.Remove("dependsOn");

            base.ResourceInstance(context, resource);
        }
    }
}
