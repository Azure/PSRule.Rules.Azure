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
    }
}
