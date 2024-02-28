// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Resources;
using System.Text;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A graph that tracks dependencies between type definitions.
    /// </summary>
    internal sealed class CustomTypeDependencyGraph
    {
        private readonly Dictionary<string, Node> _ById = new(StringComparer.OrdinalIgnoreCase);

        [DebuggerDisplay("{Resource.Id}")]
        private sealed class Node
        {
            internal readonly string Id;
            internal readonly JObject Value;

            public Node(string id, JObject value)
            {
                Id = id;
                Value = value;
            }
        }

        /// <summary>
        /// Add a custom type to the graph.
        /// </summary>
        /// <param name="name">The custom type node to add to the graph.</param>
        /// <param name="value">The definition of the custom type.</param>
        internal void Track(string name, JObject value)
        {
            if (value == null)
                return;

            var id = $"#/definitions/{name}";
            var item = new Node(id, value);
            _ById[id] = item;
        }

        /// <summary>
        /// Get a list of ordered custom types.
        /// </summary>
        internal IEnumerable<KeyValuePair<string, JObject>> GetOrdered()
        {
            var stack = new List<KeyValuePair<string, JObject>>(_ById.Values.Count);
            var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var item in _ById.Values)
            {
                Visit(item, visited, stack);
            }
            return stack.ToArray();
        }

        private bool TryGet(string id, out Node item)
        {
            return _ById.TryGetValue(id, out item);
        }

        /// <summary>
        /// Traverse a node and parent type.
        /// </summary>
        private void Visit(Node item, HashSet<string> visited, List<KeyValuePair<string, JObject>> stack)
        {
            if (visited.Contains(item.Id))
                return;

            visited.Add(item.Id);
            if (item.Value.TryStringProperty("$ref", out var id) && TryGet(id, out var parent))
            {
                Visit(parent, visited, stack);
            }
            stack.Add(new KeyValuePair<string, JObject>(item.Id, item.Value));
        }
    }
}
