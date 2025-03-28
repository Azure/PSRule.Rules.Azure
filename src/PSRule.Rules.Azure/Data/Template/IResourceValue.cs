// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

internal interface IResourceValue : IResourceIdentity
{
    /// <summary>
    /// The resource type.
    /// </summary>
    string Type { get; }

    /// <summary>
    /// The resource value.
    /// </summary>
    JObject Value { get; }

    /// <summary>
    /// The scope of the resource.
    /// </summary>
    string Scope { get; }

    /// <summary>
    /// Determines if the resource value is an existing reference instead of full resource definition.
    /// </summary>
    bool Existing { get; }

    /// <summary>
    /// Copy state of the resource.
    /// </summary>
    CopyIndexState Copy { get; }
}
