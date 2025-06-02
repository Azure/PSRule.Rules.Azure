// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Arm;
using PSRule.Rules.Azure.Arm.Deployments;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// A implementation for nested template contexts.
/// </summary>
internal abstract class NestedTemplateContext(ITemplateContext context) : ResourceManagerVisitorContext, ITemplateContext
{
    protected readonly ITemplateContext _Inner = context;

    public CopyIndexStore CopyIndex => _Inner.CopyIndex;

    public DeploymentValue Deployment => _Inner.Deployment;

    public string ScopeId => _Inner.ScopeId;

    public string TemplateFile => _Inner.TemplateFile;

    public string ParameterFile => _Inner.ParameterFile;

    public ResourceGroupOption ResourceGroup => _Inner.ResourceGroup;

    public SubscriptionOption Subscription => _Inner.Subscription;

    public TenantOption Tenant => _Inner.Tenant;

    public ManagementGroupOption ManagementGroup => _Inner.ManagementGroup;

    public DeployerOption Deployer => _Inner.Deployer;

    public ExpressionFnOuter BuildExpression(string s)
    {
        return _Inner.BuildExpression(s);
    }

    public CloudEnvironment GetEnvironment()
    {
        return _Inner.GetEnvironment();
    }

    /// <inheritdoc/>
    public virtual bool TryParameter(string parameterName, out object value)
    {
        return _Inner.TryParameter(parameterName, out value);
    }

    /// <inheritdoc/>
    public virtual bool TryVariable(string variableName, out object value)
    {
        return _Inner.TryVariable(variableName, out value);
    }

    /// <inheritdoc/>
    public bool TryGetResource(string nameOrResourceId, out IResourceValue resource)
    {
        return _Inner.TryGetResource(nameOrResourceId, out resource);
    }

    /// <inheritdoc/>
    public bool TryGetResourceCollection(string symbolicName, out IResourceValue[] resources)
    {
        return _Inner.TryGetResourceCollection(symbolicName, out resources);
    }

    /// <inheritdoc/>
    public void WriteDebug(string message, params object[] args)
    {
        _Inner.WriteDebug(message, args);
    }

    /// <inheritdoc/>
    public virtual bool TryLambdaVariable(string variableName, out object value)
    {
        return _Inner.TryLambdaVariable(variableName, out value);
    }

    /// <inheritdoc/>
    public bool TryDefinition(string type, out ITypeDefinition definition)
    {
        return _Inner.TryDefinition(type, out definition);
    }

    #region IValidationContext

    /// <inheritdoc/>
    public void AddValidationIssue(string issueId, string name, string path, string message, params object[] args)
    {
        _Inner.AddValidationIssue(issueId, name, path, message, args);
    }

    /// <inheritdoc/>
    public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
    {
        return _Inner.GetResourceType(providerNamespace, resourceType);
    }

    /// <inheritdoc/>
    public AzureLocationEntry GetAzureLocation(string location)
    {
        return _Inner.GetAzureLocation(location);
    }

    /// <inheritdoc/>
    public bool IsSecureValue(object value)
    {
        return _Inner.IsSecureValue(value);
    }

    #endregion IValidationContext
}
