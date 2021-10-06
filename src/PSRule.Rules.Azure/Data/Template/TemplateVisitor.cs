// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;

namespace PSRule.Rules.Azure.Data.Template
{
    public delegate T StringExpression<T>();

    internal interface ITemplateContext
    {
        TemplateVisitor.TemplateContext.CopyIndexStore CopyIndex { get; }

        JObject Deployment { get; }

        string TemplateFile { get; }

        string ParameterFile { get; }

        ResourceGroupOption ResourceGroup { get; }

        SubscriptionOption Subscription { get; }

        ExpressionFnOuter BuildExpression(string s);

        CloudEnvironment GetEnvironment();

        bool TryParameter(string parameterName, out object value);

        ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType);

        bool TryVariable(string variableName, out object value);

        void WriteDebug(string message, params object[] args);
    }

    /// <summary>
    /// The base class for a template visitor.
    /// </summary>
    internal abstract class TemplateVisitor
    {
        private const string RESOURCETYPE_DEPLOYMENT = "Microsoft.Resources/deployments";
        private const string DEPLOYMENTSCOPE_INNER = "inner";
        private const string PROPERTY_PARAMETERS = "parameters";
        private const string PROPERTY_FUNCTIONS = "functions";
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
        private const string PROPERTY_EXPRESSIONEVALUATIONOPTIONS = "expressionEvaluationOptions";
        private const string PROPERTY_SCOPE = "scope";
        private const string PROPERTY_RESOURCEGROUP = "resourceGroup";
        private const string PROPERTY_SUBSCRIPTIONID = "subscriptionId";
        private const string PROPERTY_NAMESPACE = "namespace";
        private const string PROPERTY_MEMBERS = "members";
        private const string PROPERTY_OUTPUT = "output";

        internal sealed class TemplateContext : ITemplateContext
        {
            private const string DATAFILE_ENVIRONMENTS = "environments.json";
            private const string CLOUD_PUBLIC = "AzureCloud";

            internal readonly PipelineContext Pipeline;

            private readonly Stack<JObject> _Deployment;
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly List<ResourceValue> _Resources;
            private readonly Dictionary<string, ResourceValue> _ResourceIds;

            private JObject _Parameters;
            private ResourceProviderHelper _ResourceProviderHelper;
            private Dictionary<string, CloudEnvironment> _Environments;

            internal TemplateContext()
            {
                _Resources = new List<ResourceValue>();
                _ResourceIds = new Dictionary<string, ResourceValue>(StringComparer.OrdinalIgnoreCase);
                Parameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = ResourceGroupOption.Default;
                Subscription = SubscriptionOption.Default;
                _Deployment = new Stack<JObject>();
                _ExpressionFactory = new ExpressionFactory();
                _ExpressionBuilder = new ExpressionBuilder(_ExpressionFactory);
                _ResourceProviderHelper = new ResourceProviderHelper();
            }

            internal TemplateContext(PipelineContext context, SubscriptionOption subscription, ResourceGroupOption resourceGroup)
                : this()
            {
                Pipeline = context;
                if (subscription != null)
                    Subscription = subscription;

                if (resourceGroup != null)
                    ResourceGroup = resourceGroup;
            }

            private Dictionary<string, object> Parameters { get; }

            private Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroupOption ResourceGroup { get; internal set; }

            public SubscriptionOption Subscription { get; internal set; }

            public JObject Deployment => _Deployment.Peek();

            public string TemplateFile { get; private set; }

            public string ParameterFile { get; private set; }

            public ExpressionFnOuter BuildExpression(string s)
            {
                return _ExpressionBuilder.Build(s);
            }

            public void AddResource(JObject resource)
            {
                if (resource == null)
                    return;

                GetResourceNameType(resource, out string[] nameParts, out string[] typeParts);
                var resourceId = GetResourceId(nameParts, typeParts);
                AddResource(new ResourceValue(resourceId, resource));
            }

            private void AddResource(ResourceValue resource)
            {
                _Resources.Add(resource);
                _ResourceIds[resource.ResourceId] = resource;
            }

            public void AddResource(ResourceValue[] resource)
            {
                for (var i = 0; resource != null && i < resource.Length; i++)
                    AddResource(resource[i]);
            }

            public ResourceValue[] GetResources()
            {
                return _Resources.ToArray();
            }

            public void RemoveResource(ResourceValue resource)
            {
                _Resources.Remove(resource);
                _ResourceIds.Remove(resource.ResourceId);
            }

            public bool TryGetResource(string resourceId, out ResourceValue resource)
            {
                if (_ResourceIds.TryGetValue(resourceId, out resource))
                    return true;

                resource = null;
                return false;
            }

            public void WriteDebug(string message, params object[] args)
            {
                if (Pipeline == null || Pipeline.Writer == null || string.IsNullOrEmpty(message) || !Pipeline.Writer.ShouldWriteDebug())
                    return;

                Pipeline.Writer.WriteDebug(message, args);
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

            private static string GetResourceId(string[] nameParts, string[] typeParts, int depth = -1)
            {
                if (depth == -1)
                    depth = nameParts.Length;

                var name = new string[2 * depth + 1];
                var nameIndex = 0;
                var typeIndex = 0;
                name[0] = typeParts[typeIndex++];
                name[1] = typeParts[typeIndex++];
                name[2] = nameParts[nameIndex++];
                for (var i = 3; i < 2 * depth + 1; i = i + 2)
                {
                    name[i] = typeParts[typeIndex++];
                    name[i + 1] = nameParts[nameIndex++];
                }
                return string.Join("/", name);
            }

            internal static bool TryParentResourceId(JObject resource, out string[] resourceId)
            {
                resourceId = null;
                if (GetResourceScope(resource, out resourceId))
                    return true;

                if (!GetResourceNameType(resource, out string[] nameParts, out string[] typeParts))
                    return false;

                resourceId = new string[nameParts.Length - 1];
                for (var i = 0; i < nameParts.Length - 1; i++)
                    resourceId[i] = GetResourceId(nameParts, typeParts, i + 1);

                return true;
            }

            private static bool GetResourceNameType(JObject resource, out string[] nameParts, out string[] typeParts)
            {
                var name = resource[PROPERTY_NAME].Value<string>();
                nameParts = name.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
                typeParts = null;
                if (nameParts == null || nameParts.Length == 0)
                    return false;

                var type = resource[PROPERTY_TYPE].Value<string>();
                typeParts = type.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
                if (typeParts == null || typeParts.Length != nameParts.Length + 1)
                    return false;

                return true;
            }

            private static bool GetResourceScope(JObject resource, out string[] resourceId)
            {
                resourceId = null;
                if (!resource.ContainsKey(PROPERTY_SCOPE))
                    return false;

                resourceId = new string[] { resource[PROPERTY_SCOPE].Value<string>() };
                return true;
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

                public CopyIndexState Current => _Current.Count > 0 ? _Current.Peek() : null;

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
                var templateLink = new JObject
                {
                    { PROPERTY_ID, ResourceGroup.Id },
                    { PROPERTY_URI, "https://deployment-uri" }
                };

                var properties = new JObject
                {
                    { PROPERTY_TEMPLATE, template },
                    { PROPERTY_TEMPLATELINK, templateLink },
                    { PROPERTY_PARAMETERS, _Parameters },
                    { PROPERTY_MODE, "Incremental" },
                    { PROPERTY_PROVISIONINGSTATE, "Accepted" },
                    { PROPERTY_TEMPLATEHASH, templateHash }
                };

                var deployment = new JObject
                {
                    { PROPERTY_NAME, deploymentName },
                    { PROPERTY_PROPERTIES, properties },
                    { PROPERTY_LOCATION, ResourceGroup.Location }
                };

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

            public bool TryParameter(string parameterName, out object value)
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

            public bool TryVariable(string variableName, out object value)
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

            internal void Function(string ns, string name, ExpressionFn fn)
            {
                var descriptor = new FunctionDescriptor(string.Concat(ns, ".", name), fn);
                _ExpressionFactory.With(descriptor);
            }

            private Dictionary<string, CloudEnvironment> ReadEnvironments()
            {
                return _ResourceProviderHelper.ReadDataFile<CloudEnvironment>(DATAFILE_ENVIRONMENTS);
            }

            public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
            {
                return _ResourceProviderHelper.GetResourceType(providerNamespace, resourceType);
            }

            public CloudEnvironment GetEnvironment()
            {
                if (_Environments == null)
                    _Environments = ReadEnvironments();

                return _Environments[CLOUD_PUBLIC];
            }

            internal void SetSource(string templateFile, string parameterFile)
            {
                TemplateFile = templateFile;
                ParameterFile = parameterFile;
            }
        }

        internal sealed class UserDefinedFunctionContext : ITemplateContext
        {
            private readonly ITemplateContext _Inner;
            private readonly Dictionary<string, object> _Parameters;

            public UserDefinedFunctionContext(ITemplateContext context)
            {
                _Inner = context;
                _Parameters = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
            }

            public TemplateContext.CopyIndexStore CopyIndex => _Inner.CopyIndex;

            public JObject Deployment => throw new NotImplementedException();

            public string TemplateFile => _Inner.TemplateFile;

            public string ParameterFile => _Inner.ParameterFile;

            public ResourceGroupOption ResourceGroup => _Inner.ResourceGroup;

            public SubscriptionOption Subscription => _Inner.Subscription;

            public ExpressionFnOuter BuildExpression(string s)
            {
                return _Inner.BuildExpression(s);
            }

            public CloudEnvironment GetEnvironment()
            {
                return _Inner.GetEnvironment();
            }

            public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
            {
                return _Inner.GetResourceType(providerNamespace, resourceType);
            }

            public bool TryParameter(string parameterName, out object value)
            {
                return _Parameters.TryGetValue(parameterName, out value);
            }

            public bool TryVariable(string variableName, out object value)
            {
                value = null;
                return false;
            }

            public void WriteDebug(string message, params object[] args)
            {
                _Inner.WriteDebug(message, args);
            }

            internal void SetParameters(JArray parameters, object[] args)
            {
                if (parameters == null || parameters.Count == 0 || args == null || args.Length == 0)
                    return;

                for (var i = 0; i < parameters.Count; i++)
                {
                    _Parameters.Add(parameters[i]["name"].Value<string>(), args[i]);
                }
            }
        }

        [DebuggerDisplay("{ResourceId}")]
        internal sealed class ResourceValue
        {
            internal readonly string ResourceId;
            internal readonly JObject Value;

            internal ResourceValue(string resourceId, JObject value)
            {
                ResourceId = resourceId;
                Value = value;
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
                return ExpandProperty<T>(context, _Value);
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
                return ResolveVariable(context, _Value);
            }
        }

        private sealed class LazyOutput : LazyValue
        {
            internal readonly JToken _Value;

            public LazyOutput(JToken value)
            {
                _Value = value;
            }

            public override object GetValue(TemplateContext context)
            {
                return ResolveVariable(context, _Value);
            }
        }

        public void Visit(TemplateContext context, string deploymentName, JObject template)
        {
            BeginTemplate(context, deploymentName, template);
            Template(context, deploymentName, template);
            EndTemplate(context, deploymentName, template);
        }

        protected virtual void BeginTemplate(TemplateContext context, string deploymentName, JObject template)
        {

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

                if (TryArrayProperty(template, PROPERTY_FUNCTIONS, out JArray functions))
                    Functions(context, functions);

                if (TryObjectProperty(template, PROPERTY_VARIABLES, out JObject variables))
                    Variables(context, variables);

                if (TryArrayProperty(template, PROPERTY_RESOURCES, out JArray resources))
                    Resources(context, resources.Values<JObject>().ToArray());

                if (TryObjectProperty(template, PROPERTY_OUTPUTS, out JObject outputs))
                    Outputs(context, outputs);
            }
            finally
            {
                context.ExitDeployment();
            }
        }

        protected virtual void EndTemplate(TemplateContext context, string deploymentName, JObject template)
        {

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

        protected virtual void Functions(TemplateContext context, JArray functions)
        {
            if (functions == null || functions.Count == 0)
                return;

            for (var i = 0; i < functions.Count; i++)
                FunctionNamespace(context, functions[i].Value<JObject>());
        }

        private void FunctionNamespace(TemplateContext context, JObject functionNamespace)
        {
            if (functionNamespace == null ||
                !TryStringProperty(functionNamespace, PROPERTY_NAMESPACE, out string ns) ||
                !TryObjectProperty(functionNamespace, PROPERTY_MEMBERS, out JObject members))
                return;

            foreach (var property in members.Properties())
                Function(context, ns, property.Name, property.Value.Value<JObject>());
        }

        protected virtual void Function(TemplateContext context, string ns, string name, JObject function)
        {
            if (!TryObjectProperty(function, PROPERTY_OUTPUT, out JObject output))
                return;

            TryArrayProperty(function, PROPERTY_PARAMETERS, out JArray parameters);
            //var outputFn = context.Expression.Build(outputValue);
            ExpressionFn fn = (ctx, args) =>
            {
                var fnContext = new UserDefinedFunctionContext(ctx);
                fnContext.SetParameters(parameters, args);
                return UserDefinedFunction(fnContext, output[PROPERTY_VALUE]);
            };
            context.Function(ns, name, fn);
        }

        private static object UserDefinedFunction(ITemplateContext context, JToken token)
        {
            return ResolveVariable(context, token);
        }

        #endregion Functions

        #region Resources

        protected virtual void Resources(TemplateContext context, JObject[] resources)
        {
            if (resources == null || resources.Length == 0)
                return;

            resources = SortResources(context, resources);
            for (var i = 0; i < resources.Length; i++)
                ResourceOuter(context, resources[i]);
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

            var deploymentContext = context;
            if (TryObjectProperty(properties, PROPERTY_EXPRESSIONEVALUATIONOPTIONS, out JObject options) &&
                TryStringProperty(options, PROPERTY_SCOPE, out string scope) &&
                StringComparer.OrdinalIgnoreCase.Equals(DEPLOYMENTSCOPE_INNER, scope))
            {
                var subscription = new SubscriptionOption(context.Subscription);
                var resourceGroup = new ResourceGroupOption(context.ResourceGroup);
                if (TryStringProperty(resource, PROPERTY_SUBSCRIPTIONID, out string subscriptionId))
                    subscription.SubscriptionId = subscriptionId;

                if (TryStringProperty(resource, PROPERTY_RESOURCEGROUP, out string resourceGroupName))
                    resourceGroup.Name = resourceGroupName;

                resourceGroup.SubscriptionId = subscription.SubscriptionId;
                deploymentContext = new TemplateContext(context.Pipeline, subscription, resourceGroup);
                if (TryObjectProperty(properties, PROPERTY_PARAMETERS, out JObject innerParameters))
                {
                    foreach (var parameter in innerParameters.Properties())
                        deploymentContext.Parameter(parameter.Name, ResolveVariable(context, parameter.Value[PROPERTY_VALUE]));
                }
            }

            if (!TryObjectProperty(properties, PROPERTY_TEMPLATE, out JObject template))
                return false;

            Template(deploymentContext, deploymentName, template);
            if (deploymentContext != context)
                context.AddResource(deploymentContext.GetResources());

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

        protected static StringExpression<T> Expression<T>(ITemplateContext context, string s)
        {
            context.WriteDebug(s);
            return () => EvaluateExpression<T>(context, context.BuildExpression(s));
        }

        private static T EvaluateExpression<T>(ITemplateContext context, ExpressionFnOuter fn)
        {
            var result = fn(context);
            return result is JToken token && !typeof(JToken).IsAssignableFrom(typeof(T)) ? token.Value<T>() : (T)result;
        }

        private static T ExpandProperty<T>(ITemplateContext context, JToken value)
        {
            return IsExpressionString(value) ? EvaluteExpression<T>(context, value) : value.Value<T>();
        }

        private static JToken ExpandPropertyToken(ITemplateContext context, JToken value)
        {
            if (!IsExpressionString(value))
                return value;

            var result = EvaluteExpression<object>(context, value);
            if (result is MockMember mock)
                result = mock.BuildString();

            return result == null ? null : JToken.FromObject(result);
        }

        private static T ExpandProperty<T>(ITemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>();
            return (propertyValue.Type == JTokenType.String) ? ExpandProperty<T>(context, propertyValue) : (T)propertyValue.Value<T>();
        }

        private static int ExpandPropertyInt(ITemplateContext context, JObject value, string propertyName)
        {
            var result = ExpandProperty<long>(context, value, propertyName);
            return (int)result;
        }

        private static JToken ResolveVariable(ITemplateContext context, JToken value)
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

        private static void ResolveProperty(ITemplateContext context, JObject obj, string propertyName)
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

        private static JToken ResolveToken(ITemplateContext context, JToken token)
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
        private static TemplateContext.CopyIndexState[] GetPropertyIterator(ITemplateContext context, JObject value)
        {
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var copyObjectArray = value[PROPERTY_COPY].Value<JArray>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState
                    {
                        Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME),
                        Input = copyObject[PROPERTY_INPUT],
                        Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
                    };
                    context.CopyIndex.Add(state);
                    value.Remove(PROPERTY_COPY);
                    result.Add(state);
                }
                return result.ToArray();
            }
            else
                return new TemplateContext.CopyIndexState[] { new TemplateContext.CopyIndexState { Input = value } };
        }

        private static TemplateContext.CopyIndexState[] GetVariableIterator(ITemplateContext context, JObject value)
        {
            if (value.ContainsKey(PROPERTY_COPY))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var copyObjectArray = value[PROPERTY_COPY].Value<JArray>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState
                    {
                        Name = ExpandProperty<string>(context, copyObject, PROPERTY_NAME),
                        Input = copyObject[PROPERTY_INPUT],
                        Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
                    };
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
            var result = new TemplateContext.CopyIndexState
            {
                Input = value
            };
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

        private static JToken ExpandObject(ITemplateContext context, JObject obj)
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

        private static void ExpandObjectInstance2(TemplateContext context, JObject obj)
        {
            foreach (var property in obj.Properties())
            {
                ResolveProperty(context, obj, property.Name);
            }
        }

        private static JToken ExpandArray(ITemplateContext context, JArray array)
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

        protected static T EvaluteExpression<T>(ITemplateContext context, JToken value)
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
                throw new ExpressionEvaluationException(svalue, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionEvaluateError, value, lineInfo?.LineNumber, inner.Message), inner);
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

        private static bool TryStringProperty(JObject obj, string propertyName, out string propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out JToken value) || value.Type != JTokenType.String)
                return false;

            propertyValue = value.Value<string>();
            return true;
        }

        /// <summary>
        /// Emit a resource object.
        /// </summary>
        protected virtual void Emit(TemplateContext context, JObject resource)
        {
            resource.SetTargetInfo(context.TemplateFile, context.ParameterFile);
            context.AddResource(resource);
        }

        protected virtual JObject[] SortResources(TemplateContext context, JObject[] resources)
        {
            return resources;
        }
    }

    /// <summary>
    /// A template visitor for generating rule data.
    /// </summary>
    internal sealed class RuleDataExportVisitor : TemplateVisitor
    {
        private const string FIELD_DEPENDSON = "dependsOn";
        private const string FIELD_COMMENTS = "comments";
        private const string FIELD_APIVERSION = "apiVersion";
        private const string FIELD_CONDITION = "condition";
        private const string FIELD_RESOURCES = "resources";

        protected override void Resource(TemplateContext context, JObject resource)
        {
            // Remove resource properties that not required in rule data
            if (resource.ContainsKey(FIELD_APIVERSION))
                resource.Remove(FIELD_APIVERSION);

            if (resource.ContainsKey(FIELD_CONDITION))
                resource.Remove(FIELD_CONDITION);

            if (resource.ContainsKey(FIELD_COMMENTS))
                resource.Remove(FIELD_COMMENTS);

            if (!resource.TryGetDependencies(out _))
                resource.Remove(FIELD_DEPENDSON);

            base.Resource(context, resource);
        }

        protected override void EndTemplate(TemplateContext context, string deploymentName, JObject template)
        {
            var resources = context.GetResources();
            for (var i = 0; i < resources.Length; i++)
            {
                if (resources[i].Value.TryGetDependencies(out string[] dependencies))
                {
                    resources[i].Value.Remove(FIELD_DEPENDSON);
                    if (TemplateContext.TryParentResourceId(resources[i].Value, out string[] parentResourceId))
                    {
                        for (var j = 0; j < parentResourceId.Length; j++)
                        {
                            if (context.TryGetResource(parentResourceId[j], out ResourceValue resource))
                            {
                                resource.Value.UseProperty(FIELD_RESOURCES, out JArray innerResources);
                                innerResources.Add(resources[i].Value);
                                context.RemoveResource(resources[i]);
                            }
                        }
                    }
                }
            }
            base.EndTemplate(context, deploymentName, template);
        }
    }
}
