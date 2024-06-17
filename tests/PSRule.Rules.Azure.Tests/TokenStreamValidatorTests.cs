// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Runtime;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class TokenStreamValidatorTests
    {
        [Fact]
        public void HasLiteralValue()
        {
            Assert.True(Helper.HasLiteralValue("password"));
            Assert.True(Helper.HasLiteralValue("123"));
            Assert.False(Helper.HasLiteralValue("[parameters('adminPassword')]"));
            Assert.True(Helper.HasLiteralValue("[variables('password')]"));
            Assert.True(Helper.HasLiteralValue("[if(true(), variables('password'), parameters('password'))]"));
            Assert.True(Helper.HasLiteralValue("[if(true(), 'password', parameters('password'))]"));
            Assert.False(Helper.HasLiteralValue("[if(and(empty(parameters('sqlLogin')),parameters('useAADOnlyAuthentication')),null(),parameters('sqlLogin'))]"));
        }

        [Fact]
        public void GetParameterTokenValue()
        {
            Assert.Equal(new string[] { "adminPassword" }, Helper.GetParameterTokenValue("[parameters('adminPassword')]"));
            Assert.Empty(Helper.GetParameterTokenValue("[variables('adminPassword')]"));
            Assert.Empty(Helper.GetParameterTokenValue("password"));
            Assert.Equal(new string[] { "adminPassword" }, Helper.GetParameterTokenValue("[if(true(), null(), parameters('adminPassword'))]"));
            Assert.Equal(new string[] { "adminPassword2", "adminPassword1" }, Helper.GetParameterTokenValue("[if(true(), parameters('adminPassword2'), parameters('adminPassword1'))]"));
        }

        [Fact]
        public void UsesListKeysFunction()
        {
            Assert.True(Helper.UsesListKeysFunction("[listKeys(resourceId('Microsoft.Storage/storageAccounts', 'storage1'), '2021-09-01').keys[0].value]"));
            Assert.True(Helper.UsesListKeysFunction("[listKeys(resourceId('Microsoft.Storage/storageAccounts', 'storage1'), '2021-09-01')]"));
            Assert.True(Helper.UsesListKeysFunction("[listAdminKeys(resourceId('Microsoft.Search/searchServices', 'search1'), '2022-09-01').primaryKey]"));
            Assert.True(Helper.UsesListKeysFunction("[listQueryKeys(resourceId('Microsoft.Search/searchServices', 'search1'), '2021-09-01').value[0].key]"));
            Assert.False(Helper.UsesListKeysFunction("[list(resourceId('Microsoft.OperationalInsights/workspaces', 'workspace1'), '2023-09-01').value[0].properties.name]"));
            Assert.False(Helper.UsesListKeysFunction("[resourceId('Microsoft.Storage/storageAccounts', 'storage1')]"));
        }

        [Fact]
        public void HasSecureValue()
        {
            var secureParameters = new string[] { "adminPassword" };

            Assert.True(Helper.HasSecureValue("[parameters('adminPassword')]", secureParameters));
            Assert.True(Helper.HasSecureValue("[parameters('adminPassword')]", new string[] { "AdminPassword" }));
            Assert.False(Helper.HasSecureValue("[variables('adminPassword')]", secureParameters));
            Assert.False(Helper.HasSecureValue("password", secureParameters));
            Assert.False(Helper.HasSecureValue("[parameters('notSecure')]", secureParameters));
            Assert.False(Helper.HasSecureValue("[parameters('notSecure')]", System.Array.Empty<string>()));
            Assert.True(Helper.HasSecureValue("[if(true(), parameters('adminPassword2'), parameters('adminPassword1'))]", new string[] { "adminPassword1", "adminPassword2" }));
            Assert.False(Helper.HasSecureValue("[if(true(), parameters('notSecure'), parameters('adminPassword'))]", secureParameters));
            Assert.True(Helper.HasSecureValue("[listKeys(resourceId('Microsoft.Storage/storageAccounts', 'aStorageAccount'), '2021-09-01').keys[0].value]", secureParameters));
            Assert.True(Helper.HasSecureValue("{{SecretReference aName}}", secureParameters));
            Assert.True(Helper.HasSecureValue("[reference(resourceId('Microsoft.Insights/components', parameters('appInsightsName')), '2020-02-02').InstrumentationKey]", secureParameters));
        }
    }
}
