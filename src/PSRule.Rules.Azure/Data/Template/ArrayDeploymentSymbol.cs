// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class ArrayDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
    {
        private List<ResourceValue> _Resources;

        public ArrayDeploymentSymbol(string name)
            : base(name) { }

        public DeploymentSymbolKind Kind => DeploymentSymbolKind.Array;

        public void Configure(ResourceValue resource)
        {
            _Resources ??= new List<ResourceValue>();
            _Resources.Add(resource);
        }

        public string GetId(int index)
        {
            return _Resources[index].Id;
        }
    }
}
