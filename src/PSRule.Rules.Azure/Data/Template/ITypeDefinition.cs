// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

internal interface ITypeDefinition
{
    TypePrimitive Type { get; }

    JObject Definition { get; }

    bool Nullable { get; }
}
