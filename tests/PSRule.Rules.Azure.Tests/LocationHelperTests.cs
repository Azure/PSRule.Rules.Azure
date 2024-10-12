// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure;

public sealed class LocationHelperTests
{
    [Fact]
    public void Equal()
    {
        // True
        Assert.True(LocationHelper.Equal("Australia East", "Australia East"));
        Assert.True(LocationHelper.Equal("Australia East", "Australia east"));
        Assert.True(LocationHelper.Equal("Australia East", "australiaEast"));
        Assert.True(LocationHelper.Equal("Australia East", "australiaeast"));
        Assert.True(LocationHelper.Equal("australia East", "Australia East"));
        Assert.True(LocationHelper.Equal("Australiaeast", "Australia East"));
        Assert.True(LocationHelper.Equal("australiAEast", "Australia East"));
        Assert.True(LocationHelper.Equal("australiaeast", "Australia East"));
        Assert.True(LocationHelper.Equal("australiaeast", "australiaeast"));
        Assert.True(LocationHelper.Equal("australiaeast", "australiaeast "));
        Assert.True(LocationHelper.Equal("australiaeast ", "australiaeast"));

        // False
        Assert.False(LocationHelper.Equal("East US", "East US 2"));
        Assert.False(LocationHelper.Equal("East US", "eastus2"));
        Assert.False(LocationHelper.Equal("East US 2", "East US"));
        Assert.False(LocationHelper.Equal("eastus2", "East US"));
    }

    [Fact]
    public void Normalize()
    {
        Assert.Equal("australiaeast", LocationHelper.Normalize("Australia East"));
        Assert.Equal("australiaeast", LocationHelper.Normalize("australia East"));
        Assert.Equal("australiaeast", LocationHelper.Normalize("AustraliaEast"));
        Assert.Equal("australiaeast", LocationHelper.Normalize("australiaeast"));
        Assert.Equal("australiaeast", LocationHelper.Normalize(" Australia East "));
    }

    [Fact]
    public void ComparerHashCode()
    {
        var comparer = new LocationHelper();

        Assert.Equal(comparer.GetHashCode("Australia East"), comparer.GetHashCode("Australia East"));
        Assert.Equal(comparer.GetHashCode("Australia East"), comparer.GetHashCode("Australia east"));
        Assert.Equal(comparer.GetHashCode("Australia East"), comparer.GetHashCode("australiaEast"));
        Assert.Equal(comparer.GetHashCode("Australia East"), comparer.GetHashCode("australiaeast"));
        Assert.Equal(comparer.GetHashCode("australia East"), comparer.GetHashCode("Australia East"));
        Assert.Equal(comparer.GetHashCode("Australiaeast"), comparer.GetHashCode("Australia East"));
        Assert.Equal(comparer.GetHashCode("australiAEast"), comparer.GetHashCode("Australia East"));
        Assert.Equal(comparer.GetHashCode("australiaeast"), comparer.GetHashCode("Australia East"));
        Assert.Equal(comparer.GetHashCode("australiaeast"), comparer.GetHashCode("australiaeast"));
        Assert.Equal(comparer.GetHashCode("australiaeast"), comparer.GetHashCode("australiaeast "));
        Assert.Equal(comparer.GetHashCode("australiaeast "), comparer.GetHashCode("australiaeast"));

        // Compare against string
        Assert.Equal("australiaeast".GetHashCode(), comparer.GetHashCode("australiaeast"));
    }
}
