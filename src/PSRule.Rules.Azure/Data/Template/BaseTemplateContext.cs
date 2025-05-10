// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Arm.Symbols;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// A base implementation for template contexts.
/// </summary>
internal abstract class ResourceManagerVisitorContext
{
    public virtual bool ShouldThrowMissingProperty => true;

    public DebugSymbol DebugSymbol { get; set; }
}
