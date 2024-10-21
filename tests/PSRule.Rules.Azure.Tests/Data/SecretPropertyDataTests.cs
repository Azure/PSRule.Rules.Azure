// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data;

public sealed class SecretPropertyDataTests
{
    private readonly SecretPropertyData _Data;

    public SecretPropertyDataTests()
    {
        _Data = new SecretPropertyData();
    }

    [Theory]
    [InlineData("Microsoft.KeyVault/vaults/secrets", new string[] { "properties.value" })]
    [InlineData("Microsoft.Resources/deploymentScripts", new string[] { "properties.storageAccountSettings.storageAccountKey", "properties.environmentVariables[*].secureValue" })]
    [InlineData("Microsoft.App/containerApps", new string[] { "properties.configuration.secrets[*].value" })]
    public void GetSecretProperty(string resourceType, string[] path)
    {
        Assert.True(_Data.TryGetValue(resourceType, out var properties));
        Assert.Equal(path, properties);
    }
}
