// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Data;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class PolicyIgnoreDataTests
    {
        [Fact]
        public void PolicyIgnoreData_contains_expected_values()
        {
            var data = GetIndex();

            Assert.True(data.TryGetValue("/providers/Microsoft.Authorization/policyDefinitions/79fdfe03-ffcb-4e55-b4d0-b925b8241759", out var entry));
            Assert.Equal(PolicyIgnoreReason.Duplicate, entry.Reason);
            Assert.Contains("Azure.ACR.AdminUser", entry.Value);

            Assert.True(data.TryGetValue("/providers/Microsoft.Authorization/policyDefinitions/b6e2945c-0b7b-40f5-9233-7a5323b5cdc6", out entry));
            Assert.Equal(PolicyIgnoreReason.NotApplicable, entry.Reason);

            Assert.True(data.TryGetValue("/providers/Microsoft.Authorization/policyDefinitions/640d2586-54d2-465f-877f-9ffc1d2109f4", out entry));
            Assert.Equal(PolicyIgnoreReason.Duplicate, entry.Reason);
            Assert.Contains("Azure.Defender.Storage.MalwareScan", entry.Value);
            Assert.Contains("Azure.Defender.Storage", entry.Value);
            Assert.Contains("Azure.Defender.Storage.SensitiveData", entry.Value);

            Assert.True(data.TryGetValue("/providers/Microsoft.Authorization/policyDefinitions/cfdc5972-75b3-4418-8ae1-7f5c36839390", out entry));
            Assert.Equal(PolicyIgnoreReason.Duplicate, entry.Reason);
            Assert.Contains("Azure.Defender.Storage.MalwareScan", entry.Value);
            Assert.Contains("Azure.Defender.Storage", entry.Value);
            Assert.Contains("Azure.Defender.Storage.SensitiveData", entry.Value);
        }

        #region Helper methods

        private static Dictionary<string, PolicyIgnoreResult> GetIndex()
        {
            return new PolicyIgnoreData().GetIndex();
        }

        #endregion Helper methods
    }
}
