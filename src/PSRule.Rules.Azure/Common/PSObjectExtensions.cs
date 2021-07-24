// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure
{
    internal static class PSObjectExtensions
    {
        internal static T GetPropertyValue<T>(this PSObject obj, string propertyName)
        {
            return (T)obj.Properties[propertyName]?.Value;
        }

        public static bool TryProperty<T>(this PSObject o, string name, out T value)
        {
            value = default;
            if (o.Properties[name]?.Value is T tValue)
            {
                value = tValue;
                return true;
            }
            return false;
        }
    }
}
