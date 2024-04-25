// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
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

        DebugSymbol DebugSymbol { get; set; }

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
}
