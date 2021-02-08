// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Runtime;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class RuntimeHelperTests
    {
        [Fact]
        public void CompressExpression()
        {
            Assert.Equal("not an expression", Helper.CompressExpression("not an expression"));
            Assert.Equal("[[not an expression]", Helper.CompressExpression("[[not an expression]"));
            Assert.Equal("[null()]", Helper.CompressExpression("[null()]"));
            Assert.Equal("[parameters('vnetName')]", Helper.CompressExpression("[parameters( 'vnetName' )]"));
            Assert.Equal("[resourceGroup().location]", Helper.CompressExpression("[ resourceGroup( ).location ]"));
            Assert.Equal("[parameters('shares')[copyIndex()].name]", Helper.CompressExpression("[ parameters( 'shares')[ copyIndex()].name]"));
            Assert.Equal("[concat('route-',parameters('subnets')[copyIndex('routeIndex')].name)]", Helper.CompressExpression("[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]"));
            Assert.Equal("[concat(split(parameters('addressPrefix')[0],'/')[0],'/27')]", Helper.CompressExpression("[concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]"));
        }

        [Fact]
        public void IsTemplateExpression()
        {
            Assert.False(Helper.IsTemplateExpression("not an expression"));
            Assert.False(Helper.IsTemplateExpression("[[not an expression]"));
            Assert.True(Helper.IsTemplateExpression("[null()]"));
            Assert.True(Helper.IsTemplateExpression("[parameters( 'vnetName' )]"));
            Assert.True(Helper.IsTemplateExpression("[ resourceGroup( ).location ]"));
            Assert.True(Helper.IsTemplateExpression("[ parameters( 'shares')[ copyIndex()].name]"));
            Assert.True(Helper.IsTemplateExpression("[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]"));
            Assert.True(Helper.IsTemplateExpression("[concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]"));
        }
    }
}
