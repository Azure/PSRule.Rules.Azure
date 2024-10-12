// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.IO;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure
{
    public sealed class OptionsTests
    {
        [Fact]
        public void GetOptions()
        {
            var actual = PSRuleOption.FromFileOrDefault("not-a-file.yaml");
            Assert.NotNull(actual);
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Configuration.Subscription.SubscriptionId);
            Assert.Equal("PSRule Test Subscription", actual.Configuration.Subscription.DisplayName);
            Assert.Null(actual.Configuration.ResourceGroup.Tags);
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Configuration.Tenant.TenantId);
            Assert.Equal("PSRule", actual.Configuration.Tenant.DisplayName);
            Assert.Equal("US", actual.Configuration.Tenant.CountryCode);
            Assert.Equal("psrule-test", actual.Configuration.ManagementGroup.Name);
            Assert.Equal("PSRule Test Management Group", actual.Configuration.ManagementGroup.Properties.DisplayName);
            Assert.Equal("Azure", actual.Configuration.PolicyRulePrefix);

            actual = PSRuleOption.FromFileOrDefault("test-template-options.yaml");
            Assert.NotNull(actual);
            Assert.True(PSRuleOption.Default.Configuration.Equals(actual.Configuration));

            actual = PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule-options.yaml"));
            Assert.NotNull(actual);
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Configuration.Subscription.SubscriptionId);
            Assert.Equal("Unit Test Subscription", actual.Configuration.Subscription.DisplayName);
            Assert.Equal("prod", actual.Configuration.ResourceGroup.Tags["env"]);
            Assert.Equal("11111111-1111-1111-1111-111111111111", actual.Configuration.Tenant.TenantId);
            Assert.Equal("Unit Test Tenant", actual.Configuration.Tenant.DisplayName);
            Assert.Equal("AU", actual.Configuration.Tenant.CountryCode);
            Assert.Equal("unit-test-mg", actual.Configuration.ManagementGroup.Name);
            Assert.Equal("My test management group", actual.Configuration.ManagementGroup.Properties.DisplayName);
            Assert.Equal("deployment-from-yaml", actual.Configuration.Deployment.Name);
            Assert.Equal("AzureCustomPrefix", actual.Configuration.PolicyRulePrefix);
        }

        [Fact]
        public void SubscriptionOption()
        {
            var hashtable = new Hashtable
            {
                ["SubscriptionId"] = "00000000-0000-0000-0000-000000000000",
                ["DisplayName"] = "Subscription option unit tests",
                ["TenantId"] = "Test tenant",
                ["State"] = "Test state"
            };

            var option = SubscriptionReference.FromHashtable(hashtable).ToSubscriptionOption();
            Assert.NotNull(option);
            Assert.Equal(hashtable["SubscriptionId"], option.SubscriptionId);
            Assert.Equal(hashtable["DisplayName"], option.DisplayName);
            Assert.Equal(hashtable["TenantId"], option.TenantId);
            Assert.Equal(hashtable["State"], option.State);
        }

        [Fact]
        public void ResourceGroupOption()
        {
            var hashtable = new Hashtable
            {
                ["Name"] = "RG option unit tests",
                ["Location"] = "westus",
                ["ManagedBy"] = "Test managed by"
            };
            var tags = new Hashtable
            {
                ["env"] = "prod"
            };
            hashtable["Tags"] = tags;
            hashtable["ProvisioningState"] = "Test";

            var option = ResourceGroupReference.FromHashtable(hashtable).ToResourceGroupOption();
            Assert.NotNull(option);
            Assert.Equal(hashtable["Name"], option.Name);
            Assert.Equal(hashtable["Location"], option.Location);
            Assert.Equal(hashtable["ManagedBy"], option.ManagedBy);
            Assert.Equal(tags["env"], option.Tags["env"]);
            Assert.Equal(hashtable["ProvisioningState"], option.Properties.ProvisioningState);
        }

        [Fact]
        public void DeploymentOption()
        {
            var hashtable = new Hashtable
            {
                ["Name"] = "option-test-deployment",
            };

            var option = DeploymentReference.FromHashtable(hashtable).ToDeploymentOption();
            Assert.NotNull(option);
            Assert.Equal(hashtable["Name"], option.Name);
        }

        #region Helper methods

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        #endregion Helper methods
    }
}
