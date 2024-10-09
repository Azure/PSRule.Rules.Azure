// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Data.Template
{
#nullable enable

    internal sealed class ObjectDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
    {
        private Func<string>? _GetId;

        public ObjectDeploymentSymbol(string name, IResourceValue? resource)
            : base(name)
        {
            if (resource != null)
                Configure(resource);
        }

        public DeploymentSymbolKind Kind => DeploymentSymbolKind.Object;

        public void Configure(IResourceValue resource)
        {
            _GetId = () => resource.Id;
        }

        public string? GetId(int index)
        {
            return _GetId == null ? null : _GetId();
        }
    }

#nullable restore
}
