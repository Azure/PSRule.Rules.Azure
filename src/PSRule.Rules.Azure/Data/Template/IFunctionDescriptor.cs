// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A common interface for defining and invoking ARM functions.
    /// </summary>
    internal interface IFunctionDescriptor
    {
        /// <summary>
        /// The name of the function.
        /// </summary>
        string Name { get; }

        /// <summary>
        /// Invoke the function.
        /// </summary>
        object Invoke(ITemplateContext context, DebugSymbol debugSymbol, ExpressionFnOuter[] args);
    }
}
