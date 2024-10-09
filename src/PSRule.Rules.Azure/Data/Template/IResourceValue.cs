// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

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
    /// Determines if the resource value is an existing reference instead of full resource definition.
    /// </summary>
    bool Existing { get; }

    /// <summary>
    /// Copy state of the resource.
    /// </summary>
    TemplateContext.CopyIndexState Copy { get; }
}
