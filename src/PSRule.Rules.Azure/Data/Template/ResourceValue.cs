// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json.Linq;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    [DebuggerDisplay("{Id}")]
    internal sealed class ResourceValue : BaseResourceValue, IResourceValue
    {
        internal ResourceValue(string id, string name, string type, string symbolicName, JObject value, TemplateContext.CopyIndexState copy)
            : base(id, name, symbolicName)
        {
            Type = type;
            Value = value;
            Copy = copy;
        }

        /// <inheritdoc/>
        public string Type { get; }

        /// <inheritdoc/>
        public JObject Value { get; }

        /// <inheritdoc/>
        public TemplateContext.CopyIndexState Copy { get; }
    }
}
