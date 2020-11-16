// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
        private const string PROPERTY_PARAMETERS = "parameters";
        private const string PROPERTY_VARIABLES = "variables";
        private const string PROPERTY_RESOURCES = "resources";
        private const string PROPERTY_OUTPUTS = "outputs";
        private const string PROPERTY_REFERENCE = "reference";
        private const string PROPERTY_VALUE = "value";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_TEMPLATE = "template";
        private const string PROPERTY_COPY = "copy";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_INPUT = "input";
        private const string PROPERTY_MODE = "mode";
        private const string PROPERTY_DEFAULTVALUE = "defaultValue";

        public sealed class TemplateContext
        {
            private readonly Stack<JObject> _Deployment;
            private JObject _Parameters;
            private readonly Dictionary<string, ResourceProvider> _Providers;

            internal TemplateContext()
            {
                Resources = new List<JObject>();
                Parameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = new ResourceGroup();
                Subscription = new Subscription();
                _Deployment = new Stack<JObject>();
                _Providers = ReadProviders();
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

            private Dictionary<string, object> Parameters { get; }

            private Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroup ResourceGroup { get; internal set; }

            public Subscription Subscription { get; internal set; }

            public JObject Deployment
            {
                get { return _Deployment.Peek(); }
            }

            internal void Load(JObject parameters)
            {
                if (parameters == null || !parameters.ContainsKey(PROPERTY_PARAMETERS))
                    return;

                _Parameters = parameters[PROPERTY_PARAMETERS] as JObject;
                foreach (JProperty property in _Parameters.Properties())
                {
                    if (!(property.Value is JObject parameter))
                        throw new TemplateParameterException(parameterName: property.Name, message: string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateParameterInvalid, property.Name));

                    if (parameter.ContainsKey(PROPERTY_VALUE))
                        Parameters.Add(property.Name, parameter[PROPERTY_VALUE]);
                    else if (parameter.ContainsKey(PROPERTY_REFERENCE))
                        Parameters.Add(property.Name, SecretPlaceholder(parameter[PROPERTY_REFERENCE]["secretName"].Value<string>()));
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
                properties.Add(PROPERTY_TEMPLATE, template);
                properties.Add(PROPERTY_PARAMETERS, _Parameters);
                properties.Add(PROPERTY_MODE, "Incremental");
                properties.Add("provisioningState", "Accepted");

                var deployment = new JObject();
                deployment.Add(PROPERTY_NAME, deploymentName);
                deployment.Add(PROPERTY_PROPERTIES, properties);

                _Deployment.Push(deployment);
            }

            internal void ExitDeployment()
            {
                _Deployment.Pop();
            }

            internal void Parameter(string parameterName, object value)
            {
                Parameters.Add(parameterName, value);
            }

            internal bool TryParameter(string parameterName, out object value)
            {
                if (!Parameters.TryGetValue(parameterName, out value))
                    return false;

                if (value is LazyValue weakValue)
                {
                    value = weakValue.GetValue(this);
                    Parameters[parameterName] = value;
                }
                return true;
            }

            internal bool TryParameter(string parameterName)
            {
                return Parameters.ContainsKey(parameterName);
            }

            internal void Variable(string variableName, object value)
            {
                Variables.Add(variableName, value);
            }

            internal bool TryVariable(string variableName, out object value)
            {
                if (!Variables.TryGetValue(variableName, out value))
                    return false;

                if (value is LazyValue weakValue)
                {
                    value = weakValue.GetValue(this);
                    Variables[variableName] = value;
                }
                return true;
            }

            private static Dictionary<string, ResourceProvider> ReadProviders()
            {
                var providersFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "providers.json");
                if (!File.Exists(providersFile))
                    return null;

                var json = File.ReadAllText(providersFile);
                var settings = new JsonSerializerSettings();
                settings.Converters.Add(new ResourceProviderConverter());
                var result = JsonConvert.DeserializeObject<Dictionary<string, ResourceProvider>>(json, settings);
                return result;
            }

            internal ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
            {
                if (_Providers == null || _Providers.Count == 0 || !_Providers.TryGetValue(providerNamespace, out ResourceProvider provider))
                    return Array.Empty<ResourceProviderType>();

                if (resourceType == null)
                    return provider.Types.Values.ToArray();

                if (!provider.Types.ContainsKey(resourceType))
                    return Array.Empty<ResourceProviderType>();

                return new ResourceProviderType[] { provider.Types[resourceType] };
            }
        }

        private abstract class LazyValue
        {
            public abstract object GetValue(TemplateContext context);
        }

        private sealed class LazyParameter<T> : LazyValue
        {
            internal readonly JToken _Value;

            public LazyParameter(JToken defaultValue)
            {
                _Value = defaultValue;
            }

            public override object GetValue(TemplateContext context)
            {
                return TemplateVisitor.ExpandProperty<T>(context, _Value);
            }
        }

        private sealed class LazyVariable : LazyValue
        {
            internal readonly JToken _Value;

            public LazyVariable(JToken value)
            {
                _Value = value;
            }

            public override object GetValue(TemplateContext context)
            {
                return TemplateVisitor.ResolveVariable(context, _Value);
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

                if (TryObjectProperty(template, PROPERTY_PARAMETERS, out JObject parameters))
                    Parameters(context, parameters);

                if (TryObjectProperty(template, PROPERTY_VARIABLES, out JObject variables))
                    Variables(context, variables);

                if (TryArrayProperty(template, PROPERTY_RESOURCES, out JArray resources))
                    Resources(context, resources.Values<JObject>());

                if (TryObjectProperty(template, PROPERTY_OUTPUTS, out JObject outputs))
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
            if (context.TryParameter(parameterName) || parameter == null || !parameter.ContainsKey(PROPERTY_DEFAULTVALUE))
                return;

            var type = parameter[PROPERTY_TYPE].ToObject<ParameterType>();
            var defaultValue = parameter[PROPERTY_DEFAULTVALUE];
            if (type == ParameterType.Bool)
                context.Parameter(parameterName, new LazyParameter<bool>(defaultValue));
            else if (type == ParameterType.Int)
                context.Parameter(parameterName, new LazyParameter<int>(defaultValue));
            else if (type == ParameterType.String)
                context.Parameter(parameterName, new LazyParameter<string>(defaultValue));
            else if (type == ParameterType.Array)
                context.Parameter(parameterName, new LazyParameter<JArray>(defaultValue));
            else if (type == ParameterType.Object)
                context.Parameter(parameterName, new LazyParameter<JObject>(defaultValue));
            else
                context.Parameter(parameterName, ExpandPropertyToken(context, defaultValue));
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
                ResourceOuter(context, resource);
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
                if (!string.Equals(variable.Key, PROPERTY_COPY, StringComparison.OrdinalIgnoreCase))
                    Variable(context, variable.Key, variable.Value);
            }

            foreach (var copyIndex in GetVariableIterator(context, variables))
            {
                if (copyIndex.IsCopy())
                {
                    context.CopyIndex.Push(copyIndex);
                    var jArray = new JArray();
                    while (copyIndex.Next())
                    {
                        var instance = copyIndex.Input.DeepClone();
                        jArray.Add(ResolveToken(context, instance));
                    }
                    Variable(context, copyIndex.Name, ResolveVariable(context, jArray));
                    context.CopyIndex.Pop();
                }
            }
        }

        protected virtual void Variable(TemplateContext context, string variableName, JToken value)
        {
            context.Variable(variableName, new LazyVariable(value));
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

        protected static StringExpression<T> Expression<T>(TemplateContext context, string s)
        {
            var builder = new ExpressionBuilder();
            return () => EvaluateExpression<T>(context, builder.Build(s));
        }

        private static T EvaluateExpression<T>(TemplateContext context, ExpressionFnOuter fn)
        {
            var result = fn(context);
            return result is JToken token && !typeof(JToken).IsAssignableFrom(typeof(T)) ? token.Value<T>() : (T)result;
        }

        private static T ExpandProperty<T>(TemplateContext context, JToken value)
        {
            if (value.Type != JTokenType.String)
                return value.Value<T>();

            var svalue = value.Value<string>();
            return IsExpressionString(svalue) ? EvaluteExpression<T>(context, svalue) : value.Value<T>();
        }

        private static JToken ExpandPropertyToken(TemplateContext context, JToken value)
        {
            if (!TryExpressionString(value, out string svalue))
                return value;

            var result = EvaluteExpression<object>(context, svalue);
            return result == null ? null : JToken.FromObject(result);
        }

        private static T ExpandProperty<T>(TemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>();
            return (propertyValue.Type == JTokenType.String) ? ExpandProperty<T>(context, propertyValue) : (T)propertyValue.Value<T>();
        }

        private static JToken ResolveVariable(TemplateContext context, JToken value)
        {
            if (value is JObject jObject)
            {
                foreach (var copyIndex in GetVariableIterator(context, jObject))
                {
                    if (copyIndex.IsCopy())
                    {
                        context.CopyIndex.Push(copyIndex);
                        var jArray = new JArray();
                        while (copyIndex.Next())
                        {
                            var instance = copyIndex.Input.DeepClone();
                            jArray.Add(ResolveToken(context, instance));
                        }
                        jObject[copyIndex.Name] = jArray;
                        context.CopyIndex.Pop();
                    }
                }
                return ResolveToken(context, jObject);
            }
            else if (value is JArray jArray)
            {
                return ExpandArray(context, jArray);
            }
            else if (value is JToken jToken && jToken.Type == JTokenType.String)
            {
                return ExpandPropertyToken(context, jToken);
            }
            return value;
        }

        private static void ResolveProperty(TemplateContext context, JObject obj, string propertyName)
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
                        var jArray = new JArray();
                        while (copyIndex.Next())
                        {
                            var instance = copyIndex.Input.DeepClone();
                            jArray.Add(ResolveToken(context, instance));
                        }
                        jObject[copyIndex.Name] = jArray;
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

        private static JToken ResolveToken(TemplateContext context, JToken token)
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
        private static TemplateContext.CopyIndexState[] GetPropertyIterator(TemplateContext context, JObject value)
        {
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var copyObjectArray = value[PROPERTY_COPY].Value<JArray>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState();
                    state.Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME);
                    state.Input = copyObject[PROPERTY_INPUT];
                    state.Count = ExpandProperty<int>(context, copyObject, PROPERTY_COUNT);
                    context.CopyIndex.Push(state);
                    value.Remove(PROPERTY_COPY);
                    result.Add(state);
                }
                return result.ToArray();
            }
            else
                return new TemplateContext.CopyIndexState[] { new TemplateContext.CopyIndexState { Input = value } };
        }

        private static TemplateContext.CopyIndexState[] GetVariableIterator(TemplateContext context, JObject value)
        {
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var copyObjectArray = value[PROPERTY_COPY].Value<JArray>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState();
                    state.Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME);
                    state.Input = copyObject[PROPERTY_INPUT];
                    state.Count = ExpandProperty<int>(context, copyObject, PROPERTY_COUNT);
                    context.CopyIndex.Push(state);
                    value.Remove(PROPERTY_COPY);
                    result.Add(state);
                }
                return result.ToArray();
            }
            else
                return new TemplateContext.CopyIndexState[] { new TemplateContext.CopyIndexState { Input = value } };
        }

        /// <summary>
        /// Get a resource based iterator copy.
        /// </summary>
        private static TemplateContext.CopyIndexState GetResourceIterator(TemplateContext context, JObject value)
        {
            var result = new TemplateContext.CopyIndexState();
            result.Input = value;
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var copyObject = value[PROPERTY_COPY].Value<JObject>();
                result.Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME);
                result.Count = ExpandProperty<int>(context, copyObject, PROPERTY_COUNT);
                context.CopyIndex.Push(result);
                value.Remove(PROPERTY_COPY);
            }
            return result;
        }

        private static JToken ExpandObject(TemplateContext context, JObject obj)
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

        private static JToken ExpandArray(TemplateContext context, JArray array)
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

        protected static T EvaluteExpression<T>(TemplateContext context, string value)
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
