// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class ExpressionHelpersTests
    {
        [Fact]
        public void TryArray()
        {
            Assert.True(ExpressionHelpers.TryArray(JToken.Parse("[ 1, 2, 3 ]"), out _));
            Assert.True(ExpressionHelpers.TryArray(new JArray(1, 2, 3), out _));
            Assert.True(ExpressionHelpers.TryArray(new int[] { 1, 2, 3 }, out _));
        }
    }
}
