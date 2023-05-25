// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Template
{
    internal enum DeploymentSymbolKind
    {
        None = 0,
        Array = 1,
        Object = 2,
    }

    internal interface IDeploymentSymbol
    {
        string Name { get; }

        DeploymentSymbolKind Kind { get; }

        void Configure(ResourceValue r);

        string GetId(int index);
    }

    internal abstract class DeploymentSymbol
    {
        protected DeploymentSymbol(string name)
        {
            Name = name;
        }

        public string Name { get; }

        internal static IDeploymentSymbol NewArray(string name)
        {
            return name == null ? null : new ArrayDeploymentSymbol(name);
        }

        internal static IDeploymentSymbol NewObject(string name)
        {
            return name == null ? null : new ObjectDeploymentSymbol(name);
        }
    }

    internal sealed class ObjectDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
    {
        private ResourceValue _Resource;

        public ObjectDeploymentSymbol(string name)
            : base(name) { }

        public DeploymentSymbolKind Kind => DeploymentSymbolKind.Object;

        public void Configure(ResourceValue resource)
        {
            _Resource = resource;
        }

        public string GetId(int index)
        {
            return _Resource.Id;
        }
    }

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
