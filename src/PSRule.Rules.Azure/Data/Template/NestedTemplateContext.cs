// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A implementation for nested template contexts.
    /// </summary>
    internal abstract class NestedTemplateContext : BaseTemplateContext, ITemplateContext
    {
        protected readonly ITemplateContext _Inner;

        public NestedTemplateContext(ITemplateContext context)
        {
            _Inner = context;
        }

        public TemplateContext.CopyIndexStore CopyIndex => _Inner.CopyIndex;

        public DeploymentValue Deployment => throw new NotImplementedException();

        public string ScopeId => _Inner.ScopeId;

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
        public bool IsSecureValue(object value)
        {
            return _Inner.IsSecureValue(value);
        }

        #endregion IValidationContext
    }
}
