// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// Build and cache descriptors for functions that are implemented in the Azure Resource Manager (ARM) template language.
    /// </summary>
    internal sealed class ExpressionFactory
    {
        private const string TOKEN_LIST = "list";

        private readonly Dictionary<string, IFunctionDescriptor> _Descriptors;

        public ExpressionFactory(bool policy = false)
        {
            _Descriptors = new Dictionary<string, IFunctionDescriptor>(StringComparer.OrdinalIgnoreCase);
            foreach (var d in Functions.Common)
                With(d);

            // Azure policy specific functions should be added
            if (policy)
            {
                foreach (var d in Functions.Policy)
                    With(d);
            }
        }

        /// <summary>
        /// Try to get a descriptor for a function by name.
        /// </summary>
        /// <param name="name">The name of the ARM function.</param>
        /// <param name="descriptor">A matching descriptor for the function implementation.</param>
        /// <returns>Return <c>true</c> when the function is known. Otherwise <c>false</c> is returned.</returns>
        public bool TryDescriptor(string name, out IFunctionDescriptor descriptor)
        {
            return IsList(name) ? _Descriptors.TryGetValue(TOKEN_LIST, out descriptor) : _Descriptors.TryGetValue(name, out descriptor);
        }

        /// <summary>
        /// Add a function to the factory.
        /// This is called internally to load built-in functions, but also when user-defined functions are loaded.
        /// </summary>
        public void With(IFunctionDescriptor descriptor)
        {
            _Descriptors.Add(descriptor.Name, descriptor);
        }

        private static bool IsList(string name)
        {
            return name.StartsWith(TOKEN_LIST, StringComparison.OrdinalIgnoreCase);
        }
    }
}
