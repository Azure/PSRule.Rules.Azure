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
using static PSRule.Rules.Azure.Data.Template.Mock;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A string expression.
    /// </summary>
    public delegate T StringExpression<T>();

    /// <summary>
    /// The base class for a template visitor.
    /// </summary>
    internal abstract class TemplateVisitor : ResourceManagerVisitor
    {
        private const string TENANT_SCOPE = "/";
        private const string RESOURCE_TYPE_DEPLOYMENT = "Microsoft.Resources/deployments";
        private const string DEPLOYMENT_SCOPE_INNER = "inner";
        private const string PROPERTY_SCHEMA = "$schema";
        private const string PROPERTY_CONTENT_VERSION = "contentVersion";
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
        private const string PROPERTY_TEMPLATE_LINK = "templateLink";
        private const string PROPERTY_LOCATION = "location";
        private const string PROPERTY_COPY = "copy";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_RESOURCENAME = "ResourceName";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_INPUT = "input";
        private const string PROPERTY_MODE = "mode";
        private const string PROPERTY_DEFAULTVALUE = "defaultValue";
        private const string PROPERTY_SECRET_NAME = "secretName";
        private const string PROPERTY_PROVISIONING_STATE = "provisioningState";
        private const string PROPERTY_ID = "id";
        private const string PROPERTY_URI = "uri";
        private const string PROPERTY_TEMPLATEHASH = "templateHash";
        private const string PROPERTY_EXPRESSION_EVALUATION_OPTIONS = "expressionEvaluationOptions";
        private const string PROPERTY_SCOPE = "scope";
        private const string PROPERTY_RESOURCE_GROUP = "resourceGroup";
        private const string PROPERTY_SUBSCRIPTION_ID = "subscriptionId";
        private const string PROPERTY_MANAGEMENT_GROUP = "managementGroup";
        private const string PROPERTY_NAMESPACE = "namespace";
        private const string PROPERTY_MEMBERS = "members";
        private const string PROPERTY_OUTPUT = "output";
        private const string PROPERTY_METADATA = "metadata";
        private const string PROPERTY_GENERATOR = "_generator";
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_DEPENDS_ON = "dependsOn";
        private const string PROPERTY_DEFINITIONS = "definitions";
        private const string PROPERTY_REF = "$ref";
        private const string PROPERTY_ROOTDEPLOYMENT = "rootDeployment";
        private const string PROPERTY_NULLABLE = "nullable";

        private const string TYPE_RESOURCE_GROUPS = "Microsoft.Resources/resourceGroups";

        [DebuggerDisplay("{Deployment?.Name}, Resources = {_Resources.Count}")]
        internal sealed class TemplateContext : ResourceManagerVisitorContext, ITemplateContext
        {
            private const string CLOUD_PUBLIC = "AzureCloud";
            private const string ISSUE_PARAMETER_EXPRESSION_LENGTH = "PSRule.Rules.Azure.Template.ExpressionLength";
            private const int EXPRESSION_MAX_LENGTH = 24576;

            internal readonly ITemplateContext? Parent;

            internal readonly PipelineContext Pipeline;

            private readonly Stack<DeploymentValue> _Deployment;
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly List<IResourceValue> _Resources;
            private readonly Dictionary<string, IResourceValue> _ResourceIds;
            private readonly ResourceProviderHelper _ResourceProviderHelper;
            private readonly Dictionary<string, JToken> _ParameterAssignments;
            private readonly TemplateValidator _Validator;
            private readonly HashSet<object> _SecureValues;
            private readonly Dictionary<string, ITypeDefinition> _Definitions;
            private readonly Dictionary<string, IDeploymentSymbol> _Symbols;

            private DeploymentValue _CurrentDeployment;
            private bool? _IsGenerated;
            private JObject _Parameters;
            private EnvironmentData _Environments;
            private ResourceDependencyGraph _DependencyMap;

            internal TemplateContext()
            {
                _Resources = [];
                _ResourceIds = new Dictionary<string, IResourceValue>(StringComparer.OrdinalIgnoreCase);
                Parameters = new Dictionary<string, IParameterValue>(StringComparer.OrdinalIgnoreCase);
                Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                CopyIndex = new CopyIndexStore();
                ResourceGroup = ResourceGroupOption.Default;
                Subscription = SubscriptionOption.Default;
                Tenant = TenantOption.Default;
                ManagementGroup = ManagementGroupOption.Default;
                Deployer = DeployerOption.Default;
                _Deployment = new Stack<DeploymentValue>();
                _ExpressionFactory = new ExpressionFactory();
                _ExpressionBuilder = new ExpressionBuilder(_ExpressionFactory);
                _ResourceProviderHelper = new ResourceProviderHelper();
                _ParameterAssignments = [];
                _Validator = new TemplateValidator();
                _IsGenerated = null;
                _SecureValues = [];
                _Definitions = new Dictionary<string, ITypeDefinition>(StringComparer.OrdinalIgnoreCase);
                _Symbols = new Dictionary<string, IDeploymentSymbol>(StringComparer.OrdinalIgnoreCase);
            }

            internal TemplateContext(ITemplateContext? parent, PipelineContext pipelineContext, SubscriptionOption subscription, ResourceGroupOption resourceGroup, TenantOption tenant, ManagementGroupOption managementGroup, DeployerOption? deployer, IDictionary<string, object> parameterDefaults)
                : this()
            {
                Parent = parent;
                Pipeline = pipelineContext;
                if (subscription != null)
                    Subscription = subscription;

                if (resourceGroup != null)
                    ResourceGroup = resourceGroup;

                if (tenant != null)
                    Tenant = tenant;

                if (managementGroup != null)
                    ManagementGroup = managementGroup;

                if (deployer != null)
                    Deployer = deployer;

                if (parameterDefaults != null)
                    ParameterDefaults = new Dictionary<string, object>(parameterDefaults, StringComparer.OrdinalIgnoreCase);
            }

            internal TemplateContext(PipelineContext pipelineContext)
                : this()
            {
                Pipeline = pipelineContext;
                if (pipelineContext?.Option?.Configuration?.Subscription != null)
                    Subscription = pipelineContext.Option.Configuration.Subscription;

                if (pipelineContext?.Option?.Configuration?.ResourceGroup != null)
                    ResourceGroup = pipelineContext.Option.Configuration.ResourceGroup;

                if (pipelineContext?.Option?.Configuration?.Tenant != null)
                    Tenant = pipelineContext.Option.Configuration.Tenant;

                if (pipelineContext?.Option?.Configuration?.ManagementGroup != null)
                    ManagementGroup = pipelineContext.Option.Configuration.ManagementGroup;

                if (pipelineContext?.Option?.Configuration.Deployer != null)
                    Deployer = pipelineContext.Option.Configuration.Deployer;

                if (pipelineContext?.Option?.Configuration?.ParameterDefaults != null)
                    ParameterDefaults = new Dictionary<string, object>(pipelineContext.Option.Configuration.ParameterDefaults, StringComparer.OrdinalIgnoreCase);
            }

            private Dictionary<string, IParameterValue> Parameters { get; }

            private Dictionary<string, object> Variables { get; }

            public CopyIndexStore CopyIndex { get; }

            public ResourceGroupOption ResourceGroup { get; internal set; }

            public SubscriptionOption Subscription { get; internal set; }

            public TenantOption Tenant { get; internal set; }

            public ManagementGroupOption ManagementGroup { get; internal set; }

            public DeployerOption Deployer { get; internal set; }

            public IDictionary<string, object> ParameterDefaults { get; private set; }

            /// <inheritdoc/>
            public DeploymentValue Deployment => _Deployment.Count > 0 ? _Deployment.Peek() : null;

            /// <inheritdoc/>
            public string ScopeId => Deployment == null ? ResourceGroup.Id : Deployment.Scope;

            public string TemplateFile { get; private set; }

            public string ParameterFile { get; private set; }

            /// <summary>
            /// The top level deployment.
            /// </summary>
            internal DeploymentValue RootDeployment { get; private set; }

#nullable enable

            public ExpressionFnOuter BuildExpression(string? s)
            {
                if (s != null && s.Length > EXPRESSION_MAX_LENGTH && !IsGenerated())
                    AddValidationIssue(ISSUE_PARAMETER_EXPRESSION_LENGTH, s, null, ReasonStrings.ExpressionLength, s, EXPRESSION_MAX_LENGTH);

                return _ExpressionBuilder.Build(s);
            }

            public void AddResource(IResourceValue? resource)
            {
                if (resource == null)
                    return;

                _Resources.Add(resource);
                _ResourceIds[resource.Id] = resource;
            }

            public void AddResource(IResourceValue[]? resource)
            {
                for (var i = 0; resource != null && i < resource.Length; i++)
                    AddResource(resource[i]);
            }

            public IResourceValue[] GetResources()
            {
                return [.. _Resources];
            }

            public void RemoveResource(IResourceValue resource)
            {
                _Resources.Remove(resource);
                _ResourceIds.Remove(resource.Id);
            }

            /// <inheritdoc/>
            public bool TryGetResource(string nameOrResourceId, out IResourceValue? resource)
            {
                resource = null;
                if (string.IsNullOrWhiteSpace(nameOrResourceId))
                    return false;

                var resourceId = nameOrResourceId;
                if (_Symbols.TryGetValue(nameOrResourceId, out var symbol) && symbol != null)
                    resourceId = symbol.GetId(0);

                if (resourceId != null && _ResourceIds.TryGetValue(resourceId, out resource))
                    return true;

                // Recurse search for resource in the parent deployment by original resource ID only.
                if (Parent != null && ResourceHelper.IsResourceId(nameOrResourceId) && Parent.TryGetResource(nameOrResourceId, out resource))
                    return true;

                return false;
            }

            /// <inheritdoc/>
            public bool TryGetResourceCollection(string symbolicName, out IResourceValue[]? resources)
            {
                resources = null;
                if (!_Symbols.TryGetValue(symbolicName, out var symbol) || symbol is not ArrayDeploymentSymbol array)
                    return false;

                var ids = array.GetIds();
                resources = new IResourceValue[ids.Length];
                for (var i = 0; i < ids.Length; i++)
                    resources[i] = _ResourceIds[ids[i]];

                return true;
            }

#nullable restore

            public void AddOutput(string name, JObject output)
            {
                if (string.IsNullOrEmpty(name) || output == null || _CurrentDeployment == null)
                    return;

                _CurrentDeployment.AddOutput(name, new LazyOutput(this, name, output));
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
                if (!resource.TryResourceScope(this, out var scopeId))
                    return false;

                if (scopeId == TENANT_SCOPE)
                {
                    resourceId = [TENANT_SCOPE];
                    return true;
                }

                if (!ResourceHelper.ResourceIdComponents(scopeId, out var tenant, out var managementGroup, out var subscriptionId, out var resourceGroup, out var resourceType, out var resourceName) ||
                    resourceType == null || resourceType.Length == 0 || resourceName == null || resourceName.Length == 0)
                    return false;

                var depth = ResourceHelper.ResourceIdDepth(tenant, managementGroup, subscriptionId, resourceGroup, resourceType, resourceName);
                var resourceTypeDepth = ResourceHelper.ResourceNameOrTypeDepth(resourceType);
                resourceId = new string[resourceTypeDepth];
                for (var i = 0; i < resourceId.Length; i++)
                {
                    resourceId[i] = ResourceHelper.ResourceId(tenant, managementGroup, subscriptionId, resourceGroup, resourceType, resourceName, depth: depth - i);
                }
                return resourceId.Length > 0;
            }

            /// <summary>
            /// Updated the <c>scope</c> property with the scope that the resource will be deployed into.
            /// </summary>
            /// <param name="resource">The resource object.</param>
            public void UpdateResourceScope(JObject resource)
            {
                if (!resource.TryResourceScope(this, out var scopeId))
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
                if (value == null || value.Type == JTokenType.Null || value.Type == JTokenType.Undefined)
                    return;

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
                else if (valueType == JTokenType.Object && parameter[PROPERTY_REFERENCE] is JObject refObj && refObj.ContainsKey(PROPERTY_SECRET_NAME))
                {
                    AddParameterAssignment(name, SecretPlaceholder(refObj[PROPERTY_SECRET_NAME].Value<string>()));
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
                TryStringProperty(template, PROPERTY_SCHEMA, out var schema);
                var scope = GetDeploymentScope(schema, out var deploymentScope);
                var id = string.Concat(scope == "/" ? string.Empty : scope, "/providers/", RESOURCE_TYPE_DEPLOYMENT, "/", deploymentName);
                var location = ResourceGroup.Location;

                var templateLink = new JObject
                {
                    { PROPERTY_ID, ResourceGroup.Id },
                    { PROPERTY_URI, "https://deployment-uri" }
                };

                var properties = new JObject
                {
                    { PROPERTY_TEMPLATE, template.CloneTemplateJToken() },
                    { PROPERTY_TEMPLATE_LINK, templateLink },
                    { PROPERTY_PARAMETERS, _Parameters },
                    { PROPERTY_MODE, "Incremental" },
                    { PROPERTY_PROVISIONING_STATE, "Accepted" },
                    { PROPERTY_TEMPLATEHASH, templateHash },
                    { PROPERTY_OUTPUTS, new JObject() }
                };

                var deployment = new JObject
                {
                    { PROPERTY_RESOURCENAME, isNested ? deploymentName : ParameterFile ?? TemplateFile },
                    { PROPERTY_NAME, deploymentName },
                    { PROPERTY_PROPERTIES, properties },
                    { PROPERTY_LOCATION, location },
                    { PROPERTY_TYPE, RESOURCE_TYPE_DEPLOYMENT },
                    { PROPERTY_METADATA, metadata },

                    { PROPERTY_ID, id },
                    { PROPERTY_SCOPE, scope },

                    // Add a property to allow rules to detect root deployment. Related to: https://github.com/Azure/PSRule.Rules.Azure/issues/2109
                    { PROPERTY_ROOTDEPLOYMENT, !isNested }
                };

                var path = template.GetResourcePath(parentLevel: 2);
                deployment.SetTargetInfo(TemplateFile, ParameterFile, path);
                var deploymentValue = new DeploymentValue(id, deploymentName, null, scope, deploymentScope, deployment, null);
                AddResource(deploymentValue);
                _CurrentDeployment = deploymentValue;
                _Deployment.Push(deploymentValue);
                if (!isNested)
                    RootDeployment = _CurrentDeployment;
            }

            private string GetDeploymentScope(string schema, out DeploymentScope deploymentScope)
            {
                if (!string.IsNullOrEmpty(schema))
                {
                    schema = schema.TrimEnd('#', ' ');
                    var parts = schema.Split('/');
                    var template = parts[parts.Length - 1];

                    // Management Group
                    if (string.Equals(template, "managementGroupDeploymentTemplate.json", StringComparison.OrdinalIgnoreCase))
                    {
                        deploymentScope = DeploymentScope.ManagementGroup;
                        return ManagementGroup.Id;
                    }
                    // Subscription
                    if (string.Equals(template, "subscriptionDeploymentTemplate.json", StringComparison.OrdinalIgnoreCase))
                    {
                        deploymentScope = DeploymentScope.Subscription;
                        return Subscription.Id;
                    }
                    // Tenant
                    if (string.Equals(template, "tenantDeploymentTemplate.json", StringComparison.OrdinalIgnoreCase))
                    {
                        deploymentScope = DeploymentScope.Tenant;
                        return "/";
                    }
                }

                // Resource Group
                deploymentScope = DeploymentScope.ResourceGroup;
                return ResourceGroup.Id;
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
                TrackSecureValue(name, type, value);
                Parameters.Add(name, new SimpleParameterValue(name, type, value));
            }

            /// <summary>
            /// Add a parameter to the context.
            /// </summary>
            /// <param name="value">The <see cref="IParameterValue"/> to add.</param>
            internal void Parameter(IParameterValue value)
            {
                Parameters.Add(value.Name, value);
            }

            /// <summary>
            /// Keeps track of secure values.
            /// </summary>
            internal void TrackSecureValue(string name, ParameterType type, object value)
            {
                if (value == null || !(type.Type == TypePrimitive.SecureString || type.Type == TypePrimitive.SecureObject) ||
                    (value is JValue jValue && jValue.IsEmpty()))
                    return;

                _SecureValues.Add(value);
            }

            /// <inheritdoc/>
            public bool IsSecureValue(object value)
            {
                return _SecureValues.Contains(value);
            }

            /// <inheritdoc/>
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
                switch (type.Type)
                {
                    case TypePrimitive.String:
                    case TypePrimitive.SecureString:
                        if (ParameterDefaults.TryGetString(parameterName, out var s))
                        {
                            value = new JValue(s);
                            return true;
                        }
                        break;

                    case TypePrimitive.Bool:
                        if (ParameterDefaults.TryGetBool(parameterName, out var b))
                        {
                            value = new JValue(b);
                            return true;
                        }
                        break;

                    case TypePrimitive.Int:
                        if (ParameterDefaults.TryGetLong(parameterName, out var i))
                        {
                            value = new JValue(i);
                            return true;
                        }
                        break;

                    case TypePrimitive.Array:
                        if (ParameterDefaults.TryGetArray(parameterName, out var a))
                        {
                            value = a;
                            return true;
                        }
                        break;

                    case TypePrimitive.Object:
                    case TypePrimitive.SecureObject:
                        if (ParameterDefaults.TryGetObject(parameterName, out var o))
                        {
                            value = o;
                            return true;
                        }
                        break;
                }
                return false;
            }

            internal bool TryParameter(string parameterName)
            {
                return Parameters.ContainsKey(parameterName);
            }

            internal void Variable(string variableName, object value)
            {
                Variables[variableName] = value;
            }

            /// <inheritdoc/>
            public bool TryVariable(string variableName, out object value)
            {
                if (!Variables.TryGetValue(variableName, out value))
                    return false;

                if (value is ILazyValue weakValue)
                {
                    value = weakValue.GetValue();
                    Variables[variableName] = ConvertType(value);
                }
                return true;
            }

            internal void Function(string ns, string name, ExpressionFn fn)
            {
                var descriptor = new FunctionDescriptor(string.Concat(ns, ".", name), fn);
                _ExpressionFactory.With(descriptor);
            }

            /// <inheritdoc/>
            public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
            {
                return _ResourceProviderHelper.GetResourceType(providerNamespace, resourceType);
            }

            public CloudEnvironment GetEnvironment()
            {
                _Environments ??= new EnvironmentData();
                return _Environments.Get(CLOUD_PUBLIC);
            }

            internal void SetSource(string templateFile, string parameterFile)
            {
                TemplateFile = templateFile;
                ParameterFile = parameterFile;
            }

            /// <inheritdoc/>
            public void AddValidationIssue(string issueId, string name, string path, string message, params object[] args)
            {
                _CurrentDeployment.Value.SetValidationIssue(issueId, name, path, message, args);
            }

            internal void CheckParameter(string parameterName, JObject parameter)
            {
                if (!Parameters.TryGetValue(parameterName, out var value))
                    return;

                if (value.Type.Type == TypePrimitive.String && !string.IsNullOrEmpty(value.GetValue() as string))
                    _Validator.ValidateParameter(this, value.Type, parameterName, parameter, value.GetValue() as string);
            }

            internal void CheckOutput(string outputName, JObject output)
            {
                if (!TryParameterType(this, output, out var type))
                    throw ThrowTemplateOutputException(outputName);

                output.TryGetProperty<JToken>(PROPERTY_VALUE, out var value);
                _Validator.ValidateOutput(this, type.Value, outputName, output, value);
            }

            private static object ConvertType(object value)
            {
                return value is JToken token ? ConvertJToken(token) : value;
            }

            private static object ConvertJToken(JToken token)
            {
                if (token == null || token.Type == JTokenType.Null)
                    return null;

                if (token.Type == JTokenType.String)
                    return token.Value<string>();

                if (token.Type == JTokenType.Integer)
                    return token.Value<long>();

                if (token.Type == JTokenType.Boolean)
                    return token.Value<bool>();

                return token;
            }

            /// <inheritdoc/>
            public bool TryLambdaVariable(string variableName, out object value)
            {
                throw new NotImplementedException();
            }

            internal void AddDefinition(string definitionName, ITypeDefinition definition)
            {
                _Definitions.Add(definitionName, definition);
            }

            public bool TryDefinition(string definitionName, out ITypeDefinition definition)
            {
                return _Definitions.TryGetValue(definitionName, out definition);
            }

            internal void AddSymbol(IDeploymentSymbol symbol)
            {
                _Symbols.Add(symbol.Name, symbol);
            }

            internal IResourceValue[] SortDependencies(IResourceValue[] resources)
            {
                return _DependencyMap == null ? resources : _DependencyMap.Sort(resources);
            }

            /// <summary>
            /// Track dependencies against the resource.
            /// </summary>
            /// <param name="resource">The resource with dependencies to track.</param>
            /// <param name="dependencies">An array of dependencies as resource IDs or symbolic names.</param>
            internal void TrackDependencies(IResourceValue resource, string[] dependencies)
            {
                if (resource == null) return;

                _DependencyMap ??= new ResourceDependencyGraph();
                _DependencyMap.Track(resource, dependencies);
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
                    _Value = _Context.ExpandToken<T>(_LazyValue);
                    _Context.TrackSecureValue(Name, Type, _Value);
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

        [DebuggerDisplay("{_Name}, {_Type.Type}")]
        private sealed class LazyOutput : ILazyValue
        {
            private readonly string _Name;
            private readonly TemplateContext _Context;
            private readonly JObject _Value;
            private readonly ParameterType _Type;

            public LazyOutput(TemplateContext context, string name, JObject value)
            {
                _Context = context;
                _Name = name;
                _Value = value;
                if (!TryParameterType(context, value, out var type))
                    throw ThrowTemplateOutputException(name);

                _Type = type.Value;
            }

            public object GetValue()
            {
                ResolveProperty(_Context, _Value, PROPERTY_VALUE);

                // Handle basic types.
                if (_Value.TryValueProperty(out var value) && _Type.Type == TypePrimitive.String && value.Type == JTokenType.String)
                {
                    return _Value;
                }
                else if (value != null && _Type.Type == TypePrimitive.Bool && value.Type == JTokenType.Boolean)
                {
                    return _Value;
                }
                else if (value != null && _Type.Type == TypePrimitive.Int && value.Type == JTokenType.Integer)
                {
                    return _Value;
                }
                else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.String && value.Type == JTokenType.Array)
                {
                    return _Value;
                }
                else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.Bool && value.Type == JTokenType.Array)
                {
                    return _Value;
                }
                else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.Int && value.Type == JTokenType.Array)
                {
                    return _Value;
                }
                return new MockObject(_Value);
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
            // Do nothing
        }

        protected virtual void Template(TemplateContext context, string deploymentName, JObject template, bool isNested)
        {
            try
            {
                context.EnterDeployment(deploymentName, template, isNested);

                // Process template sections
                if (TryStringProperty(template, PROPERTY_SCHEMA, out var schema))
                    Schema(context, schema);

                if (TryStringProperty(template, PROPERTY_CONTENT_VERSION, out var contentVersion))
                    ContentVersion(context, contentVersion);

                // Handle custom type definitions
                if (!isNested && TryObjectProperty(template, PROPERTY_DEFINITIONS, out var definitions))
                    Definitions(context, definitions);

                // Handle compile time function variables
                if (TryObjectProperty(template, PROPERTY_VARIABLES, out var variables))
                    FunctionVariables(context, variables);

                if (TryArrayProperty(template, PROPERTY_FUNCTIONS, out var functions))
                    Functions(context, functions);

                if (TryObjectProperty(template, PROPERTY_PARAMETERS, out var parameters))
                    Parameters(context, parameters);

                if (TryObjectProperty(template, PROPERTY_VARIABLES, out variables))
                    Variables(context, variables);

                if (TryObjectProperty(template, PROPERTY_RESOURCES, out var oResources))
                    Resources(context, oResources);

                if (TryArrayProperty(template, PROPERTY_RESOURCES, out var aResources))
                    Resources(context, aResources);

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

        #region Definitions

        protected void Definitions(TemplateContext context, JObject definitions)
        {
            if (definitions == null || definitions.Count == 0)
                return;

            var graph = new CustomTypeTopologyGraph();
            foreach (var definition in definitions)
            {
                graph.Add(definition.Key, definition.Value as JObject);
            }

            foreach (var definition in graph.GetOrdered())
            {
                Definition(context, definition.Key, definition.Value);
            }
        }

        protected virtual void Definition(TemplateContext context, string definitionId, JObject definition)
        {
            if (TryDefinition(context, definition, out var value))
                context.AddDefinition(definitionId, value);
        }

        private static bool TryDefinition(TemplateContext context, JObject definition, out ITypeDefinition value)
        {
            value = null;
            var type = GetTypePrimitive(context, definition);
            if (type == TypePrimitive.None)
                return false;

            var isNullable = GetTypeNullable(context, definition);

            value = new TypeDefinition(type, definition, isNullable);
            return true;
        }

        #endregion Definitions

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
                FillParameterFromAssignedValue(context, parameterName, parameter) ||
                FillParameterFromDefaultValue(context, parameterName, parameter) ||
                FillParameterFromDefaultConfiguration(context, parameterName, parameter) ||
                FillParameterWhenNullable(context, parameterName, parameter);
        }

        private static bool FillParameterFromAssignedValue(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!context.TryParameterAssignment(parameterName, out var value))
                return false;

            if (!TryParameterType(context, parameter, out var type))
                throw ThrowTemplateParameterException(parameterName);

            AddParameterFromType(context, parameterName, type.Value, value);
            return true;
        }

        /// <summary>
        /// Try to fill the parameter from default value property on the definition.
        /// </summary>
        private static bool FillParameterFromDefaultValue(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!parameter.ContainsKey(PROPERTY_DEFAULTVALUE))
                return false;

            if (!TryParameterType(context, parameter, out var type))
                throw ThrowTemplateParameterException(parameterName);

            var defaultValue = parameter[PROPERTY_DEFAULTVALUE];
            AddParameterFromType(context, parameterName, type.Value, defaultValue);
            return true;
        }

        /// <summary>
        /// Try to fill the parameter from the PSRule default value configuration.
        /// </summary>
        private static bool FillParameterFromDefaultConfiguration(TemplateContext context, string parameterName, JObject parameter)
        {
            if (!TryParameterType(context, parameter, out var type))
                throw ThrowTemplateParameterException(parameterName);

            if (!context.TryParameterDefault(parameterName, type.Value, out var value))
                return false;

            AddParameterFromType(context, parameterName, type.Value, value);
            return true;
        }

        /// <summary>
        /// If the parameter been marked as nullable, fill the parameter with a null value.
        /// </summary>
        private static bool FillParameterWhenNullable(TemplateContext context, string parameterName, JObject parameter)
        {
            var isNullable = false;
            if (parameter.TryGetProperty(PROPERTY_REF, out var typeRef) &&
                context.TryDefinition(typeRef, out var definition) && definition.Nullable)
                isNullable = true;

            if (parameter.TryBoolProperty(PROPERTY_NULLABLE, out var nullable) && nullable.HasValue)
                isNullable = true;

            if (!isNullable)
                return false;

            if (!TryParameterType(context, parameter, out var type))
                throw ThrowTemplateParameterException(parameterName);

            AddParameterFromType(context, parameterName, type.Value, JToken.Parse("null"));
            return true;
        }

#nullable enable

        private static bool TryParameterType(ITemplateContext context, JObject parameter, out ParameterType? value)
        {
            value = null;
            if (parameter == null)
                throw new ArgumentNullException(nameof(parameter));

            // Try $ref property.
            if (parameter.TryGetProperty(PROPERTY_REF, out var type) &&
                context.TryDefinition(type, out var definition))
            {
                value = new ParameterType(definition.Type, default, type);
            }
            // Try type property.
            else if (parameter.TryTypeProperty(out type) && TypeHelpers.TryTypePrimitive(type, out var typePrimitive))
            {
                value = typePrimitive == TypePrimitive.Array && parameter.TryItemsTypeProperty(out var itemsType) ?
                    ParameterType.TryArrayType(type, itemsType, out var arrayType) ?
                        arrayType :
                        default :
                    ParameterType.TrySimpleType(type, out var typeSimple) ?
                        typeSimple :
                        default;
            }

            return value != null && value.Value.Type != TypePrimitive.None;
        }

#nullable restore

        private static void AddParameterFromType(TemplateContext context, string parameterName, ParameterType type, JToken value)
        {
            if (type.Type == TypePrimitive.Bool)
                context.Parameter(new LazyParameter<bool>(context, parameterName, type, value));
            else if (type.Type == TypePrimitive.Int)
                context.Parameter(new LazyParameter<long>(context, parameterName, type, value));
            else if (type.Type == TypePrimitive.String)
                context.Parameter(new LazyParameter<string>(context, parameterName, type, value));
            else if (type.Type == TypePrimitive.Array)
                context.Parameter(new LazyParameter<JArray>(context, parameterName, type, value));
            else if (type.Type == TypePrimitive.Object)
                context.Parameter(new LazyParameter<JObject>(context, parameterName, type, value));
            else
                context.Parameter(parameterName, type, ExpandPropertyToken(context, type.Type, value));
        }

        #endregion Parameters

        #region Functions

        protected virtual void Functions(TemplateContext context, JObject[] functions)
        {
            if (functions == null || functions.Length == 0)
                return;

            for (var i = 0; i < functions.Length; i++)
                FunctionNamespace(context, functions[i]);
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
                expanded.AddRange(ResourceExpand(context, null, resources[i]));

            Resources(context, expanded.ToArray());
        }

        /// <summary>
        /// Handle resources as an array of resources.
        /// </summary>
        private void Resources(TemplateContext context, ResourceValue[] resources)
        {
            if (resources.Length == 0)
                return;

            var sorted = SortResources(context, resources);
            for (var i = 0; i < sorted.Length; i++)
                ResourceOuter(context, sorted[i]);
        }

        /// <summary>
        /// Handle resources as symbolic named resources.
        /// </summary>
        private void Resources(TemplateContext context, JObject resources)
        {
            if (resources == null || resources.IsEmpty())
                return;

            // Collect resources
            var r = new List<ResourceValue>(resources.Count);
            foreach (var p in resources.Properties())
            {
                if (p.Value.Type == JTokenType.Object && p.Value.Value<JObject>() is JObject resource)
                {
                    if (resource.IsExisting())
                    {
                        Reference(context, p.Name, resource);
                    }
                    else if (!resource.IsImport())
                    {
                        r.AddRange(ResourceExpand(context, p.Name, resource));
                    }
                }
            }
            Resources(context, r.ToArray());
        }

        /// <summary>
        /// Handle an existing reference.
        /// </summary>
        private static void Reference(TemplateContext context, string symbolicName, JObject resource)
        {
            var copyIndex = GetResourceIterator(context, resource);
            var symbol = copyIndex.IsCopy() ? DeploymentSymbol.NewArray(symbolicName) : DeploymentSymbol.NewObject(symbolicName);

            while (copyIndex.Next())
            {
                var instance = copyIndex.CloneInput<JObject>();
                var condition = !instance.ContainsKey(PROPERTY_CONDITION) || context.ExpandProperty<bool>(instance, PROPERTY_CONDITION);
                if (!condition)
                    continue;

                if (!resource.TryTypeProperty(out var resourceType))
                    throw new Exception();

                var r = new ExistingResourceValue(context, resourceType, symbolicName, instance, copyIndex.Clone());
                symbol.Configure(r);

                // Add symbols for each array index.
                if (symbol != null && symbol.Kind == DeploymentSymbolKind.Array)
                    context.AddSymbol(DeploymentSymbol.NewObject(string.Concat(symbolicName, '[', copyIndex.Index, ']'), r));
            }

            if (copyIndex.IsCopy())
                context.CopyIndex.Pop();

            context.AddSymbol(symbol);
        }

        /// <summary>
        /// Expand copied resources.
        /// </summary>
        private static IEnumerable<ResourceValue> ResourceExpand(TemplateContext context, string symbolicName, JObject resource)
        {
            var copyIndex = GetResourceIterator(context, resource);
            var symbol = copyIndex.IsCopy() ? DeploymentSymbol.NewArray(symbolicName) : DeploymentSymbol.NewObject(symbolicName);
            while (copyIndex.Next())
            {
                var instance = copyIndex.CloneInput<JObject>();
                var condition = !resource.ContainsKey(PROPERTY_CONDITION) || context.ExpandProperty<bool>(resource, PROPERTY_CONDITION);
                if (!condition)
                    continue;

                var r = ResourceInstance(context, instance, copyIndex, symbolicName);
                symbol?.Configure(r);

                // Add symbols for each array index.
                if (symbol != null && symbol.Kind == DeploymentSymbolKind.Array)
                    context.AddSymbol(DeploymentSymbol.NewObject(string.Concat(symbolicName, '[', copyIndex.Index, ']'), r));

                yield return r;
            }
            if (copyIndex.IsCopy())
                context.CopyIndex.Pop();

            if (symbol != null)
                context.AddSymbol(symbol);
        }

        private static ResourceValue ResourceInstance(TemplateContext context, JObject resource, TemplateContext.CopyIndexState copyIndex, string symbolicName)
        {
            if (resource.TryGetProperty<JValue>(PROPERTY_NAME, out var nameValue))
                resource[PROPERTY_NAME] = ResolveToken(context, nameValue);

            if (resource.TryGetProperty<JArray>(PROPERTY_DEPENDS_ON, out var dependsOn))
                resource[PROPERTY_DEPENDS_ON] = ExpandArray(context, dependsOn);

            resource.TryNameProperty(out var name);
            resource.TryTypeProperty(out var type);

            var deploymentScope = GetDeploymentScope(context, resource, type, out var managementGroup, out var subscriptionId, out var resourceGroupName);

            // Get scope if specified.
            var scope = context.TryParentResourceId(resource, out var parentIds) && parentIds != null && parentIds.Length > 0 ? parentIds[0] : null;

            string resourceId = null;

            // Handle special case when resource type is a resource group.
            if (StringComparer.OrdinalIgnoreCase.Equals(type, TYPE_RESOURCE_GROUPS))
            {
                resourceId = ResourceHelper.ResourceGroupId(subscriptionId: subscriptionId, resourceGroup: name);
            }
            else if (deploymentScope == DeploymentScope.ResourceGroup)
            {
                resourceId = ResourceHelper.ResourceId(tenant: null, managementGroup: null, subscriptionId: subscriptionId, resourceGroup: resourceGroupName, resourceType: type, resourceName: name, scopeId: scope);
            }
            else if (deploymentScope == DeploymentScope.Subscription)
            {
                resourceId = ResourceHelper.ResourceId(tenant: null, managementGroup: null, subscriptionId: subscriptionId, resourceGroup: null, resourceType: type, resourceName: name, scopeId: null);
            }
            else if (deploymentScope == DeploymentScope.ManagementGroup)
            {
                resourceId = ResourceHelper.ResourceId(tenant: null, managementGroup: managementGroup, subscriptionId: null, resourceGroup: null, resourceType: type, resourceName: name, scopeId: scope);
            }
            else if (deploymentScope == DeploymentScope.Tenant)
            {
                resourceId = ResourceHelper.ResourceId(tenant: "/", managementGroup: null, subscriptionId: null, resourceGroup: null, resourceType: type, resourceName: name, scopeId: "/");
            }

            context.UpdateResourceScope(resource);
            resource[PROPERTY_ID] = resourceId;
            var result = new ResourceValue(resourceId, name, type, symbolicName, resource, copyIndex.Clone());

            // Map dependencies if any are defined.
            resource.TryGetDependencies(out var dependencies);
            context.TrackDependencies(result, dependencies);

            return result;
        }

        /// <summary>
        /// Get the deployment scope for the resource.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="resource">The resource.</param>
        /// <param name="type">The resource type.</param>
        /// <param name="managementGroup">Returns the management group name if the scope is within a management group.</param>
        /// <param name="subscriptionId">Returns the subscription ID if the scope is within a subscription.</param>
        /// <param name="resourceGroupName">Returns the resource group name if the scope is with a resource group.</param>
        /// <returns>The deployment scope.</returns>
        private static DeploymentScope GetDeploymentScope(TemplateContext context, JObject resource, string type, out string managementGroup, out string subscriptionId, out string resourceGroupName)
        {
            if (!IsDeploymentResource(type))
            {
                if (context.Deployment.DeploymentScope == DeploymentScope.ManagementGroup)
                {
                    managementGroup = context.ManagementGroup.Name;
                    resourceGroupName = null;
                    subscriptionId = null;
                    return context.Deployment.DeploymentScope;
                }

                managementGroup = null;
                resourceGroupName = context.ResourceGroup.Name;
                subscriptionId = context.Subscription.SubscriptionId;
                return context.Deployment.DeploymentScope;
            }

            // Handle special case for cross-scope deployments which may have an alternative subscription or resource group set.
            subscriptionId = ResolveDeploymentScopeProperty(context, resource, PROPERTY_SUBSCRIPTION_ID, contextValue:
                context.Deployment.DeploymentScope == DeploymentScope.Subscription ||
                context.Deployment.DeploymentScope == DeploymentScope.ResourceGroup ? context.Subscription.SubscriptionId : null);

            resourceGroupName = ResolveDeploymentScopeProperty(context, resource, PROPERTY_RESOURCE_GROUP, contextValue:
                context.Deployment.DeploymentScope == DeploymentScope.ResourceGroup ? context.ResourceGroup.Name : null);

            managementGroup = ResolveDeploymentScopeProperty(context, resource, PROPERTY_MANAGEMENT_GROUP, contextValue:
                context.Deployment.DeploymentScope == DeploymentScope.ManagementGroup ? context.ManagementGroup.Name : null);

            // Update the deployment scope.
            if (context.Deployment.DeploymentScope == DeploymentScope.ResourceGroup || resourceGroupName != null)
            {
                return DeploymentScope.ResourceGroup;
            }
            if (context.Deployment.DeploymentScope == DeploymentScope.Subscription || subscriptionId != null)
            {
                return DeploymentScope.Subscription;
            }
            if (context.Deployment.DeploymentScope == DeploymentScope.ManagementGroup || managementGroup != null)
            {
                return DeploymentScope.ManagementGroup;
            }

            return context.Deployment.DeploymentScope;
        }

        private static string ResolveDeploymentScopeProperty(TemplateContext context, JObject resource, string propertyName, string contextValue)
        {
            var resolvedValue = contextValue;
            if (resource.TryGetProperty<JValue>(propertyName, out var value) && value.Type != JTokenType.Null && ExpressionHelpers.TryString(value, out var s))
            {
                s = ExpandString(context, s);
                if (!string.IsNullOrEmpty(s))
                    resolvedValue = s;
            }

            resource[propertyName] = resolvedValue;
            return resolvedValue;
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

            ResolveProperties(context, resource.Value);
            Trim(resource.Value);
            Emit(context, resource);
        }

        /// <summary>
        /// Trim objects to remove null properties.
        /// </summary>
        private static void Trim(JToken value)
        {
            if (value == null) return;

            if (value is JObject jObject)
            {
                foreach (var property in jObject.Properties().ToArray())
                {
                    if (property.Value == null || property.Value.Type == JTokenType.Null)
                    {
                        property.Remove();
                    }
                    else
                    {
                        Trim(property.Value);
                    }
                }
            }
            else if (value is JArray jArray)
            {
                foreach (var item in jArray)
                {
                    Trim(item);
                }
            }
        }

        /// <summary>
        /// Handle a nested deployment resource.
        /// </summary>
        private bool TryDeploymentResource(TemplateContext context, JObject resource)
        {
            var resourceType = context.ExpandProperty<string>(resource, PROPERTY_TYPE);
            if (!IsDeploymentResource(resourceType))
                return false;

            var deploymentName = context.ExpandProperty<string>(resource, PROPERTY_NAME);
            if (string.IsNullOrEmpty(deploymentName))
                return false;

            if (!TryObjectProperty(resource, PROPERTY_PROPERTIES, out var properties))
                return false;

            var deploymentContext = GetDeploymentContext(context, deploymentName, resource, properties);
            if (!TryObjectProperty(properties, PROPERTY_TEMPLATE, out var template))
                return false;

            Template(deploymentContext, deploymentName, template, isNested: true);

            // Collect resource from the completed deployment context in the parent context.
            if (deploymentContext != context)
                context.AddResource(deploymentContext.GetResources());

            return true;
        }

        protected static bool IsDeploymentResource(string resourceType)
        {
            return string.Equals(resourceType, RESOURCE_TYPE_DEPLOYMENT, StringComparison.OrdinalIgnoreCase);
        }

        private TemplateContext GetDeploymentContext(TemplateContext context, string deploymentName, JObject resource, JObject properties)
        {
            if (!TryObjectProperty(properties, PROPERTY_EXPRESSION_EVALUATION_OPTIONS, out var options) ||
                !TryStringProperty(options, PROPERTY_SCOPE, out var scope) ||
                !StringComparer.OrdinalIgnoreCase.Equals(DEPLOYMENT_SCOPE_INNER, scope) ||
                !TryObjectProperty(properties, PROPERTY_TEMPLATE, out var template))
                return context;

            // Handle inner scope
            var subscription = new SubscriptionOption(context.Subscription);
            var resourceGroup = new ResourceGroupOption(context.ResourceGroup);
            var tenant = new TenantOption(context.Tenant);
            var managementGroup = new ManagementGroupOption(context.ManagementGroup);
            var deployer = new DeployerOption(context.Deployer);
            if (TryStringProperty(resource, PROPERTY_SUBSCRIPTION_ID, out var subscriptionId))
            {
                var targetSubscriptionId = ExpandString(context, subscriptionId);
                if (!string.IsNullOrEmpty(subscriptionId))
                    subscription.SubscriptionId = targetSubscriptionId;
            }

            if (TryStringProperty(resource, PROPERTY_RESOURCE_GROUP, out var resourceGroupName))
            {
                var targetResourceGroup = ExpandString(context, resourceGroupName);
                if (!string.IsNullOrEmpty(targetResourceGroup))
                    resourceGroup.Name = targetResourceGroup;
            }

            if (TryStringProperty(resource, PROPERTY_SCOPE, out var scopeId) && ResourceHelper.ResourceIdComponents(scopeId, out _, out var managementGroupName, out subscriptionId, out resourceGroupName, out _, out _))
            {
                if (!string.IsNullOrEmpty(managementGroupName))
                    managementGroup.Name = managementGroupName;

                if (!string.IsNullOrEmpty(subscriptionId))
                    subscription.SubscriptionId = subscriptionId;

                if (!string.IsNullOrEmpty(resourceGroupName))
                    resourceGroup.Name = resourceGroupName;
            }

            resourceGroup.SubscriptionId = subscription.SubscriptionId;
            TryObjectProperty(template, PROPERTY_PARAMETERS, out var templateParameters);

            var deploymentContext = new TemplateContext(context, context.Pipeline, subscription, resourceGroup, tenant, managementGroup, deployer, context.ParameterDefaults);

            // Handle custom type definitions early to allow type mapping of parameters if required.
            if (TryObjectProperty(template, PROPERTY_DEFINITIONS, out var definitions))
                Definitions(deploymentContext, definitions);

            if (TryObjectProperty(properties, PROPERTY_PARAMETERS, out var innerParameters))
            {
                foreach (var parameter in innerParameters.Properties())
                {
                    var parameterType = templateParameters.TryGetProperty<JObject>(parameter.Name, out var templateParameter) &&
                        TryParameterType(deploymentContext, templateParameter, out var t) ? t.Value.Type : TypePrimitive.None;

                    if (parameter.Value is JValue parameterValueExpression)
                        parameter.Value = ResolveToken(context, ResolveVariable(context, parameterType, parameterValueExpression));

                    if (parameter.Value is JObject parameterInner)
                    {
                        if (parameterInner.TryGetProperty(PROPERTY_VALUE, out JToken parameterValue))
                            parameterInner[PROPERTY_VALUE] = ResolveToken(context, ResolveVariable(context, parameterType, parameterValue));

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

        protected virtual void FunctionVariables(TemplateContext context, JObject variables)
        {
            if (variables == null || variables.Count == 0)
                return;

            foreach (var variable in variables)
            {
                if (variable.Key.StartsWith("$fxv#"))
                    Variable(context, variable.Key, variable.Value);
            }
        }

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
            ResolveProperties(context, value);
            return value;
        }

        protected virtual JToken VariableArray(TemplateContext context, JArray value)
        {
            return ExpandArray(context, value);
        }

        protected virtual JToken VariableSimple(TemplateContext context, JValue value)
        {
            var result = context.ExpandToken<object>(value.Value<string>());
            return result == null ? JValue.CreateNull() : JToken.FromObject(result);
        }

        #endregion Variables

        #region Outputs

        protected void Outputs(TemplateContext context, JObject outputs)
        {
            if (outputs == null || outputs.Count == 0)
                return;

            foreach (var output in outputs)
            {
                foreach (var copyIndex in GetOutputIterator(context, output.Value as JObject))
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
                        context.CopyIndex.Pop();
                        output.Value[PROPERTY_VALUE] = jArray;
                    }
                }
                Output(context, output.Key, output.Value as JObject);
            }
        }

        protected virtual void Output(TemplateContext context, string name, JObject output)
        {
            ResolveProperty(context, output, PROPERTY_VALUE, GetTypePrimitive(context, output));
            context.CheckOutput(name, output);
            context.AddOutput(name, output);
        }

        #endregion Outputs

        private static TypePrimitive GetTypePrimitive(TemplateContext context, JObject value)
        {
            if (value == null) return TypePrimitive.None;

            // Find primitive.
            if (value.TryGetProperty(PROPERTY_TYPE, out var t) && Enum.TryParse(t, ignoreCase: true, result: out TypePrimitive type))
                return type;

            // Find primitive from parent type.
            if (context != null && value.TryGetProperty(PROPERTY_REF, out var id) && context.TryDefinition(id, out var definition))
                return GetTypePrimitive(context, definition.Definition);

            return TypePrimitive.None;
        }

        private static bool GetTypeNullable(TemplateContext context, JObject value)
        {
            if (value == null) return false;

            // Find nullable from parent type.
            if (value.TryBoolProperty(PROPERTY_NULLABLE, out var nullable) && nullable.Value)
                return nullable.Value;

            if (context != null && value.TryGetProperty(PROPERTY_REF, out var id) && context.TryDefinition(id, out var definition))
                return definition.Nullable;

            return false;
        }

        internal static string ExpandString(ITemplateContext context, string value)
        {
            return value != null && value.IsExpressionString() ? context.EvaluateExpression<string>(value, null) : value;
        }

        internal static JToken ExpandPropertyToken(ITemplateContext context, TypePrimitive type, JToken value)
        {
            if (value == null || !value.IsExpressionString())
                return value;

            var result = context.EvaluateExpression<object>(value);
            if (result is IMock mock)
                return mock.GetValue(type);

            return result == null ? null : JToken.FromObject(result);
        }

        internal static JToken ExpandPropertyToken(ITemplateContext context, JToken value)
        {
            return ExpandPropertyToken(context, TypePrimitive.None, value);
        }

        private static int ExpandPropertyInt(ITemplateContext context, JObject value, string propertyName)
        {
            var result = context.ExpandProperty<long>(value, propertyName);
            return (int)result;
        }

        private static JToken ResolveVariable(ITemplateContext context, TypePrimitive primitive, JToken value)
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
                return ExpandPropertyToken(context, primitive, jToken);
            }
            return value;
        }

        private static JToken ResolveVariable(ITemplateContext context, JToken value)
        {
            return ResolveVariable(context, TypePrimitive.None, value);
        }

        /// <summary>
        /// Expand each property.
        /// </summary>
        private static void ResolveProperties(ITemplateContext context, JObject obj)
        {
            foreach (var property in obj.Properties().ToArray())
                ResolveProperty(context, obj, property.Name);
        }

        private static void ResolveProperty(ITemplateContext context, JObject obj, string propertyName, TypePrimitive type = TypePrimitive.None)
        {
            if (!obj.ContainsKey(propertyName) || propertyName == null)
                return;

            // Replace property
            if (propertyName.IsExpressionString())
            {
                var property = obj.Property(propertyName);
                propertyName = ExpandString(context, propertyName);
                property.Replace(new JProperty(propertyName, property.Value));
            }

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
                obj[propertyName] = ExpandPropertyToken(context, type, jToken);
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
            if (value.TryArrayProperty(PROPERTY_COPY, out var copyObjectArray))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState
                    {
                        Name = context.ExpandProperty<string>(copyObject, PROPERTY_NAME),
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
                return new TemplateContext.CopyIndexState[] { new() { Input = value } };
        }

        /// <summary>
        /// Get an iterator for outputs.
        /// </summary>
        private static TemplateContext.CopyIndexState[] GetOutputIterator(ITemplateContext context, JObject value)
        {
            if (value.TryObjectProperty(PROPERTY_COPY, out var copyObject))
            {
                var result = new List<TemplateContext.CopyIndexState>();
                var state = new TemplateContext.CopyIndexState
                {
                    Name = string.Empty,
                    Input = copyObject[PROPERTY_INPUT],
                    Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
                };
                context.CopyIndex.Add(state);
                value.Remove(PROPERTY_COPY);
                result.Add(state);
                return result.ToArray();
            }
            else
                return new TemplateContext.CopyIndexState[] { new() { Input = value } };
        }

        private static IEnumerable<TemplateContext.CopyIndexState> GetVariableIterator(ITemplateContext context, JObject value, bool pushToStack = true)
        {
            if (value.TryArrayProperty(PROPERTY_COPY, out var copyObjectArray))
            {
                for (var i = 0; i < copyObjectArray.Count; i++)
                {
                    var copyObject = copyObjectArray[i] as JObject;
                    var state = new TemplateContext.CopyIndexState
                    {
                        Name = context.ExpandProperty<string>(copyObject, PROPERTY_NAME),
                        Input = copyObject[PROPERTY_INPUT],
                        Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
                    };

                    if (pushToStack)
                        context.CopyIndex.Push(state);
                    else
                        context.CopyIndex.Add(state);

                    value.Remove(PROPERTY_COPY);
                    yield return state;
                }
            }
            else
                yield return new TemplateContext.CopyIndexState { Input = value };
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
            if (value.TryObjectProperty(PROPERTY_COPY, out var copyObject))
            {
                result.Name = context.ExpandProperty<string>(copyObject, PROPERTY_NAME);
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
                    context.CopyIndex.Remove(copyIndex);
                }
                else
                {
                    ResolveProperties(context, obj);
                }
            }
            return obj;
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

        protected static bool TryArrayProperty(JObject obj, string propertyName, out JObject[] propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out var value) || value.Type != JTokenType.Array)
                return false;

            propertyValue = value.Values<JObject>().ToArray();
            var annotation = obj.UseTokenAnnotation();
            if (annotation != null && propertyValue != null)
                propertyValue.UseTokenAnnotation(annotation.Path, propertyName);

            return true;
        }

        protected static bool TryObjectProperty(JObject obj, string propertyName, out JObject propertyValue)
        {
            propertyValue = null;
            if (!obj.TryGetValue(propertyName, out var value) || value.Type != JTokenType.Object)
                return false;

            propertyValue = value as JObject;
            var annotation = obj.UseTokenAnnotation();
            if (annotation != null && propertyValue != null)
                propertyValue.UseTokenAnnotation(annotation.Path, propertyName);

            return true;
        }

        protected static bool TryStringProperty(JObject obj, string propertyName, out string propertyValue)
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
            if (resource == null || resource.IsExisting())
                return;

            resource.Value.SetTargetInfo(context.TemplateFile, context.ParameterFile);
            context.AddResource(resource);
        }

        /// <summary>
        /// Sort resources by dependencies.
        /// </summary>
        protected virtual IResourceValue[] SortResources(TemplateContext context, IResourceValue[] resources)
        {
            return context.SortDependencies(resources);
        }

        /// <summary>
        /// The type for parameter '{0}' was not defined or invalid.
        /// </summary>
        private static Exception ThrowTemplateParameterException(string parameterName)
        {
            return new TemplateParameterException(parameterName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterTypeInvalid, parameterName));
        }

        /// <summary>
        /// The type for output '{0}' was not defined or invalid.
        /// </summary>
        private static Exception ThrowTemplateOutputException(string outputName)
        {
            return new TemplateOutputException(outputName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterTypeInvalid, outputName));
        }
    }
}
