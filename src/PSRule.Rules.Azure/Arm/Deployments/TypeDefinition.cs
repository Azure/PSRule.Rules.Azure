// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal sealed class TypeDefinition(TypePrimitive type, JObject definition, bool nullable) : ITypeDefinition
{
    public TypePrimitive Type { get; } = type;

    public JObject Definition { get; } = definition;

    public bool Nullable { get; } = nullable;
}
