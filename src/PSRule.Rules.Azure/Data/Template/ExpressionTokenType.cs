// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// The available token types used for Azure Resource Manager expressions.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Naming", "CA1720:Identifier contains type name", Justification = "Represents standard type.")]
    public enum ExpressionTokenType : byte
    {
        /// <summary>
        /// Null token.
        /// </summary>
        None,

        /// <summary>
        /// A function name.
        /// </summary>
        Element,

        /// <summary>
        /// A property <c>.property_name</c>.
        /// </summary>
        Property,

        /// <summary>
        /// A string literal.
        /// </summary>
        String,

        /// <summary>
        /// A numeric literal.
        /// </summary>
        Numeric,

        /// <summary>
        /// Start a grouping <c>'('</c>.
        /// </summary>
        GroupStart,

        /// <summary>
        /// End a grouping <c>')'</c>.
        /// </summary>
        GroupEnd,

        /// <summary>
        /// Start an index <c>'['</c>.
        /// </summary>
        IndexStart,

        /// <summary>
        /// End an index <c>']'</c>.
        /// </summary>
        IndexEnd
    }
}
