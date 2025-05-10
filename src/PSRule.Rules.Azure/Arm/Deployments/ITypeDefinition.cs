// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal interface ITypeDefinition
{
    TypePrimitive Type { get; }

    JObject Definition { get; }

    bool Nullable { get; }
}
