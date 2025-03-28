// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template;

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

    /// <summary>
    /// The scope of the current context.
    /// </summary>
    string ScopeId { get; }

    string TemplateFile { get; }

    string ParameterFile { get; }

    ResourceGroupOption ResourceGroup { get; }

    SubscriptionOption Subscription { get; }

    TenantOption Tenant { get; }

    ManagementGroupOption ManagementGroup { get; }

    DeployerOption Deployer { get; }

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

#nullable enable

    /// <summary>
    /// Try to get a resource from the current context.
    /// </summary>
    /// <param name="nameOrResourceId">The symbolic name or resource identifier.</param>
    /// <param name="resource">A resource.</param>
    /// <returns>Returns <c>true</c> when the resource exists.</returns>
    bool TryGetResource(string nameOrResourceId, out IResourceValue? resource);

    /// <summary>
    /// Try to get a resource collection from the current context.
    /// </summary>
    /// <param name="symbolicName">The symbolic name for the collection.</param>
    /// <param name="resources">A collection of resources.</param>
    /// <returns>Returns <c>true</c> when the symbolic name exists.</returns>
    bool TryGetResourceCollection(string symbolicName, out IResourceValue[]? resources);

#nullable restore

    /// <summary>
    /// Write a debug message for the current execution context.
    /// </summary>
    /// <param name="message">The format message.</param>
    /// <param name="args">Additional arguments for the format message.</param>
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
