// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface ITypeDefinition
    {
        TypePrimitive Type { get; }
    }

    internal sealed class TypeDefinition : ITypeDefinition
    {
        public TypeDefinition(TypePrimitive type, JObject definition)
        {
            Type = type;
            Definition = definition;
        }

        public TypePrimitive Type { get; }

        public JObject Definition { get; }
    }
}
