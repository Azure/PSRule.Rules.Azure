// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure;

/// <summary>
/// Unit tests for <see cref="JsonExtensions"/>.
/// </summary>
public sealed class JsonExtensionsTests
{
    [Fact]
    public void AddIfNotExists_WithNewProperty_ShouldAdd()
    {
        var json = new JObject
        {
            { "existing", "value" }
        };

        json.AddIfNotExists("new", "value");

        Assert.Equal("value", json["existing"]);
        Assert.Equal("value", json["new"]);
        Assert.Equal(2, json.Count);
    }

    [Fact]
    public void AddIfNotExists_WithExistingProperty_ShouldNotAdd()
    {
        var json = new JObject
        {
            { "existing", "value" }
        };

        json.AddIfNotExists("existing", "value");

        Assert.Equal("value", json["existing"]);
        Assert.Single(json);
    }
}
