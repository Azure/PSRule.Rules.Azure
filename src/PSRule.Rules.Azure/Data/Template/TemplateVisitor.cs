// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

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

        TenantOption Tenant { get; }

        ManagementGroupOption ManagementGroup { get; }

        ExpressionFnOuter BuildExpression(string s);

        CloudEnvironment GetEnvironment();

        bool TryParameter(string parameterName, out object value);

        ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType);

        bool TryVariable(string variableName, out object value);

        void WriteDebug(string message, params object[] args);

        void AddValidationIssue(string issueId, string name, string message, params object[] args);
    }

    /// <summary>
    /// The base class for a template visitor.
    /// </summary>
    internal abstract class TemplateVisitor
    {
        private const string RESOURCETYPE_DEPLOYMENT = "Microsoft.Resources/deployments";
        private const string DEPLOYMENTSCOPE_INNER = "inner";
        private const string PROPERTY_SCHEMA = "$schema";
        private const string PROPERTY_CONTENTVERSION = "contentVersion";
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
        private const string PROPERTY_RESOURCENAME = "ResourceName";
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
        private const string PROPERTY_METADATA = "metadata";
        private const string PROPERTY_GENERATOR = "_generator";

        internal sealed class TemplateContext : ITemplateContext
        {
            private const string DATAFILE_ENVIRONMENTS = "environments.json";
            private const string CLOUD_PUBLIC = "AzureCloud";
            private const string ISSUE_PARAMETER_EXPRESSIONLENGTH = "PSRule.Rules.Azure.Template.ExpressionLength";
            private const int EXPRESSION_MAXLENGTH = 24576;

            internal readonly PipelineContext Pipeline;

            private readonly Stack<JObject> _Deployment;
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly List<ResourceValue> _Resources;
            private readonly Dictionary<string, ResourceValue> _ResourceIds;
            private readonly ResourceProviderHelper _ResourceProviderHelper;
            private readonly Dictionary<string, JToken> _ParameterAssignments;
            private readonly TemplateValidator _Validator;

            private JObject _CurrentDeployment;
            private bool? _IsGenerated;
            private JObject _Parameters;
            private Dictionary<string, CloudEnvironment> _Environments;

            internal TemplateContext()
            {
                _Resources = new List<ResourceValue>();
                _ResourceIds = new Dictionary<string, ResourceValue>(StringComparer.OrdinalIgnoreCase);
                Parameters = new Dictionary<string, IParameterValue>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = ResourceGroupOption.Default;
                Subscription = SubscriptionOption.Default;
                Tenant = TenantOption.Default;
                ManagementGroup = ManagementGroupOption.Default;
                _Deployment = new Stack<JObject>();
                _ExpressionFactory = new ExpressionFactory();
                _ExpressionBuilder = new ExpressionBuilder(_ExpressionFactory);
                _ResourceProviderHelper = new ResourceProviderHelper();
                _ParameterAssignments = new Dictionary<string, JToken>();
                _Validator = new TemplateValidator();
                _IsGenerated = null;
            }

            internal TemplateContext(PipelineContext context, SubscriptionOption subscription, ResourceGroupOption resourceGroup, TenantOption tenant, ManagementGroupOption managementGroup, ParameterDefaultsOption parameterDefaults)
                : this()
            {
                Pipeline = context;
                if (subscription != null)
                    Subscription = subscription;

                if (resourceGroup != null)
                    ResourceGroup = resourceGroup;

                if (tenant != null)
                    Tenant = tenant;

                if (managementGroup != null)
                    ManagementGroup = managementGroup;

                if (parameterDefaults != null)
                    ParameterDefaults = parameterDefaults;
            }

            internal TemplateContext(PipelineContext context)
                : this()
            {
                Pipeline = context;
                if (context?.Option?.Configuration?.Subscription != null)
                    Subscription = context?.Option?.Configuration?.Subscription;

                if (context?.Option?.Configuration?.ResourceGroup != null)
                    ResourceGroup = context?.Option?.Configuration?.ResourceGroup;

                if (context?.Option?.Configuration?.Tenant != null)
                    Tenant = context?.Option?.Configuration?.Tenant;

                if (context?.Option?.Configuration?.ManagementGroup != null)
                    ManagementGroup = context?.Option?.Configuration?.ManagementGroup;

                if (context?.Option?.Configuration?.ParameterDefaults != null)
                    ParameterDefaults = context?.Option?.Configuration?.ParameterDefaults;
            }

            private Dictionary<string, IParameterValue> Parameters { get; }

            private Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroupOption ResourceGroup { get; internal set; }

            public SubscriptionOption Subscription { get; internal set; }

            public TenantOption Tenant { get; internal set; }

            public ManagementGroupOption ManagementGroup { get; internal set; }

            public ParameterDefaultsOption ParameterDefaults { get; private set; }

            public JObject Deployment => _Deployment.Peek();

            public string TemplateFile { get; private set; }

            public string ParameterFile { get; private set; }

            public ExpressionFnOuter BuildExpression(string s)
            {
                if (s != null && s.Length > EXPRESSION_MAXLENGTH && !IsGenerated())
                    AddValidationIssue(ISSUE_PARAMETER_EXPRESSIONLENGTH, s, ReasonStrings.ExpressionLength, s, EXPRESSION_MAXLENGTH);

                return _ExpressionBuilder.Build(s);
            }

            public void AddResource(JObject resource)
            {
                if (resource == null)
                    return;

                GetResourceNameType(resource, out var nameParts, out var typeParts);
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
                foreach (var property in _Parameters.Properties())
                {
                    if (!(property.Value is JObject parameter && AssignParameterValue(property.Name, parameter)))
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
                for (var i = 3; i < 2 * depth + 1; i += 2)
                {
                    name[i] = typeParts[typeIndex++];
                    name[i + 1] = nameParts[nameIndex++];
                }
                return string.Join("/", name);
            }

            internal static bool TryParentResourceId(JObject resource, out string[] resourceId)
            {
                if (GetResourceScope(resource, out resourceId))
                    return true;

                if (!GetResourceNameType(resource, out var nameParts, out var typeParts))
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
                return typeParts != null && typeParts.Length == nameParts.Length + 1;
            }

            private static bool GetResourceScope(JObject resource, out string[] resourceId)
            {
                resourceId = null;
                if (!resource.ContainsKey(PROPERTY_SCOPE))
                    return false;

                resourceId = new string[] { resource[PROPERTY_SCOPE].Value<string>() };
                return true;
            }

            private bool AssignParameterValue(string name, JObject parameter)
            {
                return AssignParameterLiteral(name, parameter) || AssignKeyVaultReference(name, parameter);
            }

            private bool AssignParameterLiteral(string name, JObject parameter)
            {
                if (!parameter.ContainsKey(PROPERTY_VALUE))
                    return false;

                AddParameterAssignment(name, parameter[PROPERTY_VALUE]);
                return true;
            }

            private void AddParameterAssignment(string name, JToken value)
            {
                _ParameterAssignments.Add(name, value);
            }

            private bool AssignKeyVaultReference(string name, JObject parameter)
            {
                if (!parameter.ContainsKey(PROPERTY_REFERENCE))
                    return false;

                var valueType = parameter[PROPERTY_REFERENCE].Type;
                if (valueType == JTokenType.String)
                {
                    AddParameterAssignment(name, SecretPlaceholder(parameter[PROPERTY_REFERENCE].Value<string>()));
                    return true;
                }
                else if (valueType == JTokenType.Object && parameter[PROPERTY_REFERENCE] is JObject refObj && refObj.ContainsKey(PROPERTY_SECRETNAME))
                {
                    AddParameterAssignment(name, SecretPlaceholder(refObj[PROPERTY_SECRETNAME].Value<string>()));
                    return true;
                }
                return false;
            }

            private static JToken SecretPlaceholder(string placeholder)
            {
                return new JValue(string.Concat("{{SecretReference:", placeholder, "}}"));
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
                    return Input == null ? null : (T)Input.CloneTemplateJToken();
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

                public void Remove(CopyIndexState state)
                {
                    if (_Current.Contains(state))
                        return;

                    if (_Index.ContainsValue(state))
                        _Index.Remove(state.Name);
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

            internal void EnterDeployment(string deploymentName, JObject template, bool isNested)
            {
                var templateHash = template.GetHashCode().ToString(Thread.CurrentThread.CurrentCulture);
                TryObjectProperty(template, PROPERTY_METADATA, out var metadata);
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
                    { PROPERTY_RESOURCENAME, ParameterFile ?? TemplateFile },
                    { PROPERTY_NAME, deploymentName },
                    { PROPERTY_PROPERTIES, properties },
                    { PROPERTY_LOCATION, ResourceGroup.Location },
                    { PROPERTY_TYPE, RESOURCETYPE_DEPLOYMENT },
                    { PROPERTY_METADATA, metadata },
                };

                deployment.SetTargetInfo(TemplateFile, ParameterFile);
                AddResource(new ResourceValue(string.Concat(RESOURCETYPE_DEPLOYMENT, "/", deploymentName), deployment));
                _CurrentDeployment = deployment;
                _Deployment.Push(deployment);
            }

            internal void ExitDeployment()
            {
                _Deployment.Pop();
                if (_Deployment.Count > 0)
                    _CurrentDeployment = _Deployment.Peek();
            }

            private bool IsGenerated()
            {
                if (!_IsGenerated.HasValue)
                {
                    _IsGenerated = TryObjectProperty(_CurrentDeployment, PROPERTY_METADATA, out var metadata) &&
                        TryObjectProperty(metadata, PROPERTY_GENERATOR, out var generator) &&
                        TryStringProperty(generator, PROPERTY_NAME, out _);
                }
                return _IsGenerated.Value;
            }

            internal void Parameter(string name, ParameterType type, object value)
            {
                Parameters.Add(name, new SimpleParameterValue(name, type, value));
            }

            internal void Parameter(IParameterValue value)
            {
                Parameters.Add(value.Name, value);
            }

            public bool TryParameter(string parameterName, out object value)
            {
                value = null;
                if (!Parameters.TryGetValue(parameterName, out var pv))
                    return false;

                value = pv.GetValue(this);
                return true;
            }

            internal bool TryParameterAssignment(string parameterName, out JToken value)
            {
                return _ParameterAssignments.TryGetValue(parameterName, out value);
            }

            internal bool TryParameterDefault(string parameterName, ParameterType type, out JToken value)
            {
                value = default;
                switch (type)
                {
                    case ParameterType.String:
                    case ParameterType.SecureString:
                        return ParameterDefaults.TryGetString(parameterName, out value);

                    case ParameterType.Bool:
                        return ParameterDefaults.TryGetBool(parameterName, out value);

                    case ParameterType.Int:
                        return ParameterDefaults.TryGetLong(parameterName, out value);

                    case ParameterType.Array:
                        return ParameterDefaults.TryGetString(parameterName, out value);

                    case ParameterType.Object:
                    case ParameterType.SecureObject:
                    default:
                        return false;
                }
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

                if (value is ILazyValue weakValue)
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

            public void AddValidationIssue(string issueId, string name, string message, params object[] args)
            {
                _CurrentDeployment.SetValidationIssue(issueId, name, message, args);
            }

            internal void CheckParameter(string parameterName, JObject parameter, ParameterType type, JToken value)
            {
                _Validator.ValidateParameter(this, parameterName, parameter, value);
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

            public TenantOption Tenant => _Inner.Tenant;

            public ManagementGroupOption ManagementGroup => _Inner.ManagementGroup;

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

            public void AddValidationIssue(string issueId, string name, string message, params object[] args)
            {
                _Inner.AddValidationIssue(issueId, name, message, args);
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

        internal interface IParameterValue
        {
            string Name { get; }

            ParameterType Type { get; }

            object GetValue(TemplateContext context);
        }

        internal sealed class SimpleParameterValue : IParameterValue
        {
            private readonly object _Value;

            public SimpleParameterValue(string name, ParameterType type, object value)
            {
                Name = name;
                Type = type;
                _Value = value;
            }

            public string Name { get; }

            public ParameterType Type { get; }

            public object GetValue(TemplateContext context)
            {
                return _Value;
            }
        }

        internal interface ILazyValue
        {
            object GetValue(TemplateContext context);
        }

        private sealed class LazyParameter<T> : ILazyValue, IParameterValue
        {
            private readonly JToken _LazyValue;
            private T _Value;
            private bool _Resolved;

            public LazyParameter(string name, ParameterType type, JToken defaultValue)
            {
                Name = name;
                Type = type;
                _LazyValue = defaultValue;
            }

            public string Name { get; }

            public ParameterType Type { get; }

            public object GetValue(TemplateContext context)
            {
                if (!_Resolved)
                {
                    _Value = ExpandProperty<T>(context, _LazyValue);
                    _Resolved = true;
                }
                return _Value;
            }
        }

        private sealed class LazyVariable : ILazyValue
        {
            internal readonly JToken _Value;

            public LazyVariable(JToken value)
            {
                _Value = value;
            }

            public object GetValue(TemplateContext context)
            {
                return ResolveVariable(context, _Value);
            }
        }

        private sealed class LazyOutput : ILazyValue
        {
            internal readonly JToken _Value;

            public LazyOutput(JToken value)
            {
                _Value = value;
            }

            public object GetValue(TemplateContext context)
            {
                return ResolveVariable(context, _Value);
            }
        }

        public void Visit(TemplateContext context, string deploymentName, JObject template)
        {
            BeginTemplate(context, deploymentName, template);
            Template(context, deploymentName, template, isNested: false);
            EndTemplate(context, deploymentName, template);
        }

        protected virtual void BeginTemplate(TemplateContext context, string deploymentName, JObject template)
        {

        }

        protected virtual void Template(TemplateContext context, string deploymentName, JObject template, bool isNested)
        {
            try
            {
                context.EnterDeployment(deploymentName, template, isNested);

                // Process template sections
                if (TryStringProperty(template, PROPERTY_SCHEMA, out var schema))
                    Schema(context, schema);

                if (TryStringProperty(template, PROPERTY_CONTENTVERSION, out var contentVersion))
                    ContentVersion(context, contentVersion);

                if (TryObjectProperty(template, PROPERTY_PARAMETERS, out var parameters))
                    Parameters(context, parameters);

                if (TryArrayProperty(template, PROPERTY_FUNCTIONS, out var functions))
                    Functions(context, functions);

                if (TryObjectProperty(template, PROPERTY_VARIABLES, out var variables))
                    Variables(context, variables);

                if (TryArrayProperty(template, PROPERTY_RESOURCES, out var resources))
                    Resources(context, resources.Values<JObject>().ToArray());

                if (TryObjectProperty(template, PROPERTY_OUTPUTS, out var outputs))
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
            TryParameter(context, parameterName, parameter);
        }

        private static bool TryParameter(TemplateContext context, string parameterName, JObject parameter)
        {
            return parameter == null || TryParameterAssignment(context, parameterName, parameter) || TryParameterDefaultValue(context, parameterName, parameter) || TryParameterDefault(context, parameterName, parameter);
        }

        private static bool TryParameterAssignment(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!context.TryParameterAssignment(parameterName, out var value))
                return false;

            var type = GetParameterType(parameter);
            context.CheckParameter(parameterName, parameter, type, value);
            AddParameterFromType(context, parameterName, type, value);
            return true;
        }

        /// <summary>
        /// Try to fill parameter from default value.
        /// </summary>
        private static bool TryParameterDefaultValue(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!parameter.ContainsKey(PROPERTY_DEFAULTVALUE))
                return false;

            var type = GetParameterType(parameter);
            var defaultValue = ExpandPropertyToken(context, parameter[PROPERTY_DEFAULTVALUE]);
            if (type == ParameterType.String && !string.IsNullOrEmpty(parameter[PROPERTY_DEFAULTVALUE].Value<string>()))
                context.CheckParameter(parameterName, parameter, type, defaultValue);

            AddParameterFromType(context, parameterName, type, defaultValue);
            return true;
        }

        private static bool TryParameterDefault(TemplateContext context, string parameterName, JObject parameter)
        {
            var type = GetParameterType(parameter);
            if (!context.TryParameterDefault(parameterName, type, out var value))
                return false;

            context.CheckParameter(parameterName, parameter, type, value);
            AddParameterFromType(context, parameterName, type, value);
            return true;
        }

        private static ParameterType GetParameterType(JToken parameter)
        {
            return parameter[PROPERTY_TYPE].ToObject<ParameterType>();
        }

        private static void AddParameterFromType(TemplateContext context, string parameterName, ParameterType type, JToken value)
        {
            if (type == ParameterType.Bool)
                context.Parameter(new LazyParameter<bool>(parameterName, type, value));
            else if (type == ParameterType.Int)
                context.Parameter(new LazyParameter<long>(parameterName, type, value));
            else if (type == ParameterType.String)
                context.Parameter(new LazyParameter<string>(parameterName, type, value));
            else if (type == ParameterType.Array)
                context.Parameter(new LazyParameter<JArray>(parameterName, type, value));
            else if (type == ParameterType.Object)
                context.Parameter(new LazyParameter<JObject>(parameterName, type, value));
            else
                context.Parameter(parameterName, type, ExpandPropertyToken(context, value));
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
                !TryStringProperty(functionNamespace, PROPERTY_NAMESPACE, out var ns) ||
                !TryObjectProperty(functionNamespace, PROPERTY_MEMBERS, out var members))
                return;

            foreach (var property in members.Properties())
                Function(context, ns, property.Name, property.Value.Value<JObject>());
        }

        protected virtual void Function(TemplateContext context, string ns, string name, JObject function)
        {
            if (!TryObjectProperty(function, PROPERTY_OUTPUT, out var output))
                return;

            TryArrayProperty(function, PROPERTY_PARAMETERS, out var parameters);
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

            if (!TryObjectProperty(resource, PROPERTY_PROPERTIES, out var properties))
                return false;

            var deploymentContext = GetDeploymentContext(context, resource, properties);
            if (!TryObjectProperty(properties, PROPERTY_TEMPLATE, out var template))
                return false;

            Template(deploymentContext, deploymentName, template, isNested: true);
            if (deploymentContext != context)
                context.AddResource(deploymentContext.GetResources());

            return true;
        }

        private static TemplateContext GetDeploymentContext(TemplateContext context, JObject resource, JObject properties)
        {
            if (!TryObjectProperty(properties, PROPERTY_EXPRESSIONEVALUATIONOPTIONS, out var options) ||
                !TryStringProperty(options, PROPERTY_SCOPE, out var scope) ||
                !StringComparer.OrdinalIgnoreCase.Equals(DEPLOYMENTSCOPE_INNER, scope))
                return context;

            // Handle inner scope
            var subscription = new SubscriptionOption(context.Subscription);
            var resourceGroup = new ResourceGroupOption(context.ResourceGroup);
            var tenant = new TenantOption(context.Tenant);
            var managementGroup = new ManagementGroupOption(context.ManagementGroup);
            var parameterDefaults = new ParameterDefaultsOption(context.ParameterDefaults);
            if (TryStringProperty(resource, PROPERTY_SUBSCRIPTIONID, out var subscriptionId))
                subscription.SubscriptionId = subscriptionId;

            if (TryStringProperty(resource, PROPERTY_RESOURCEGROUP, out var resourceGroupName))
                resourceGroup.Name = resourceGroupName;

            resourceGroup.SubscriptionId = subscription.SubscriptionId;
            var deploymentContext = new TemplateContext(context.Pipeline, subscription, resourceGroup, tenant, managementGroup, parameterDefaults);
            if (TryObjectProperty(properties, PROPERTY_PARAMETERS, out var innerParameters))
            {
                foreach (var parameter in innerParameters.Properties())
                {
                    if (parameter.Value is JObject parameterInner)
                    {
                        if (parameterInner.TryGetProperty(PROPERTY_VALUE, out JToken parameterValue))
                            parameterInner[PROPERTY_VALUE] = ResolveVariable(context, parameterValue);

                        if (parameterInner.TryGetProperty(PROPERTY_COPY, out JArray _))
                        {
                            foreach (var copyIndex in GetVariableIterator(context, parameterInner, pushToStack: false))
                            {
                                if (copyIndex.IsCopy())
                                {
                                    var jArray = new JArray();
                                    while (copyIndex.Next())
                                    {
                                        var instance = copyIndex.CloneInput<JToken>();
                                        jArray.Add(ResolveToken(context, instance));
                                    }
                                    parameterInner[copyIndex.Name] = ResolveVariable(context, jArray);
                                }
                            }
                        }
                    }
                }
                deploymentContext.Load(properties);
            }

            deploymentContext.SetSource(context.TemplateFile, context.ParameterFile);
            return deploymentContext;
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

        private static TemplateContext.CopyIndexState[] GetVariableIterator(ITemplateContext context, JObject value, bool pushToStack = true)
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

                    if (pushToStack)
                        context.CopyIndex.Push(state);
                    else
                        context.CopyIndex.Add(state);

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
            if (!obj.TryGetValue(propertyName, out var value) || value.Type != JTokenType.Array)
                return false;

            propertyValue = value.Value<JArray>();
            return true;
        }

        private static bool TryObjectProperty(JObject obj, string propertyName, out JObject propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out var value) || value.Type != JTokenType.Object)
                return false;

            propertyValue = value as JObject;
            return true;
        }

        private static bool TryStringProperty(JObject obj, string propertyName, out string propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out var value) || value.Type != JTokenType.String)
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
                if (resources[i].Value.TryGetDependencies(out var dependencies))
                {
                    resources[i].Value.Remove(FIELD_DEPENDSON);
                    if (TemplateContext.TryParentResourceId(resources[i].Value, out var parentResourceId))
                    {
                        for (var j = 0; j < parentResourceId.Length; j++)
                        {
                            if (context.TryGetResource(parentResourceId[j], out var resource))
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
