// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Arm.Symbols;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal abstract partial class DeploymentVisitor
{
    [DebuggerDisplay("{Deployment?.Name}, Resources = {_Resources.Count}")]
    internal sealed class TemplateContext : ResourceManagerVisitorContext, ITemplateContext
    {
        private const string CLOUD_PUBLIC = "AzureCloud";
        private const string ISSUE_PARAMETER_EXPRESSION_LENGTH = "PSRule.Rules.Azure.Template.ExpressionLength";
        private const int EXPRESSION_MAX_LENGTH = 24576;

#nullable enable

        internal readonly ITemplateContext? Parent;

#nullable restore

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

#nullable enable

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

#nullable restore

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

#nullable enable

        /// <summary>
        /// Updated the <c>scope</c> property with the scope that the resource will be deployed into.
        /// </summary>
        /// <param name="resource">The resource object.</param>
        public string? UpdateResourceScope(JObject resource)
        {
            if (!resource.TryResourceScope(this, out var scopeId))
                return scopeId;

            resource[PROPERTY_SCOPE] = scopeId;
            return scopeId;
        }

#nullable restore

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
                { PROPERTY_TEMPLATE_HASH, templateHash },
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
                { PROPERTY_ROOT_DEPLOYMENT, !isNested }
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
                value is JValue jValue && jValue.IsEmpty())
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
            if (ParameterDefaults == null)
                return false;

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
}
