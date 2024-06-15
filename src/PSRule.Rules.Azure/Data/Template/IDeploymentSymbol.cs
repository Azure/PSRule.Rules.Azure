// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface IDeploymentSymbol
    {
        string Name { get; }

        DeploymentSymbolKind Kind { get; }

        void Configure(ResourceValue r);

        string GetId(int index);
    }
}
