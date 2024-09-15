// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

internal abstract class BaseResourceValue(string id, string name, string symbolicName)
{
    /// <inheritdoc/>
    public string Id { get; } = id;

    /// <inheritdoc/>
    public string Name { get; } = name;

    /// <inheritdoc/>
    public string SymbolicName { get; } = symbolicName;
}
