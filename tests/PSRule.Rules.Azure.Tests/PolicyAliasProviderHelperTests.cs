// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Data.Policy;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class PolicyAliasProviderHelperTests
    {
        [Fact]
        public void ResolvePolicyAliasPath()
        {
            var policyAliasProviderHelper = new PolicyAliasProviderHelper();

            // Invalid aliases
            policyAliasProviderHelper.ResolvePolicyAliasPath("InvalidAliasPath", out var test5);
            Assert.Null(test5);

            policyAliasProviderHelper.ResolvePolicyAliasPath("Microsoft.Compute/imageId", out var test3);
            Assert.Null(test3);

            // Valid aliases
            policyAliasProviderHelper.ResolvePolicyAliasPath("Microsoft.Storage/storageAccounts/minimumTlsVersion", out var test1);
            Assert.Equal("properties.minimumTlsVersion", test1);
            policyAliasProviderHelper.ResolvePolicyAliasPath("Microsoft.AAD/domainServices/deploymentId", out var test2);
            Assert.Equal("properties.deploymentId", test2);

            policyAliasProviderHelper.SetDefaultResourceType("Microsoft.Compute", "virtualMachines");
            policyAliasProviderHelper.ResolvePolicyAliasPath("Microsoft.Compute/imageId", out var test4);
            Assert.Equal("properties.storageProfile.imageReference.id", test4);
        }
    }
}
