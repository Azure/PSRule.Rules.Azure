// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Runtime;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class TokenStreamValidatorTests
    {
        [Fact]
        public void HasInsecureToken()
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
        public void HasValueFromSecureParameter()
        {
            Assert.True(Helper.HasValueFromSecureParameter("[parameters('adminPassword')]", new string[] { "adminPassword" }));
            Assert.True(Helper.HasValueFromSecureParameter("[parameters('adminPassword')]", new string[] { "AdminPassword" }));
            Assert.False(Helper.HasValueFromSecureParameter("[variables('adminPassword')]", new string[] { "adminPassword" }));
            Assert.False(Helper.HasValueFromSecureParameter("password", new string[] { "adminPassword" }));
            Assert.False(Helper.HasValueFromSecureParameter("[parameters('notSecure')]", new string[] { "adminPassword" }));
            Assert.False(Helper.HasValueFromSecureParameter("[parameters('notSecure')]", System.Array.Empty<string>()));
            Assert.True(Helper.HasValueFromSecureParameter("[if(true(), parameters('adminPassword2'), parameters('adminPassword1'))]", new string[] { "adminPassword1", "adminPassword2" }));
            Assert.False(Helper.HasValueFromSecureParameter("[if(true(), parameters('notSecure'), parameters('adminPassword1'))]", new string[] { "adminPassword1" }));
        }
    }
}
