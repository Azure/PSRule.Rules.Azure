using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.Threading;

namespace PSRule.Rules.Azure.Data.Template
{
    public delegate T StringExpression<T>();

    /// <summary>
    /// The base class for a template visitor.
    /// </summary>
    internal abstract class TemplateVisitor
    {
        private const string RESOURCETYPE_DEPLOYMENT = "Microsoft.Resources/deployments";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_TEMPLATE = "template";
        private const string PROPERTY_COPY = "copy";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_INPUT = "input";

        public sealed class TemplateContext
        {
            private readonly Stack<JObject> _Deployment;
            private JObject _Parameters;

            internal TemplateContext()
            {
                Resources = new List<JObject>();
                Parameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = new ResourceGroup();
                Subscription = new Subscription();
                _Deployment = new Stack<JObject>();
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

            public JObject Deployment
            {
                get { return _Deployment.Peek(); }
            }

            internal void Load(JObject parameters)
            {
                if (!parameters.ContainsKey("parameters"))
                    return;

                _Parameters = parameters["parameters"] as JObject;
                foreach (JProperty property in _Parameters.Properties())
                {
                    if (!(property.Value is JObject parameter))
                        throw new TemplateParameterException(parameterName: property.Name, message: string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateParameterInvalid, property.Name));

                    if (parameter.ContainsKey("value"))
                        Parameters.Add(property.Name, parameter["value"]);
                    else if (parameter.ContainsKey("reference"))
                        Parameters.Add(property.Name, SecretPlaceholder(parameter["reference"]["secretName"].Value<string>()));
                    else
                        throw new TemplateParameterException(parameterName: property.Name, message: string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateParameterInvalid, property.Name));
                }
            }

            private static string SecretPlaceholder(string secretName)
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

            internal void EnterDeployment(string deploymentName, JObject template)
            {
                var properties = new JObject();
                properties.Add("template", template);
                properties.Add("parameters", _Parameters);
                properties.Add("mode", "Incremental");
                properties.Add("provisioningState", "Accepted");

                var deployment = new JObject();
                deployment.Add("name", deploymentName);
                deployment.Add("properties", properties);

                _Deployment.Push(deployment);
            }

            internal void ExitDeployment()
            {
                _Deployment.Pop();
            }
        }

        public void Visit(TemplateContext context, string deploymentName, JObject template)
        {
            Template(context, deploymentName, template);
        }

        protected virtual void Template(TemplateContext context, string deploymentName, JObject template)
        {
            try
            {
                context.EnterDeployment(deploymentName, template);

                // Process template sections
                // Schema(_Context, template.Schema);
                // ContentVersion(_Context, template.ContentVersion);

                if (TryObjectProperty(template, "parameters", out JObject parameters))
                    Parameters(context, parameters);

                if (TryObjectProperty(template, "variables", out JObject variables))
                    Variables(context, variables);

                if (TryArrayProperty(template, "resources", out JArray resources))
                    Resources(context, resources.Values<JObject>());

                if (TryObjectProperty(template, "outputs", out JObject outputs))
                    Outputs(context, outputs);
            }
            finally
            {
                context.ExitDeployment();
            }
        }

        protected virtual void Schema(TemplateContext context, string schema)
        {

        }

        protected virtual void ContentVersion(TemplateContext context, string contentVersion)
        {

        }

        #region Parameters

        protected virtual void Parameters(TemplateContext context, JObject parameters)
        {
            if (parameters == null || parameters.Count == 0)
                return;

            foreach (var parameter in parameters)
                Parameter(context, parameter.Key, parameter.Value as JObject);
        }

        protected virtual void Parameter(TemplateContext context, string parameterName, JObject parameter)
        {
            if (context.Parameters.ContainsKey(parameterName) || parameter == null || !parameter.ContainsKey("defaultValue"))
                return;

            var type = parameter["type"].ToObject<ParameterType>();
            var defaultValue = parameter["defaultValue"];
            if (type == ParameterType.Bool)
                context.Parameters.Add(parameterName, ExpandProperty<bool>(context, defaultValue));
            else if (type == ParameterType.Int)
                context.Parameters.Add(parameterName, ExpandProperty<int>(context, defaultValue));
            else if (type == ParameterType.String)
                context.Parameters.Add(parameterName, ExpandProperty<string>(context, defaultValue));
            else if (type == ParameterType.Array)
                context.Parameters.Add(parameterName, ExpandProperty<JArray>(context, defaultValue));
            else if (type == ParameterType.Object)
                context.Parameters.Add(parameterName, ExpandProperty<JObject>(context, defaultValue));
            else
                context.Parameters.Add(parameterName, ExpandPropertyToken(context, defaultValue));
        }

        #endregion Parameters

        #region Functions

        protected virtual void Functions(TemplateContext context)
        {

        }

        protected virtual void Function(TemplateContext context)
        {

        }

        #endregion Functions

        #region Resources

        protected virtual void Resources(TemplateContext context, IEnumerable<JObject> resources)
        {
            if (resources == null)
                return;

            foreach (var resource in resources)
            {
                ResourceOuter(context, resource);
            }
        }

        private void ResourceOuter(TemplateContext context, JObject resource)
        {
            var condition = !resource.ContainsKey("condition") || ExpandProperty<bool>(context, resource, "condition");
            if (!condition)
                return;

            var copyIndex = GetResourceIterator(context, resource);
            while (copyIndex.Next())
            {
                var instance = copyIndex.Input.DeepClone() as JObject;
                Resource(context, instance);
            }
            if (copyIndex.IsCopy())
                context.CopyIndex.Pop();
        }

        protected virtual void Resource(TemplateContext context, JObject resource)
        {
            // Get resource type
            if (TryDeploymentResource(context, resource))
                return;

            // Expand resource properties
            foreach (var property in resource.Properties())
                ResolveProperty(context, resource, property.Name);

            Emit(context, resource);
        }

        /// <summary>
        /// Handle a nested deployment resource.
        /// </summary>
        private bool TryDeploymentResource(TemplateContext context, JObject resource)
        {
            var resourceType = ExpandProperty<string>(context, resource, PROPERTY_TYPE);
            if (!string.Equals(resourceType, RESOURCETYPE_DEPLOYMENT, StringComparison.OrdinalIgnoreCase))
                return false;

            var deploymentName = ExpandProperty<string>(context, resource, PROPERTY_NAME);
            if (string.IsNullOrEmpty(deploymentName))
                return false;

            if (!TryObjectProperty(resource, PROPERTY_PROPERTIES, out JObject properties))
                return false;

            if (!TryObjectProperty(properties, PROPERTY_TEMPLATE, out JObject template))
                return false;

            Template(context, deploymentName, template);
            return true;
        }

        #endregion Resources

        #region Variables

        protected virtual void Variables(TemplateContext context, JObject variables)
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
                if (TryArrayProperty(jobj, PROPERTY_COPY, out JArray copyArray))
                {
                    var arrayValue = new List<JToken>();
                    foreach (var copy in copyArray)
                    {
                        var copyObject = copy.Value<JObject>();
                        var copyIndex = new TemplateContext.CopyIndexState();
                        copyIndex.Count = ExpandProperty<int>(context, copyObject, PROPERTY_COUNT);
                        copyIndex.Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME);
                        copyIndex.Input = copyObject[PROPERTY_INPUT];
                        context.CopyIndex.Push(copyIndex);
                        for (var i = 0; i < copyIndex.Count; i++)
                        {
                            copyIndex.Index = i;
                            var instance = copyIndex.Input.DeepClone();
                            arrayValue.Add(VariableInstance(context, instance));
                        }
                        context.CopyIndex.Pop();
                        jobj.Remove(PROPERTY_COPY);
                        jobj.Add(copyIndex.Name, new JArray(arrayValue.ToArray()));
                    }
                }
                context.Variables.Add(variableName, jobj);
                return;
            }
            context.Variables.Add(variableName, VariableInstance(context, value));
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

        #region Outputs

        protected virtual void Outputs(TemplateContext context, JObject outputs)
        {

        }

        #endregion Outputs

        protected StringExpression<T> Expression<T>(TemplateContext context, string s)
        {
            var builder = new ExpressionBuilder();
            return () => EvaluateExpression<T>(context, builder.Build(s));
        }

        private T EvaluateExpression<T>(TemplateContext context, ExpressionFnOuter fn)
        {
            var result = fn(context);
            return result is JToken token && !typeof(JToken).IsAssignableFrom(typeof(T)) ? token.Value<T>() : (T)result;
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

            var result = EvaluteExpression<object>(context, svalue);
            return result == null ? null : JToken.FromObject(result);
        }

        private T ExpandProperty<T>(TemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>();
            return (propertyValue.Type == JTokenType.String) ? ExpandProperty<T>(context, propertyValue) : (T)propertyValue.Value<T>();
        }

        private void ResolveProperty(TemplateContext context, JObject obj, string propertyName)
        {
            if (!obj.ContainsKey(propertyName))
                return;

            var value = obj[propertyName];
            if (value is JObject jObject)
            {
                foreach (var copyIndex in GetPropertyIterator(context, jObject))
                {
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
                return ExpandObject(context, jObject);
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
        private TemplateContext.CopyIndexState[] GetPropertyIterator(TemplateContext context, JObject value)
        {
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var copyObjectArray = value[PROPERTY_COPY].Value<JArray>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState();
                    state.Name = ExpandProperty<string>(context, copyObject, "name");
                    state.Input = copyObject["input"];
                    state.Count = ExpandProperty<int>(context, copyObject, "count");
                    context.CopyIndex.Push(state);
                    value.Remove(PROPERTY_COPY);
                }
                return result.ToArray();
            }
            else
                return new TemplateContext.CopyIndexState[] { new TemplateContext.CopyIndexState { Input = value } };
        }

        /// <summary>
        /// Get a resource based iterator copy.
        /// </summary>
        private TemplateContext.CopyIndexState GetResourceIterator(TemplateContext context, JObject value)
        {
            var result = new TemplateContext.CopyIndexState();
            result.Input = value;
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var copyObject = value[PROPERTY_COPY].Value<JObject>();
                result.Name = ExpandProperty<string>(context, copyObject, "name");
                result.Count = ExpandProperty<int>(context, copyObject, "count");
                context.CopyIndex.Push(result);
                value.Remove(PROPERTY_COPY);
            }
            return result;
        }

        private JToken ExpandObject(TemplateContext context, JObject obj)
        {
            foreach (var copyIndex in GetPropertyIterator(context, obj))
            {
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
                    result.Add(ExpandObject(context, jObject));
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

        /// <summary>
        /// Check if the script uses an expression.
        /// </summary>
        protected static bool IsExpressionString(string value)
        {
            return value != null &&
                value.Length >= 5 && // [f()]
                value[0] == '[' &&
                value[value.Length - 1] == ']';
        }

        protected static bool TryExpressionString(JToken token, out string value)
        {
            value = null;
            if (token.Type != JTokenType.String)
                return false;

            value = token.Value<string>();
            return IsExpressionString(value);
        }

        private static bool TryArrayProperty(JObject obj, string propertyName, out JArray propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out JToken value) || value.Type != JTokenType.Array)
                return false;

            propertyValue = value.Value<JArray>();
            return true;
        }

        private static bool TryObjectProperty(JObject obj, string propertyName, out JObject propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out JToken value) || value.Type != JTokenType.Object)
                return false;

            propertyValue = value as JObject;
            return true;
        }

        /// <summary>
        /// Emit a resource object.
        /// </summary>
        protected virtual void Emit(TemplateContext context, JObject resource)
        {
            context.Resources.Add(resource);
        }
    }

    /// <summary>
    /// A template visitor for generating rule data.
    /// </summary>
    internal sealed class RuleDataExportVisitor : TemplateVisitor
    {
        protected override void Resource(TemplateContext context, JObject resource)
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

            base.Resource(context, resource);
        }
    }
}
