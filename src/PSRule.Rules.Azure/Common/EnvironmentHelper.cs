// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure
{
    internal sealed class EnvironmentHelper
    {
        public static readonly EnvironmentHelper Default = new EnvironmentHelper();

        internal bool TryBool(string key, out bool value)
        {
            value = default;
            return TryVariable(key, out string variable) && TryParseBool(variable, out value);
        }

        private bool TryVariable(string key, out string variable)
        {
            variable = Environment.GetEnvironmentVariable(key);
            return variable != null;
        }

        private static bool TryParseBool(string variable, out bool value)
        {
            if (bool.TryParse(variable, out value))
                return true;

            if (int.TryParse(variable, out int ivalue))
            {
                value = ivalue > 0;
                return true;
            }
            return false;
        }
    }
}
