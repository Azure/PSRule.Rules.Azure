// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Reflection;

namespace PSRule.Rules.Azure;

/// <summary>
/// Extensions for types.
/// </summary>
internal static class TypeExtensions
{
    public static bool TryGetValue(this Type type, object instance, string propertyOrField, out object value)
    {
        value = null;
        var property = type.GetProperty(propertyOrField, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetProperty | BindingFlags.Public);
        if (property != null)
        {
            value = property.GetValue(instance);
            return true;
        }

        // Try field
        var field = type.GetField(propertyOrField, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetField | BindingFlags.Public);
        if (field != null)
        {
            value = field.GetValue(instance);
            return true;
        }
        return false;
    }
}
