// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
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

        internal static bool GetPath(this PSObject sourceObject, out string path)
        {
            path = null;
            if (sourceObject.BaseObject is string s)
            {
                path = s;
                return true;
            }
            if (sourceObject.BaseObject is FileInfo info && info.Extension == ".json")
            {
                path = info.FullName;
                return true;
            }
            return false;
        }
    }
}
