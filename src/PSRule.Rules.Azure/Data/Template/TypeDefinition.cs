// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

internal sealed class TypeDefinition(TypePrimitive type, JObject definition, bool nullable) : ITypeDefinition
{
    public TypePrimitive Type { get; } = type;

    public JObject Definition { get; } = definition;

    public bool Nullable { get; } = nullable;
}
