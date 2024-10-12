// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure;

/// <summary>
/// Tests for <see cref="CustomTypeTopologyGraph"/>.
/// </summary>
public sealed class CustomTypeTopologyGraphTests
{
    [Fact]
    public void Sort_custom_type_graph()
    {
        var graph = new CustomTypeTopologyGraph();
        graph.Add("base", GetObject());
        graph.Add("nestedComplexType", GetObject("complexType"));
        graph.Add("basicType", GetObject("object"));
        graph.Add("object", GetObject());
        graph.Add("array", GetObject("object"));
        graph.Add("complexType", GetObject("array"));
        graph.Add("newBase", GetObject());

        var result = graph.GetOrdered().ToArray();
        Assert.NotEmpty(result);

        Assert.Equal("#/definitions/base", result[0].Key);
        Assert.Equal("#/definitions/object", result[1].Key);
        Assert.Equal("#/definitions/array", result[2].Key);
        Assert.Equal("#/definitions/complexType", result[3].Key);
        Assert.Equal("#/definitions/nestedComplexType", result[4].Key);
        Assert.Equal("#/definitions/basicType", result[5].Key);
        Assert.Equal("#/definitions/newBase", result[6].Key);
    }

    #region Helper methods

    private static JObject GetObject(string ancestor = null)
    {
        return ancestor == null ? new JObject() : JObject.Parse(string.Concat("{ \"$ref\": \"#/definitions/", ancestor, "\"}"));
    }

    #endregion Helper methods
}
