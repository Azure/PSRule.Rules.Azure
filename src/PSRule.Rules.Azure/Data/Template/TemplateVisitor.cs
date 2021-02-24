// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management.Automation;
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
        private const string PROPERTY_TEMPLATELINK = "templateLink";
        private const string PROPERTY_LOCATION = "location";
        private const string PROPERTY_COPY = "copy";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_INPUT = "input";
        private const string PROPERTY_MODE = "mode";
        private const string PROPERTY_DEFAULTVALUE = "defaultValue";
        private const string PROPERTY_SECRETNAME = "secretName";
        private const string PROPERTY_PROVISIONINGSTATE = "provisioningState";
        private const string PROPERTY_ID = "id";
        private const string PROPERTY_URI = "uri";
        private const string PROPERTY_TEMPLATEHASH = "templateHash";

        private static string AssemblyPath = Path.GetDirectoryName(typeof(TemplateVisitor).Assembly.Location);

        public sealed class TemplateContext
        {
            private const string DATAFILE_PROVIDERS = "providers.json";
            private const string DATAFILE_ENVIRONMENTS = "environments.json";
            private const string CLOUD_PUBLIC = "AzureCloud";

            private readonly PipelineContext _Context;
            private readonly Stack<JObject> _Deployment;
            private JObject _Parameters;
            private readonly Dictionary<string, ResourceProvider> _Providers;
            private readonly Dictionary<string, CloudEnvironment> _Environments;

            internal TemplateContext()
            {
                Resources = new List<JObject>();
                Parameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = ResourceGroupOption.Default;
                Subscription = SubscriptionOption.Default;
                _Deployment = new Stack<JObject>();
                _Providers = ReadProviders();
                _Environments = ReadEnvironments();
            }

            internal TemplateContext(PipelineContext context, SubscriptionOption subscription, ResourceGroupOption resourceGroup)
                : this()
            {
                _Context = context;
                if (subscription != null)
                    Subscription = subscription;

                if (resourceGroup != null)
                    ResourceGroup = resourceGroup;
            }

            public List<JObject> Resources { get; }

            private Dictionary<string, object> Parameters { get; }

            private Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroupOption ResourceGroup { get; internal set; }

            public SubscriptionOption Subscription { get; internal set; }

            public JObject Deployment
            {
                get { return _Deployment.Peek(); }
            }

            internal void WriteDebug(string message, params object[] args)
            {
                if (_Context == null || _Context.Writer == null || string.IsNullOrEmpty(message) || !_Context.Writer.ShouldWriteDebug())
                    return;

                _Context.Writer.WriteDebug(message, args);
            }

            internal void Load(JObject parameters)
            {
                if (parameters == null || !parameters.ContainsKey(PROPERTY_PARAMETERS))
                    return;

                _Parameters = parameters[PROPERTY_PARAMETERS] as JObject;
                foreach (JProperty property in _Parameters.Properties())
                {
                    if (!(property.Value is JObject parameter && (TryParameterValue(property.Name, parameter) || TryKeyVaultReference(property.Name, parameter))))
                        throw new TemplateParameterException(parameterName: property.Name, message: string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateParameterInvalid, property.Name));
                }
            }

            private bool TryParameterValue(string parameterName, JObject parameter)
            {
                if (!parameter.ContainsKey(PROPERTY_VALUE))
                    return false;

                Parameters.Add(parameterName, parameter[PROPERTY_VALUE]);
                return true;
            }

            private bool TryKeyVaultReference(string parameterName, JObject parameter)
            {
                if (!parameter.ContainsKey(PROPERTY_REFERENCE))
                    return false;

                var valueType = parameter[PROPERTY_REFERENCE].Type;
                if (valueType == JTokenType.String)
                {
                    Parameters.Add(parameterName, SecretPlaceholder(parameter[PROPERTY_REFERENCE].Value<string>()));
                    return true;
                }
                else if (valueType == JTokenType.Object && parameter[PROPERTY_REFERENCE] is JObject refObj && refObj.ContainsKey(PROPERTY_SECRETNAME))
                {
                    Parameters.Add(parameterName, SecretPlaceholder(refObj[PROPERTY_SECRETNAME].Value<string>()));
                    return true;
                }
                return false;
            }

            private static string SecretPlaceholder(string placeholder)
            {
                return string.Concat("{{SecretReference:", placeholder, "}}");
            }

            [DebuggerDisplay("{Name}: {Index} of {Count}")]
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

                internal T CloneInput<T>() where T : JToken
                {
                    if (Input == null)
                        return null;

                    return (T)Input.CloneTemplateJToken();
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

                public void Add(CopyIndexState state)
                {
                    _Index[state.Name] = state;
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
                var templateHash = template.GetHashCode().ToString();
                var templateLink = new JObject();
                templateLink.Add(PROPERTY_ID, ResourceGroup.Id);
                templateLink.Add(PROPERTY_URI, "https://deployment-uri");

                var properties = new JObject();
                properties.Add(PROPERTY_TEMPLATE, template);
                properties.Add(PROPERTY_TEMPLATELINK, templateLink);
                properties.Add(PROPERTY_PARAMETERS, _Parameters);
                properties.Add(PROPERTY_MODE, "Incremental");
                properties.Add(PROPERTY_PROVISIONINGSTATE, "Accepted");
                properties.Add(PROPERTY_TEMPLATEHASH, templateHash);

                var deployment = new JObject();
                deployment.Add(PROPERTY_NAME, deploymentName);
                deployment.Add(PROPERTY_PROPERTIES, properties);
                deployment.Add(PROPERTY_LOCATION, ResourceGroup.Location);

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
                return ReadDataFile<ResourceProvider>(DATAFILE_PROVIDERS);
            }

            private static Dictionary<string, CloudEnvironment> ReadEnvironments()
            {
                return ReadDataFile<CloudEnvironment>(DATAFILE_ENVIRONMENTS);
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

            internal CloudEnvironment GetEnvironment()
            {
                return _Environments[CLOUD_PUBLIC];
            }

            private static Dictionary<string, T> ReadDataFile<T>(string fileName)
            {
                var sourcePath = Path.Combine(AssemblyPath, fileName);
                if (!File.Exists(sourcePath))
                    return null;

                var json = File.ReadAllText(sourcePath);
                var settings = new JsonSerializerSettings();
                settings.Converters.Add(new ResourceProviderConverter());
                var result = JsonConvert.DeserializeObject<Dictionary<string, T>>(json, settings);
                return result;
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
                context.Parameter(parameterName, new LazyParameter<long>(defaultValue));
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
            var copyIndex = GetResourceIterator(context, resource);
            while (copyIndex.Next())
            {
                var instance = copyIndex.CloneInput<JObject>();
                var condition = !resource.ContainsKey("condition") || ExpandProperty<bool>(context, resource, "condition");
                if (!condition)
                    continue;

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
                        var instance = copyIndex.CloneInput<JToken>();
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
            context.WriteDebug(s);
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
            return IsExpressionString(value) ? EvaluteExpression<T>(context, value) : value.Value<T>();
        }

        private static JToken ExpandPropertyToken(TemplateContext context, JToken value)
        {
            if (!IsExpressionString(value))
                return value;

            var result = EvaluteExpression<object>(context, value);
            return result == null ? null : JToken.FromObject(result);
        }

        private static T ExpandProperty<T>(TemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>();
            return (propertyValue.Type == JTokenType.String) ? ExpandProperty<T>(context, propertyValue) : (T)propertyValue.Value<T>();
        }

        private static int ExpandPropertyInt(TemplateContext context, JObject value, string propertyName)
        {
            var result = ExpandProperty<long>(context, value, propertyName);
            return (int)result;
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
                            var instance = copyIndex.CloneInput<JToken>();
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
                        context.CopyIndex.Push(copyIndex);
                        var jArray = new JArray();
                        while (copyIndex.Next())
                        {
                            var instance = copyIndex.CloneInput<JToken>();
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
                    state.Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT);
                    context.CopyIndex.Add(state);
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
                    state.Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT);
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
                result.Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT);
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
                        var instance = copyIndex.CloneInput<JToken>();
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
            result.CopyTemplateAnnotationFrom(array);
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

        protected static T EvaluteExpression<T>(TemplateContext context, JToken value)
        {
            if (value.Type != JTokenType.String)
                return default(T);

            var svalue = value.Value<string>();
            var lineInfo = value.TryLineInfo();
            var exp = Expression<T>(context, svalue);
            try
            {
                return exp();
            }
            catch (Exception inner)
            {
                throw new ExpressionEvaluationException(svalue, string.Format(PSRuleResources.ExpressionEvaluateError, value, lineInfo?.LineNumber, inner.Message), inner);
            }
        }

        /// <summary>
        /// Check if the script uses an expression.
        /// </summary>
        protected static bool IsExpressionString(JToken token)
        {
            if (token == null || token.Type != JTokenType.String)
                return false;

            var value = token.Value<string>();
            return value != null &&
                value.Length >= 5 && // [f()]
                value[0] == '[' &&
                value[1] != '[' &&
                value[value.Length - 1] == ']';
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
