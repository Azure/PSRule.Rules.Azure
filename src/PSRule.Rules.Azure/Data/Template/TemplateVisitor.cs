// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    public delegate T StringExpression<T>();

    internal interface ITemplateContext
    {
        TemplateContext.CopyIndexStore CopyIndex { get; }

        DeploymentValue Deployment { get; }

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

        bool TryGetResource(string resourceId, out IResourceValue resource);

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
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_DEPENDSON = "dependsOn";

        internal sealed class TemplateContext : ITemplateContext
        {
            private const string DATAFILE_ENVIRONMENTS = "environments.json";
            private const string CLOUD_PUBLIC = "AzureCloud";
            private const string ISSUE_PARAMETER_EXPRESSIONLENGTH = "PSRule.Rules.Azure.Template.ExpressionLength";
            private const int EXPRESSION_MAXLENGTH = 24576;

            internal readonly PipelineContext Pipeline;

            private readonly Stack<DeploymentValue> _Deployment;
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly List<IResourceValue> _Resources;
            private readonly Dictionary<string, IResourceValue> _ResourceIds;
            private readonly ResourceProviderHelper _ResourceProviderHelper;
            private readonly Dictionary<string, JToken> _ParameterAssignments;
            private readonly TemplateValidator _Validator;

            private DeploymentValue _CurrentDeployment;
            private bool? _IsGenerated;
            private JObject _Parameters;
            private Dictionary<string, CloudEnvironment> _Environments;

            internal TemplateContext()
            {
                _Resources = new List<IResourceValue>();
                _ResourceIds = new Dictionary<string, IResourceValue>(StringComparer.OrdinalIgnoreCase);
                Parameters = new Dictionary<string, IParameterValue>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = ResourceGroupOption.Default;
                Subscription = SubscriptionOption.Default;
                Tenant = TenantOption.Default;
                ManagementGroup = ManagementGroupOption.Default;
                _Deployment = new Stack<DeploymentValue>();
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

            public DeploymentValue Deployment => _Deployment.Peek();

            public string TemplateFile { get; private set; }

            public string ParameterFile { get; private set; }

            public ExpressionFnOuter BuildExpression(string s)
            {
                if (s != null && s.Length > EXPRESSION_MAXLENGTH && !IsGenerated())
                    AddValidationIssue(ISSUE_PARAMETER_EXPRESSIONLENGTH, s, ReasonStrings.ExpressionLength, s, EXPRESSION_MAXLENGTH);

                return _ExpressionBuilder.Build(s);
            }

            public void AddResource(IResourceValue resource)
            {
                if (resource == null)
                    return;

                _Resources.Add(resource);
                _ResourceIds[resource.Id] = resource;
            }

            public void AddResource(IResourceValue[] resource)
            {
                for (var i = 0; resource != null && i < resource.Length; i++)
                    AddResource(resource[i]);
            }

            public IResourceValue[] GetResources()
            {
                return _Resources.ToArray();
            }

            public void RemoveResource(IResourceValue resource)
            {
                _Resources.Remove(resource);
                _ResourceIds.Remove(resource.Id);
            }

            public bool TryGetResource(string resourceId, out IResourceValue resource)
            {
                if (_ResourceIds.TryGetValue(resourceId, out resource))
                    return true;

                resource = null;
                return false;
            }

            public void AddOutput(string name, JObject output)
            {
                if (string.IsNullOrEmpty(name) || output == null || _CurrentDeployment == null)
                    return;

                _CurrentDeployment.AddOutput(name, new LazyOutput(this, output));
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

            internal bool TryParentResourceId(JObject resource, out string[] resourceId)
            {
                resourceId = null;
                if (!TryResourceScope(resource, out var id) ||
                    !ResourceHelper.TryResourceIdComponents(id, out var subscriptionId, out var resourceGroupName, out var resourceTypeComponents, out var nameComponents))
                    return false;

                resourceId = new string[nameComponents.Length];
                for (var i = 0; i < nameComponents.Length; i++)
                    resourceId[i] = ResourceHelper.CombineResourceId(subscriptionId, resourceGroupName, resourceTypeComponents, nameComponents, depth: i);

                return resourceId.Length > 0;
            }

            private static bool GetResourceNameType(JObject resource, out string name, out string type)
            {
                name = null;
                type = null;
                return resource != null && resource.TryGetProperty(PROPERTY_NAME, out name) && resource.TryGetProperty(PROPERTY_TYPE, out type);
            }

            private bool TryResourceScope(JObject resource, out string scopeId)
            {
                scopeId = null;
                if (!resource.ContainsKey(PROPERTY_SCOPE))
                    return false;

                var scope = ExpandProperty<string>(this, resource, PROPERTY_SCOPE);
                ResourceHelper.TryResourceIdComponents(scope, out var subscriptionId, out var resourceGroupName, out var resourceTypeComponents, out var nameComponents);
                subscriptionId ??= Subscription.SubscriptionId;
                resourceGroupName ??= ResourceGroup.Name;
                scopeId = ResourceHelper.CombineResourceId(subscriptionId, resourceGroupName, resourceTypeComponents, nameComponents);
                return true;
            }

            //private bool TryResourceScope(JObject resource, out string[] scopeId)
            //{
            //    scopeId = null;
            //    if (!TryResourceScope(resource, out string value))
            //        return false;

            //    scopeId = new string[] { value };
            //    return true;
            //}

            private bool TryParentScope(JObject resource, out string scopeId)
            {
                scopeId = null;
                if (!GetResourceNameType(resource, out var name, out var type) ||
                    !ResourceHelper.TryResourceIdComponents(type, name, out var resourceTypeComponents, out var nameComponents) ||
                    resourceTypeComponents.Length == 1)
                    return false;

                scopeId = ResourceHelper.GetParentResourceId(Subscription.SubscriptionId, ResourceGroup.Name, resourceTypeComponents, nameComponents);
                return true;
            }

            public void UpdateResourceScope(JObject resource)
            {
                if (!TryResourceScope(resource, out string scopeId) &&
                    !TryParentScope(resource, out scopeId))
                    return;

                resource[PROPERTY_SCOPE] = scopeId;
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

                internal CopyIndexState Clone()
                {
                    return new CopyIndexState
                    {
                        Index = Index,
                        Count = Count,
                        Input = Input,
                        Name = Name
                    };
                }
            }

            public sealed class CopyIndexStore
            {
                private readonly Dictionary<string, CopyIndexState> _Index;
                private readonly Stack<CopyIndexState> _Current;
                private readonly Stack<CopyIndexState> _CurrentResourceType;

                internal CopyIndexStore()
                {
                    _Index = new Dictionary<string, CopyIndexState>();
                    _Current = new Stack<CopyIndexState>();
                    _CurrentResourceType = new Stack<CopyIndexState>();
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

                internal void PushResourceType(CopyIndexState state)
                {
                    Push(state);
                    _CurrentResourceType.Push(state);
                }

                public void Pop()
                {
                    var state = _Current.Pop();
                    if (_CurrentResourceType.Count > 0 && _CurrentResourceType.Peek() == state)
                        _CurrentResourceType.Pop();

                    _Index.Remove(state.Name);
                }

                public bool TryGetValue(string name, out CopyIndexState state)
                {
                    if (name == null)
                    {
                        state = _CurrentResourceType.Count > 0 ? _CurrentResourceType.Peek() : Current;
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
                    { PROPERTY_TEMPLATEHASH, templateHash },
                    { PROPERTY_OUTPUTS, new JObject() }
                };

                var deployment = new JObject
                {
                    { PROPERTY_RESOURCENAME, ParameterFile ?? TemplateFile },
                    { PROPERTY_NAME, deploymentName },
                    { PROPERTY_PROPERTIES, properties },
                    { PROPERTY_LOCATION, ResourceGroup.Location },
                    { PROPERTY_TYPE, RESOURCETYPE_DEPLOYMENT },
                    { PROPERTY_METADATA, metadata }
                };
                deployment.SetTargetInfo(TemplateFile, ParameterFile);
                var deploymentValue = new DeploymentValue(string.Concat(ResourceGroup.Id, "/providers/", RESOURCETYPE_DEPLOYMENT, "/", deploymentName), deployment, null, null);
                AddResource(deploymentValue);
                _CurrentDeployment = deploymentValue;
                _Deployment.Push(deploymentValue);
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
                    _IsGenerated = TryObjectProperty(_CurrentDeployment.Value, PROPERTY_METADATA, out var metadata) &&
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

                value = pv.GetValue();
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
                        return ParameterDefaults.TryGetArray(parameterName, out value);

                    case ParameterType.Object:
                    case ParameterType.SecureObject:
                        return ParameterDefaults.TryGetObject(parameterName, out value);

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
                    value = weakValue.GetValue();
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
                _CurrentDeployment.Value.SetValidationIssue(issueId, name, message, args);
            }

            internal void CheckParameter(string parameterName, JObject parameter)
            {
                if (!Parameters.TryGetValue(parameterName, out var value))
                    return;

                if (value.Type == ParameterType.String && !string.IsNullOrEmpty(value.GetValue() as string))
                    _Validator.ValidateParameter(this, parameterName, parameter, value.GetValue() as string);
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

            public DeploymentValue Deployment => throw new NotImplementedException();

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

            public bool TryGetResource(string resourceId, out IResourceValue resource)
            {
                return _Inner.TryGetResource(resourceId, out resource);
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

        internal interface IParameterValue
        {
            string Name { get; }

            ParameterType Type { get; }

            object GetValue();
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

            public object GetValue()
            {
                return _Value;
            }
        }

        private sealed class LazyParameter<T> : ILazyValue, IParameterValue
        {
            private readonly TemplateContext _Context;
            private readonly JToken _LazyValue;
            private T _Value;
            private bool _Resolved;

            public LazyParameter(TemplateContext context, string name, ParameterType type, JToken defaultValue)
            {
                _Context = context;
                Name = name;
                Type = type;
                _LazyValue = defaultValue;
            }

            public string Name { get; }

            public ParameterType Type { get; }

            public object GetValue()
            {
                if (!_Resolved)
                {
                    _Value = ExpandToken<T>(_Context, _LazyValue);
                    _Resolved = true;
                }
                return _Value;
            }
        }

        private sealed class LazyVariable : ILazyValue
        {
            private readonly TemplateContext _Context;
            private readonly JToken _Value;

            public LazyVariable(TemplateContext context, JToken value)
            {
                _Context = context;
                _Value = value;
            }

            public object GetValue()
            {
                return ResolveVariable(_Context, _Value);
            }
        }

        private sealed class LazyOutput : ILazyValue
        {
            private readonly TemplateContext _Context;
            private readonly JObject _Value;

            public LazyOutput(TemplateContext context, JObject value)
            {
                _Context = context;
                _Value = value;
            }

            public object GetValue()
            {
                ResolveProperty(_Context, _Value, PROPERTY_VALUE);
                return _Value;
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

            foreach (var parameter in parameters)
                context.CheckParameter(parameter.Key, parameter.Value as JObject);
        }

        protected virtual void Parameter(TemplateContext context, string parameterName, JObject parameter)
        {
            TryParameter(context, parameterName, parameter);
        }

        private static bool TryParameter(TemplateContext context, string parameterName, JObject parameter)
        {
            return parameter == null ||
                TryParameterAssignment(context, parameterName, parameter) ||
                TryParameterDefaultValue(context, parameterName, parameter) ||
                TryParameterDefault(context, parameterName, parameter);
        }

        private static bool TryParameterAssignment(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!context.TryParameterAssignment(parameterName, out var value))
                return false;

            var type = GetParameterType(parameter);
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
            var defaultValue = parameter[PROPERTY_DEFAULTVALUE];
            AddParameterFromType(context, parameterName, type, defaultValue);
            return true;
        }

        private static bool TryParameterDefault(TemplateContext context, string parameterName, JObject parameter)
        {
            var type = GetParameterType(parameter);
            if (!context.TryParameterDefault(parameterName, type, out var value))
                return false;

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
                context.Parameter(new LazyParameter<bool>(context, parameterName, type, value));
            else if (type == ParameterType.Int)
                context.Parameter(new LazyParameter<long>(context, parameterName, type, value));
            else if (type == ParameterType.String)
                context.Parameter(new LazyParameter<string>(context, parameterName, type, value));
            else if (type == ParameterType.Array)
                context.Parameter(new LazyParameter<JArray>(context, parameterName, type, value));
            else if (type == ParameterType.Object)
                context.Parameter(new LazyParameter<JObject>(context, parameterName, type, value));
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

            var expanded = new List<ResourceValue>();
            for (var i = 0; i < resources.Length; i++)
                expanded.AddRange(ResourceExpand(context, resources[i]));

            var sorted = SortResources(context, expanded.ToArray());
            for (var i = 0; i < sorted.Length; i++)
                ResourceOuter(context, sorted[i]);
        }

        /// <summary>
        /// Expand copied resources.
        /// </summary>
        private static IEnumerable<ResourceValue> ResourceExpand(TemplateContext context, JObject resource)
        {
            var copyIndex = GetResourceIterator(context, resource);
            while (copyIndex.Next())
            {
                var instance = copyIndex.CloneInput<JObject>();
                var condition = !resource.ContainsKey(PROPERTY_CONDITION) || ExpandProperty<bool>(context, resource, PROPERTY_CONDITION);
                if (!condition)
                    continue;

                yield return ResourceInstance(context, instance, copyIndex);
            }
            if (copyIndex.IsCopy())
                context.CopyIndex.Pop();
        }

        private static ResourceValue ResourceInstance(TemplateContext context, JObject resource, TemplateContext.CopyIndexState copyIndex)
        {
            if (resource.TryGetProperty<JValue>(PROPERTY_NAME, out var nameValue))
                resource[PROPERTY_NAME] = ResolveToken(context, nameValue);

            if (resource.TryGetProperty<JArray>(PROPERTY_DEPENDSON, out var dependsOn))
                resource[PROPERTY_DEPENDSON] = ExpandArray(context, dependsOn);

            resource.TryGetProperty(PROPERTY_NAME, out var name);
            resource.TryGetProperty(PROPERTY_TYPE, out var type);
            resource.TryGetDependencies(out var dependencies);
            var resourceId = ResourceHelper.CombineResourceId(context.Subscription.SubscriptionId, context.ResourceGroup.Name, type, name);
            context.UpdateResourceScope(resource);
            return new ResourceValue(resourceId, type, resource, dependencies, copyIndex.Clone());
        }

        private void ResourceOuter(TemplateContext context, IResourceValue resource)
        {
            var copyIndex = RestoreResourceIterator(context, resource);
            Resource(context, resource);
            if (copyIndex != null && copyIndex.IsCopy())
                context.CopyIndex.Pop();
        }

        protected virtual void Resource(TemplateContext context, IResourceValue resource)
        {
            // Get resource type
            if (TryDeploymentResource(context, resource.Value))
                return;

            // Expand resource properties
            foreach (var property in resource.Value.Properties())
                ResolveProperty(context, resource.Value, property.Name);

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
                subscription.SubscriptionId = ExpandString(context, subscriptionId);

            if (TryStringProperty(resource, PROPERTY_RESOURCEGROUP, out var resourceGroupName))
                resourceGroup.Name = ExpandString(context, resourceGroupName);

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
            context.Variable(variableName, new LazyVariable(context, value));
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
            var result = ExpandToken<object>(context, value.Value<string>());
            return result == null ? JValue.CreateNull() : JToken.FromObject(result);
        }

        #endregion Variables

        #region Outputs

        protected void Outputs(TemplateContext context, JObject outputs)
        {
            if (outputs == null || outputs.Count == 0)
                return;

            foreach (var output in outputs)
                Output(context, output.Key, output.Value as JObject);
        }

        protected virtual void Output(TemplateContext context, string name, JObject output)
        {
            context.AddOutput(name, output);
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
            return result is JToken token && !typeof(JToken).IsAssignableFrom(typeof(T)) ? token.Value<T>() : Convert<T>(result);
        }

        private static T Convert<T>(object o)
        {
            if (o is T value)
                return value;

            return typeof(JToken).IsAssignableFrom(typeof(T)) && ExpressionHelpers.GetJToken(o) is T token ? token : (T)o;
        }

        internal static T ExpandToken<T>(ITemplateContext context, JToken value)
        {
            return value.IsExpressionString() ? EvaluateExpression<T>(context, value) : value.Value<T>();
        }

        internal static string ExpandString(ITemplateContext context, string value)
        {
            return value != null && value.IsExpressionString() ? EvaluateExpression<string>(context, value, null) : value;
        }

        internal static JToken ExpandPropertyToken(ITemplateContext context, JToken value)
        {
            if (value == null || !value.IsExpressionString())
                return value;

            var result = EvaluateExpression<object>(context, value);
            if (result is IMock mock && !mock.TryGetValue(out result))
                result = mock.ToString();

            return result == null ? null : JToken.FromObject(result);
        }

        private static T ExpandProperty<T>(ITemplateContext context, JObject value, string propertyName)
        {
            if (!value.ContainsKey(propertyName))
                return default(T);

            var propertyValue = value[propertyName].Value<JValue>();
            return (propertyValue.Type == JTokenType.String) ? ExpandToken<T>(context, propertyValue) : (T)propertyValue.Value<T>();
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
                context.CopyIndex.PushResourceType(result);
                value.Remove(PROPERTY_COPY);
            }
            return result;
        }

        private static TemplateContext.CopyIndexState RestoreResourceIterator(TemplateContext context, IResourceValue value)
        {
            var state = value.Copy;
            if (state != null && state.IsCopy())
                context.CopyIndex.PushResourceType(state);

            return state;
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

        protected static T EvaluateExpression<T>(ITemplateContext context, JToken value)
        {
            if (value.Type != JTokenType.String)
                return default(T);

            var svalue = value.Value<string>();
            var lineInfo = value.TryLineInfo();
            return EvaluateExpression<T>(context, svalue, lineInfo);
        }

        protected static T EvaluateExpression<T>(ITemplateContext context, string value, IJsonLineInfo lineInfo)
        {
            if (string.IsNullOrEmpty(value))
                return default(T);

            var exp = Expression<T>(context, value);
            try
            {
                return exp();
            }
            catch (Exception inner)
            {
                throw new ExpressionEvaluationException(value, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionEvaluateError, value, lineInfo?.LineNumber, inner.Message), inner);
            }
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
        protected virtual void Emit(TemplateContext context, IResourceValue resource)
        {
            resource.Value.SetTargetInfo(context.TemplateFile, context.ParameterFile);
            context.AddResource(resource);
        }

        /// <summary>
        /// Sort resources by dependencies.
        /// </summary>
        protected virtual IResourceValue[] SortResources(TemplateContext context, IResourceValue[] resources)
        {
            Array.Sort(resources, new ResourceDependencyComparer());
            return resources;
        }
    }

    /// <summary>
    /// A template visitor for generating rule data.
    /// </summary>
    internal sealed class RuleDataExportVisitor : TemplateVisitor
    {
        private const string PROPERTY_DEPENDSON = "dependsOn";
        private const string PROPERTY_COMMENTS = "comments";
        private const string PROPERTY_APIVERSION = "apiVersion";
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_RESOURCES = "resources";

        protected override void Resource(TemplateContext context, IResourceValue resource)
        {
            // Remove resource properties that not required in rule data
            if (resource.Value.ContainsKey(PROPERTY_APIVERSION))
                resource.Value.Remove(PROPERTY_APIVERSION);

            if (resource.Value.ContainsKey(PROPERTY_CONDITION))
                resource.Value.Remove(PROPERTY_CONDITION);

            if (resource.Value.ContainsKey(PROPERTY_COMMENTS))
                resource.Value.Remove(PROPERTY_COMMENTS);

            if (!resource.Value.TryGetDependencies(out _))
                resource.Value.Remove(PROPERTY_DEPENDSON);

            base.Resource(context, resource);
        }

        protected override void EndTemplate(TemplateContext context, string deploymentName, JObject template)
        {
            var resources = context.GetResources();
            for (var i = 0; i < resources.Length; i++)
            {
                if (resources[i].Value.TryGetDependencies(out var dependencies))
                {
                    resources[i].Value.Remove(PROPERTY_DEPENDSON);
                    if (context.TryParentResourceId(resources[i].Value, out var parentResourceId))
                    {
                        for (var j = 0; j < parentResourceId.Length; j++)
                        {
                            if (context.TryGetResource(parentResourceId[j], out var resource))
                            {
                                resource.Value.UseProperty(PROPERTY_RESOURCES, out JArray innerResources);
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
