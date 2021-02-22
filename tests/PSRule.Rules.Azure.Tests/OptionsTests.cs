// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;
using System;
using System.Collections;
using System.IO;
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

            Assert.NotNull(actual2);
            Assert.Equal("Unit Test Subscription", actual2.Configuration.Subscription.DisplayName);
        }

        [Fact]
        public void SubscriptionOption()
        {
            var hashtable = new Hashtable();
            hashtable["SubscriptionId"] = "00000000-0000-0000-0000-000000000000";
            hashtable["DisplayName"] = "Subscription option unit tests";
            hashtable["TenantId"] = "Test tenant";
            hashtable["State"] = "Test state";

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
            var hashtable = new Hashtable();
            hashtable["Name"] = "RG option unit tests";
            hashtable["Location"] = "westus";
            hashtable["ManagedBy"] = "Test managed by";
            var tags = new Hashtable();
            tags["env"] = "prod";
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
