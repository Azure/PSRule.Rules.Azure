// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class ObjectDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
    {
        private string _ResourceId;

        public ObjectDeploymentSymbol(string name, ResourceValue resource)
            : base(name)
        {
            if (resource != null)
                Configure(resource);
        }

        public DeploymentSymbolKind Kind => DeploymentSymbolKind.Object;

        public void Configure(ResourceValue resource)
        {
            _ResourceId = resource.Id;
        }

        public string GetId(int index)
        {
            return _ResourceId;
        }
    }
}
