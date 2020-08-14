// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using System;
using Xunit;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class ExpressionBuilderTests
    {
        [Fact]
        public void BuildExpression1()
        {
            var expression = "[parameters('vnetName')]";
            var context = GetContext();
            context.Parameter("vnetName", "vnet1");

            var actual = Build(context, expression);

            Assert.Equal("vnet1", actual);
        }

        [Fact]
        public void BuildExpression2()
        {
            var expression = "[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]";
            var context = GetContext();
            context.CopyIndex.Push(new TemplateContext.CopyIndexState() { Name = "routeIndex", Index = 0 });
            context.Parameter("subnets", JArray.Parse("[ { \"name\": \"subnet1\", \"route\": [ \"routeA\", \"routeB\" ] } ]"));

            var actual = Build(context, expression);

            Assert.Equal("route-subnet1", actual);
        }

        [Fact]
        public void BuildExpression4()
        {
            var expression = "[concat('route-', parameters('subnets')[0].route[1])]";
            var context = GetContext();
            context.Parameter("subnets", JArray.Parse("[ { \"name\": \"subnet1\", \"route\": [ \"routeA\", \"routeB\" ] } ]"));

            var actual = Build(context, expression);

            Assert.Equal("route-routeB", actual);
        }

        [Fact]
        public void BuildExpression5()
        {
            var expression = "['subnet1']";
            var actual = Build(GetContext(), expression);
            Assert.Equal("subnet1", actual);
        }

        [Fact]
        public void BuildExpression6()
        {
            var expression = "[variables('environments')['dev'].prefix[1]]";
            var context = GetContext();
            context.Variable("environments", JObject.Parse("{ \"test\": { \"prefix\": \"tst-\" }, \"dev\": { \"prefix\": [ \"d-\", \"dev-\" ] } }"));

            var actual = Build(context, expression) as JToken;
            Assert.Equal("dev-", actual.Value<string>());
        }

        [Fact]
        public void BuildExpressionWithNullProperty()
        {
            var context = GetContext();
            context.Variable("environments", JObject.Parse("{ }"));
            context.Variable("items", JArray.Parse("[ ]"));

            Assert.Throws<ExpressionReferenceException>(() => Build(context, "[variables('environments').prod]"));
            Assert.Throws<ExpressionReferenceException>(() => Build(context, "[variables('environments')['prod']]"));
            Assert.Throws<InvalidOperationException>(() => Build(context, "[variables('environments')[0]]"));
            Assert.Throws<ArgumentOutOfRangeException>(() => Build(context, "[variables('items')[0]]"));
        }

        private static object Build(TemplateContext context, string expression)
        {
            var builder = new ExpressionBuilder();
            var fn = builder.Build(expression);
            return fn(context);
        }

        private static TemplateContext GetContext()
        {
            return new TemplateContext();
        }
    }
}
