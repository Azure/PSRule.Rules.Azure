// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Arm.Deployments;

/// <summary>
/// A graph that tracks dependencies between type definitions.
/// </summary>
internal sealed class CustomTypeTopologyGraph
{
    private const string PROPERTY_REF = "$ref";

    private readonly Dictionary<string, Node> _ById = new(StringComparer.OrdinalIgnoreCase);

    [DebuggerDisplay("{Id}")]
    private sealed class Node(string id, JObject value)
    {
        internal readonly string Id = id;
        internal readonly JObject Value = value;

        /// <summary>
        /// The color of the node in the graph.
        /// 0 = white, 1 = gray, 2 = black.
        /// </summary>
        internal int Color = 0;
    }

    /// <summary>
    /// Add a custom type to the graph.
    /// </summary>
    /// <param name="name">The custom type node to add to the graph.</param>
    /// <param name="value">The definition of the custom type.</param>
    internal void Add(string name, JObject value)
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
    internal KeyValuePair<string, JObject>[] GetOrdered()
    {
        var result = new List<KeyValuePair<string, JObject>>(_ById.Values.Count);
        foreach (var item in _ById.Values)
        {
            Visit(item, result);
        }
        return [.. result];
    }

    private bool TryGet(string id, out Node item)
    {
        return _ById.TryGetValue(id, out item);
    }

    /// <summary>
    /// Traverse a node and parent type.
    /// </summary>
    private void Visit(Node item, List<KeyValuePair<string, JObject>> result)
    {
        if (item.Color != 0)
            return;

        item.Color = 1;
        if (item.Value.TryStringProperty(PROPERTY_REF, out var id) && TryGet(id, out var parent))
        {
            Visit(parent, result);
        }
        item.Color = 2;
        result.Add(new KeyValuePair<string, JObject>(item.Id, item.Value));
    }
}
