// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.IO;
using PSRule.Rules.Azure.Configuration;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class OptionsTests
    {
        [Fact]
        public void GetOptions()
        {
            var actual1 = PSRuleOption.FromFileOrDefault(null);
            var actual2 = PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule-options.yaml"));

            Assert.NotNull(actual1);
            Assert.Equal("PSRule Test Subscription", actual1.Configuration.Subscription.DisplayName);
            Assert.Null(actual1.Configuration.ResourceGroup.Tags);

            Assert.NotNull(actual2);
            Assert.Equal("Unit Test Subscription", actual2.Configuration.Subscription.DisplayName);
            Assert.Equal("prod", actual2.Configuration.ResourceGroup.Tags["env"]);
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

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }
    }
}
