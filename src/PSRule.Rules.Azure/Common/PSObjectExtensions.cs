// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure
{
    internal static class PSObjectExtensions
    {
        internal static T GetPropertyValue<T>(this PSObject obj, string propertyName)
        {
            return (T)obj.Properties[propertyName].Value;
        }
    }
}
