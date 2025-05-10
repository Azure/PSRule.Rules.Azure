// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm.Symbols;

/// <summary>
/// A symbol used for debugging and runtime information.
/// </summary>
internal sealed class DebugSymbol(string name, string symbolName)
{
    public string Name { get; } = name;

    public string SymbolName { get; } = symbolName;
}
