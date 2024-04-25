// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A base implementation for template contexts.
    /// </summary>
    internal abstract class BaseTemplateContext
    {
        public virtual bool ShouldThrowMissingProperty => true;

        public DebugSymbol DebugSymbol { get; set; }
    }
}
