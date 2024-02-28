// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface ITypeDefinition
    {
        TypePrimitive Type { get; }

        JObject Definition { get; }

        bool Nullable { get; }
    }

    internal sealed class TypeDefinition : ITypeDefinition
    {
        public TypeDefinition(TypePrimitive type, JObject definition, bool nullable)
        {
            Type = type;
            Definition = definition;
            Nullable = nullable;
        }

        public TypePrimitive Type { get; }

        public JObject Definition { get; }

        public bool Nullable { get; }
    }
}
