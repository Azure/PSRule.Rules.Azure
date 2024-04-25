// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A symbol used for debugging and runtime information.
    /// </summary>
    internal sealed class DebugSymbol
    {
        public DebugSymbol(string name, string symbolName)
        {
            Name = name;
            SymbolName = symbolName;
        }

        public string Name { get; }

        public string SymbolName { get; }
    }
}
