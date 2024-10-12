// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data
{
    public sealed class ProviderDataTests
    {
        [Fact]
        public void TryResourceType()
        {
            var providers = new ProviderData();
            Assert.True(providers.TryResourceType("Microsoft.Storage", "storageAccounts", out var type));
            Assert.NotNull(type);
        }

        [Fact]
        public void GetFromIndex()
        {
            var index = new ProviderData().GetIndex();
            Assert.NotNull(index);
            Assert.NotEmpty(index.Resources);
            Assert.True(index.Resources.TryGetValue("Microsoft.Storage/storageAccounts", out var entry));
            Assert.NotNull(entry);
        }
    }
}
