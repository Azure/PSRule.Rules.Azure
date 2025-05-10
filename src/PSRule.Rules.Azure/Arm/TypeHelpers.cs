// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Arm;

#nullable enable

internal static class TypeHelpers
{
    public static bool TryTypePrimitive(string? type, out TypePrimitive? value)
    {
        if (string.IsNullOrEmpty(type) || !Enum.TryParse(type, ignoreCase: true, result: out TypePrimitive primitive))
        {
            value = default;
            return false;
        }
        value = primitive;
        return true;
    }
}

#nullable restore
