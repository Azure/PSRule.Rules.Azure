// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Data.Template
{
    internal static class ResourceValueExtensions
    {
        private const string PROPERTY_EXISTING = "existing";

        public static bool DependsOn(this IResourceValue resource, IResourceValue other)
        {
            return resource.DependsOn(other);
        }

        public static bool IsType(this IResourceValue resource, string type)
        {
            return string.Equals(resource.Type, type, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Determines if the resource is flagged as an existing reference.
        /// </summary>
        public static bool IsExisting(this IResourceValue resource)
        {
            return resource.Value.TryBoolProperty(PROPERTY_EXISTING, out var existing) && existing.HasValue && existing.Value;
        }

        internal static bool TryOutput<TValue>(this DeploymentValue resource, string name, out TValue value)
        {
            value = default;
            if (resource.TryOutput(name, out var o) && o is TValue v)
            {
                value = v;
                return true;
            }
            return false;
        }
    }
}
