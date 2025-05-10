// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Arm.Deployments;

#nullable enable

[DebuggerDisplay("{Id}")]
internal sealed class ResourceValue : BaseResourceValue, IResourceValue
{
    internal ResourceValue(string id, string name, string type, string symbolicName, JObject value, CopyIndexState copy)
        : base(id, name, symbolicName)
    {
        Type = type;
        Value = value;
        Copy = copy;
    }

    /// <inheritdoc/>
    public string Type { get; }

    /// <inheritdoc/>
    public JObject Value { get; }

    /// <inheritdoc/>
    public bool Existing => false;

    /// <inheritdoc/>
    public CopyIndexState Copy { get; }

    /// <inheritdoc/>
    public string Scope => string.Empty;
}

#nullable restore
