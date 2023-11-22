// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    internal static class TemplateContextExtensions
    {
        /// <summary>
        /// Get a lambda variable from the current context scope.
        /// This will throw an exception if the current context is not within a lambda expression.
        /// </summary>
        /// <param name="context">An instance of a <see cref="ITemplateContext"/>.</param>
        /// <param name="variableName">The name of the variable. Variable names are case-insensitive.</param>
        /// <param name="value">The returned value of the variable.</param>
        /// <returns>Returns <c>true</c> if the variable exists or <c>false</c> if a variable with the specified name could not be found.</returns>
        /// <exception cref="NotImplementedException">A lambda variable can not be evaluated outside a lambda expression.</exception>
        public static bool TryLambdaVariable<TValue>(this ITemplateContext context, string variableName, out TValue value)
        {
            value = default;
            if (!context.TryLambdaVariable(variableName, out var v))
                return false;

            value = (TValue)v;
            return true;
        }
    }

    /// <summary>
    /// An interface for a template context.
    /// </summary>
    internal interface ITemplateContext : IValidationContext
    {
        TemplateContext.CopyIndexStore CopyIndex { get; }

        /// <summary>
        /// The current deployment.
        /// </summary>
        DeploymentValue Deployment { get; }

        string TemplateFile { get; }

        string ParameterFile { get; }

        ResourceGroupOption ResourceGroup { get; }

        SubscriptionOption Subscription { get; }

        TenantOption Tenant { get; }

        ManagementGroupOption ManagementGroup { get; }

        bool ShouldThrowMissingProperty { get; }

        ExpressionFnOuter BuildExpression(string s);

        CloudEnvironment GetEnvironment();

        /// <summary>
        /// Get a parameter from the current context.
        /// </summary>
        /// <param name="parameterName">The name of the parameter. Parameter names are case-insensitive.</param>
        /// <param name="value">The returned value of the parameter.</param>
        /// <returns>Returns <c>true</c> if the parameter exists or <c>false</c> if a parameter with the specified name could not be found.</returns>
        bool TryParameter(string parameterName, out object value);

        /// <summary>
        /// Get a variable from the current context.
        /// </summary>
        /// <param name="variableName">The name of the variable. Variable names are case-insensitive.</param>
        /// <param name="value">The returned value of the variable.</param>
        /// <returns>Returns <c>true</c> if the variable exists or <c>false</c> if a variable with the specified name could not be found.</returns>
        bool TryVariable(string variableName, out object value);

        bool TryDefinition(string type, out ITypeDefinition definition);

        bool TryGetResource(string resourceId, out IResourceValue resource);

        void WriteDebug(string message, params object[] args);

        /// <summary>
        /// Get a lambda variable from the current context scope.
        /// This will throw an exception if the current context is not within a lambda expression.
        /// </summary>
        /// <param name="variableName">The name of the variable. Variable names are case-insensitive.</param>
        /// <param name="value">The returned value of the variable.</param>
        /// <returns>Returns <c>true</c> if the variable exists or <c>false</c> if a variable with the specified name could not be found.</returns>
        /// <exception cref="NotImplementedException">A lambda variable can not be evaluated outside a lambda expression.</exception>
        bool TryLambdaVariable(string variableName, out object value);
    }

    /// <summary>
    /// A base implementation of a template context.
    /// </summary>
    internal abstract class BaseTemplateContext : ITemplateContext
    {
        protected readonly ITemplateContext _Inner;

        public BaseTemplateContext(ITemplateContext context)
        {
            _Inner = context;
        }

        public TemplateContext.CopyIndexStore CopyIndex => _Inner.CopyIndex;

        public DeploymentValue Deployment => throw new NotImplementedException();

        public string TemplateFile => _Inner.TemplateFile;

        public string ParameterFile => _Inner.ParameterFile;

        public ResourceGroupOption ResourceGroup => _Inner.ResourceGroup;

        public SubscriptionOption Subscription => _Inner.Subscription;

        public TenantOption Tenant => _Inner.Tenant;

        public ManagementGroupOption ManagementGroup => _Inner.ManagementGroup;

        public virtual bool ShouldThrowMissingProperty => true;

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

        public bool TryGetResource(string resourceId, out IResourceValue resource)
        {
            return _Inner.TryGetResource(resourceId, out resource);
        }

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
