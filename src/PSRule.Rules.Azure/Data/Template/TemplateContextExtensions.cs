// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

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
}
