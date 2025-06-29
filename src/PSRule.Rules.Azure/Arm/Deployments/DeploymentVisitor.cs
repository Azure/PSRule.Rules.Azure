// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Arm.Mocks;
using PSRule.Rules.Azure.Arm.Symbols;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Arm.Deployments;

/// <summary>
/// The base class for a template visitor.
/// This is where most of the processing of an ARM deployment/ template/ module occurs.
/// The end result is a resource is emitted for each resource in the template.
/// </summary>
internal abstract partial class DeploymentVisitor : ResourceManagerVisitor
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
    private const string PROPERTY_TEMPLATE_HASH = "templateHash";
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
    private const string PROPERTY_ROOT_DEPLOYMENT = "rootDeployment";
    private const string PROPERTY_NULLABLE = "nullable";

    private const string TYPE_RESOURCE_GROUPS = "Microsoft.Resources/resourceGroups";

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

    /// <summary>
    /// Process the template object.
    /// </summary>
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

    /// <summary>
    /// After the template has been processed, perform any final processing.
    /// </summary>
    protected virtual void EndTemplate(TemplateContext context, string deploymentName, JObject template)
    {
        // Do nothing
    }

    protected virtual void Schema(TemplateContext context, string schema)
    {
        // Do nothing
    }

    protected virtual void ContentVersion(TemplateContext context, string contentVersion)
    {
        // Do nothing
    }

    #region Definitions

    /// <summary>
    /// Process the <c>definitions</c> property that defines custom types that may be used in the template.
    /// Each type definition is a key/ value with the name of the type as the key and the body of the definition as the value.
    /// </summary>
    protected void Definitions(TemplateContext context, JObject definitions)
    {
        if (definitions == null || definitions.Count == 0)
            return;

        // Custom types can based on other custom types.
        // The order of the definitions is important so that base types are defined before derived types.
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

    /// <summary>
    /// Process a single custom type definition.
    /// </summary>
    /// <param name="context">The current context.</param>
    /// <param name="definitionId">The name of the definition.</param>
    /// <param name="definition">The body of the definition.</param>
    /// <remarks>
    /// See <seealso href="https://learn.microsoft.com/azure/azure-resource-manager/templates/definitions">Type definitions in ARM templates</seealso>.
    /// </remarks>
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

    /// <summary>
    /// Process the <c>parameters</c> property that defines parameters that can be passed to the template.
    /// </summary>
    protected virtual void Parameters(TemplateContext context, JObject parameters)
    {
        if (parameters == null || parameters.Count == 0)
            return;

        foreach (var parameter in parameters)
            Parameter(context, parameter.Key, parameter.Value as JObject);

        foreach (var parameter in parameters)
            context.CheckParameter(parameter.Key, parameter.Value as JObject);
    }

    /// <summary>
    /// Process a single parameter definition.
    /// </summary>
    /// <param name="context"></param>
    /// <param name="parameterName">The name of the parameter.</param>
    /// <param name="parameter">The body of the parameter.</param>
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

    /// <summary>
    /// Try to fill the parameter from a value that has already been assigned to the parameter.
    /// A value could be set in a separate parameter file or in the parent deployment before it was called.
    /// </summary>
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

    private static ResourceValue ResourceInstance(TemplateContext context, JObject resource, CopyIndexState copyIndex, string symbolicName)
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

        _ = context.UpdateResourceScope(resource);
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
        if (TryDeploymentResource(context, resource.SymbolicName, resource.Value))
            return;

        ResolveProperties(context, resource.Value);
        Trim(resource.Value);
        TrackSecureProperties(context, resource, resource.Value);
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

    private static void TrackSecureProperties(ITemplateContext context, IResourceValue resource, JToken value)
    {
        if (value == null) return;

        if (value is ISecretPlaceholder placeholder)
        {
            resource.SecretProperties.Add(placeholder.Path);
        }
        else if (value is IMock mock && mock.IsSecret)
        {
            resource.SecretProperties.Add(value.Path);
        }
        else if (value is JValue jValue && context.IsSecureValue(jValue))
        {
            resource.SecretProperties.Add(jValue.Path);
        }


        if (value is JObject jObject)
        {
            foreach (var property in jObject.Properties().ToArray())
            {
                TrackSecureProperties(context, resource, property.Value);
            }
        }
        else if (value is JArray jArray)
        {
            foreach (var item in jArray)
            {
                TrackSecureProperties(context, resource, item);
            }
        }
    }

#nullable enable

    /// <summary>
    /// Handle a nested deployment resource.
    /// </summary>
    private bool TryDeploymentResource(TemplateContext context, string? symbolicName, JObject resource)
    {
        var resourceType = context.ExpandProperty<string>(resource, PROPERTY_TYPE);
        if (!IsDeploymentResource(resourceType))
            return false;

        var deploymentName = context.ExpandProperty<string>(resource, PROPERTY_NAME);
        if (string.IsNullOrEmpty(deploymentName))
            return false;

        if (!TryObjectProperty(resource, PROPERTY_PROPERTIES, out var properties))
            return false;

        var deploymentContext = GetDeploymentContext(context, symbolicName, deploymentName, resource, properties);
        if (!TryObjectProperty(properties, PROPERTY_TEMPLATE, out var template))
            return false;

        try
        {
            Template(deploymentContext, deploymentName, template, isNested: true);
        }
        catch (DeploymentEvaluationException)
        {
            throw;
        }
        catch (Exception ex)
        {
            // Let's add info about the current deployment symbol / name being expanded.
            throw new DeploymentEvaluationException(
                symbolicName,
                deploymentName,
                string.Format(Thread.CurrentThread.CurrentCulture, Diagnostics.FailedDeployment, deploymentContext.Name, symbolicName ?? string.Empty, ex.Message),
                ex
            );
        }

        // Collect resource from the completed deployment context in the parent context.
        if (deploymentContext != context)
            context.AddResource(deploymentContext.GetResources());

        return true;
    }

    protected static bool IsDeploymentResource(string resourceType)
    {
        return string.Equals(resourceType, RESOURCE_TYPE_DEPLOYMENT, StringComparison.OrdinalIgnoreCase);
    }

    private TemplateContext GetDeploymentContext(TemplateContext context, string? symbolicName, string deploymentName, JObject resource, JObject properties)
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

        var deploymentContext = new TemplateContext(context, context.Pipeline, deploymentName, subscription, resourceGroup, tenant, managementGroup, deployer, context.ParameterDefaults);

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

#nullable restore

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
        return value != null && value.IsExpressionString() ? context.EvaluateExpression<string>(value, null, null) : value;
    }

    internal static JToken ExpandPropertyToken(ITemplateContext context, TypePrimitive type, JToken value)
    {
        if (value == null || !value.IsExpressionString())
            return value;

        var result = context.EvaluateExpression<object>(value);
        if (result is IMock mock)
        {
            return mock.GetValue(type);
        }
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
        {
            ResolveProperty(context, obj, property.Name);
        }
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
    private static CopyIndexState[] GetPropertyIterator(ITemplateContext context, JObject value)
    {
        if (value.TryArrayProperty(PROPERTY_COPY, out var copyObjectArray))
        {
            var result = new List<CopyIndexState>();
            for (var i = 0; i < copyObjectArray.Count; i++)
            {
                var copyObject = copyObjectArray[i] as JObject;
                var state = new CopyIndexState
                {
                    Name = context.ExpandProperty<string>(copyObject, PROPERTY_NAME),
                    Input = copyObject[PROPERTY_INPUT],
                    Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
                };
                context.CopyIndex.Add(state);
                value.Remove(PROPERTY_COPY);
                result.Add(state);
            }
            return [.. result];
        }
        else
        {
            return [new() { Input = value }];
        }
    }

    /// <summary>
    /// Get an iterator for outputs.
    /// </summary>
    private static CopyIndexState[] GetOutputIterator(ITemplateContext context, JObject value)
    {
        if (value.TryObjectProperty(PROPERTY_COPY, out var copyObject))
        {
            var result = new List<CopyIndexState>();
            var state = new CopyIndexState
            {
                Name = string.Empty,
                Input = copyObject[PROPERTY_INPUT],
                Count = ExpandPropertyInt(context, copyObject, PROPERTY_COUNT)
            };
            context.CopyIndex.Add(state);
            value.Remove(PROPERTY_COPY);
            result.Add(state);
            return [.. result];
        }
        else
        {
            return [new() { Input = value }];
        }
    }

    private static IEnumerable<CopyIndexState> GetVariableIterator(ITemplateContext context, JObject value, bool pushToStack = true)
    {
        if (value.TryArrayProperty(PROPERTY_COPY, out var copyObjectArray))
        {
            for (var i = 0; i < copyObjectArray.Count; i++)
            {
                var copyObject = copyObjectArray[i] as JObject;
                var state = new CopyIndexState
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
        {
            yield return new CopyIndexState { Input = value };
        }
    }

    /// <summary>
    /// Get a resource based iterator copy.
    /// </summary>
    private static CopyIndexState GetResourceIterator(TemplateContext context, JObject value)
    {
        var result = new CopyIndexState
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

    private static CopyIndexState RestoreResourceIterator(TemplateContext context, IResourceValue value)
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
    private static TemplateParameterException ThrowTemplateParameterException(string parameterName)
    {
        return new TemplateParameterException(parameterName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterTypeInvalid, parameterName));
    }

    /// <summary>
    /// The type for output '{0}' was not defined or invalid.
    /// </summary>
    private static TemplateOutputException ThrowTemplateOutputException(string outputName)
    {
        return new TemplateOutputException(outputName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterTypeInvalid, outputName));
    }
}
