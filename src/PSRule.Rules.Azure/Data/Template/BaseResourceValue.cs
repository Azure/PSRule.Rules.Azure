// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    internal abstract class BaseResourceValue
    {
        protected BaseResourceValue(string id, string name, string symbolicName)
        {
            Id = id;
            Name = name;
            SymbolicName = symbolicName;
        }

        /// <inheritdoc/>
        public string Id { get; }

        /// <inheritdoc/>
        public string Name { get; }

        /// <inheritdoc/>
        public string SymbolicName { get; }
    }
}
