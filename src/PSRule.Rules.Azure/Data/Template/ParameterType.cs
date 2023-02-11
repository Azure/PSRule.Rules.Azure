// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Data.Template
{
    [JsonConverter(typeof(StringEnumConverter))]
    internal enum TypePrimitive
    {
        None,

        Array,

        Bool,

        Int,

        Object,

        String,

        SecureString,

        SecureObject
    }

    internal readonly struct ParameterType
    {
        public readonly TypePrimitive Type;
        public readonly string Name;

        public static readonly ParameterType String = new(TypePrimitive.String);
        public static readonly ParameterType Object = new(TypePrimitive.Object);
        public static readonly ParameterType SecureString = new(TypePrimitive.SecureString);
        public static readonly ParameterType Array = new(TypePrimitive.Array);

        public ParameterType(TypePrimitive type = TypePrimitive.None, string name = null)
        {
            Type = type;
            Name = name;
        }

        //public static bool operator ==(ParameterType left, TypePrimitive right)
        //{
        //    return left.Type == right;
        //}

        //public static bool operator !=(ParameterType left, TypePrimitive right)
        //{
        //    return left.Type != right;
        //}

        public static bool TrySimpleType(string type, out ParameterType value)
        {
            if (!Enum.TryParse(type, ignoreCase: true, result: out TypePrimitive primitive))
            {
                value = new ParameterType();
                return false;
            }
            value = new ParameterType(primitive, null);
            return true;
        }
    }
}
