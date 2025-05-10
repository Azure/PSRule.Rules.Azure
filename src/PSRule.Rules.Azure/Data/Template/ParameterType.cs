// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using PSRule.Rules.Azure.Arm;

namespace PSRule.Rules.Azure.Data.Template;

#nullable enable

[DebuggerDisplay("{Type}/{ItemType}, {Name}")]
internal readonly struct ParameterType(TypePrimitive type = TypePrimitive.None, TypePrimitive itemType = TypePrimitive.None, string? name = null)
{
    public readonly TypePrimitive Type = type;
    public readonly TypePrimitive ItemType = itemType;
    public readonly string? Name = name;

    public static readonly ParameterType String = new(TypePrimitive.String);
    public static readonly ParameterType Object = new(TypePrimitive.Object);
    public static readonly ParameterType SecureString = new(TypePrimitive.SecureString);
    public static readonly ParameterType Array = new(TypePrimitive.Array);

    public static bool TrySimpleType(string? type, out ParameterType? value)
    {
        if (!TypeHelpers.TryTypePrimitive(type, out var primitive) || primitive == null)
        {
            value = new ParameterType();
            return false;
        }
        value = new ParameterType(primitive.Value, default, default);
        return true;
    }

    public static bool TryArrayType(string? type, string? itemType, out ParameterType? value)
    {
        if (!TypeHelpers.TryTypePrimitive(type, out var primitive) || primitive == null)
        {
            value = new ParameterType();
            return false;
        }

        value = TypeHelpers.TryTypePrimitive(itemType, out var itemPrimitive) && itemPrimitive != null
            ? new ParameterType(primitive.Value, itemPrimitive.Value, default)
            : new ParameterType(primitive.Value, TypePrimitive.None, default);

        return true;
    }
}

#nullable restore
