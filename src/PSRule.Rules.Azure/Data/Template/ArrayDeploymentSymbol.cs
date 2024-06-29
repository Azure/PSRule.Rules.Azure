// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class ArrayDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
    {
        private List<string> _Ids;

        public ArrayDeploymentSymbol(string name)
            : base(name) { }

        public DeploymentSymbolKind Kind => DeploymentSymbolKind.Array;

        public void Configure(ResourceValue resource)
        {
            _Ids ??= new List<string>();
            _Ids.Add(resource.Id);
        }

        public string GetId(int index)
        {
            return _Ids[index];
        }

        public string[] GetIds()
        {
            return _Ids?.ToArray() ?? Array.Empty<string>();
        }
    }
}
