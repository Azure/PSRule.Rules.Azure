// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A graph that tracks resource dependencies in scope of a deployment.
    /// </summary>
    internal sealed class ResourceDependencyGraph
    {
        private readonly Dictionary<string, Node> _ById = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, Node> _ByName = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, Node> _BySymbolicName = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, List<Node>> _ByCopyName = new(StringComparer.OrdinalIgnoreCase);

        [DebuggerDisplay("{Resource.Id}")]
        private sealed class Node
        {
            internal readonly IResourceValue Resource;
            internal readonly string[] Dependencies;

            public Node(IResourceValue resource, string[] dependencies)
            {
                Resource = resource;
                Dependencies = dependencies;
            }
        }

        /// <summary>
        /// Sort the provided resources based on dependency graph.
        /// </summary>
        /// <param name="resources">The resources to sort.</param>
        /// <returns>An ordered set of resources.</returns>
        internal IResourceValue[] Sort(IResourceValue[] resources)
        {
            if (resources == null || resources.Length <= 1)
                return resources;

            var stack = new List<IResourceValue>(resources.Length);
            var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var resource in resources)
            {
                if (TryGet(resource.Id, out var item))
                {
                    Visit(item, visited, stack);
                }
                else
                {
                    stack.Add(resource);
                    visited.Add(resource.Id);
                }
            }
            return stack.ToArray();
        }

        /// <summary>
        /// Add a resource to the graph.
        /// </summary>
        /// <param name="resource">The resource node to add to the graph.</param>
        /// <param name="dependencies">Any dependencies for the node.</param>
        internal void Track(IResourceValue resource, string[] dependencies)
        {
            if (resource == null)
                return;

            var item = new Node(resource, dependencies);
            _ById[resource.Id] = item;
            _ByName[resource.Name] = item;

            if (!string.IsNullOrEmpty(resource.SymbolicName))
                _BySymbolicName[resource.SymbolicName] = item;

            if (resource.Copy != null && !string.IsNullOrEmpty(resource.Copy.Name))
            {
                if (!_ByCopyName.TryGetValue(resource.Copy.Name, out var copyItems))
                {
                    copyItems = new List<Node>();
                    _ByCopyName[resource.Copy.Name] = copyItems;
                }
                copyItems.Add(item);
            }
        }

        private bool TryGet(string key, out Node item)
        {
            return _ById.TryGetValue(key, out item) ||
                _ByName.TryGetValue(key, out item) ||
                _BySymbolicName.TryGetValue(key, out item);
        }

        /// <summary>
        /// Traverse a node and dependencies.
        /// </summary>
        private void Visit(Node source, HashSet<string> visited, List<IResourceValue> stack)
        {
            if (visited.Contains(source.Resource.Id))
                return;

            visited.Add(source.Resource.Id);
            for (var i = 0; source.Dependencies != null && i < source.Dependencies.Length; i++)
            {
                if (TryGet(source.Dependencies[i], out var item))
                {
                    Visit(item, visited, stack);
                }
                else if (_ByCopyName.TryGetValue(source.Dependencies[i], out var countItems))
                {
                    foreach (var countItem in countItems)
                        Visit(countItem, visited, stack);
                }
            }
            stack.Add(source.Resource);
        }
    }
}
