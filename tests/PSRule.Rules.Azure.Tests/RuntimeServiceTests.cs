// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using System.Management.Automation;
using PSRule.Rules.Azure.Runtime;

namespace PSRule.Rules.Azure;

public sealed class RuntimeServiceTests
{
    [Fact]
    public void ToPSRuleOption_WhenNotSet_ShouldUseDefaults()
    {
        // Arrange
        var runtime = GetRuntimeService();

        // Act
        var actual = runtime.ToPSRuleOption();

        // Assert
        Assert.NotNull(actual.Configuration);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Configuration.Subscription.SubscriptionId);
        Assert.Equal("ps-rule-test-rg", actual.Configuration.ResourceGroup.Name);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Configuration.Tenant.TenantId);
        Assert.Equal("ps-rule-test-deployment", actual.Configuration.Deployment.Name);
        Assert.Equal("Azure", actual.Configuration.PolicyRulePrefix);
        Assert.Equal("0.4.451", actual.Configuration.BicepMinimumVersion);
        Assert.Equal(5, actual.Configuration.BicepFileExpansionTimeout);
    }

    [Fact]
    public void WithAzureSubscription_WhenValid_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var pso = new PSObject();
        pso.Properties.Add(new PSNoteProperty("subscriptionId", "value1"));

        // Act
        runtime.WithAzureSubscription(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.Equal("value1", actual.Configuration.Subscription.SubscriptionId);
    }

    [Fact]
    public void WithAzureResourceGroup_WhenValid_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var pso = new PSObject();
        pso.Properties.Add(new PSNoteProperty("name", "value1"));

        // Act
        runtime.WithAzureResourceGroup(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.Equal("value1", actual.Configuration.ResourceGroup.Name);
    }

    [Fact]
    public void WithAzureTenant_WhenValid_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var pso = new PSObject();
        pso.Properties.Add(new PSNoteProperty("tenantId", "value1"));

        // Act
        runtime.WithAzureTenant(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.Equal("value1", actual.Configuration.Tenant.TenantId);
    }

    [Fact]
    public void WithAzureDeployment_WhenValid_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var pso = new PSObject();
        pso.Properties.Add(new PSNoteProperty("name", "value1"));

        // Act
        runtime.WithAzureDeployment(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.Equal("value1", actual.Configuration.Deployment.Name);
    }

    [Fact]
    public void WithParameterDefaults_WhenValidPSObject_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var pso = new PSObject();
        pso.Properties.Add(new PSNoteProperty("value1", "1"));
        pso.Properties.Add(new PSNoteProperty("value2", "2"));

        // Act
        runtime.WithParameterDefaults(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.True(actual.Configuration.ParameterDefaults.TryGetString("value1", out string value1));
        Assert.Equal("1", value1);
        Assert.True(actual.Configuration.ParameterDefaults.TryGetString("value2", out string value2));
        Assert.Equal("2", value2);
    }

    [Fact]
    public void WithParameterDefaults_WhenValidHashtable_ShouldSetOptions()
    {
        var runtime = GetRuntimeService();
        var hashtable = new Hashtable
        {
            ["value1"] = "1",
            ["value2"] = "2"
        };

        var pso = new PSObject(hashtable);

        // Act
        runtime.WithParameterDefaults(pso);

        // Assert
        var actual = runtime.ToPSRuleOption();
        Assert.True(actual.Configuration.ParameterDefaults.TryGetString("value1", out string value1));
        Assert.Equal("1", value1);
        Assert.True(actual.Configuration.ParameterDefaults.TryGetString("value2", out string value2));
        Assert.Equal("2", value2);
    }

    #region Helper methods

    private static RuntimeService GetRuntimeService()
    {
        // Arrange
        return new RuntimeService("0.4.451", 5);
    }

    #endregion Helper methods
}
