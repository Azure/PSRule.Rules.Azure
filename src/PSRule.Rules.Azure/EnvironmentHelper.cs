// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure;

/// <summary>
/// Helper to read configuration from environment variables.
/// </summary>
/// <remarks>
/// This can be replaced with helpers from PSRule v3 in the future.
/// </remarks>
internal sealed class EnvironmentHelper
{
    public static readonly EnvironmentHelper Default = new();

    internal bool TryBool(string key, out bool value)
    {
        value = default;
        return TryVariable(key, out var variable) && TryParseBool(variable, out value);
    }

    private static bool TryVariable(string key, out string variable)
    {
        variable = Environment.GetEnvironmentVariable(key);
        return variable != null;
    }

    private static bool TryParseBool(string variable, out bool value)
    {
        if (bool.TryParse(variable, out value))
            return true;

        if (int.TryParse(variable, out var ivalue))
        {
            value = ivalue > 0;
            return true;
        }
        return false;
    }
}
