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
        public void BuildExpression7()
        {
            var expression = "[toUpper(first(variables('environment')))]";
            var context = GetContext();
            context.Variable("environment", "Test");

            var actual = Build(context, expression) as string;
            Assert.Equal("T", actual);
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

        [Fact]
        public void BuildExpressionWithDateParameter()
        {
            var expression = "[dateTimeAdd(parameters('startDate'), parameters('duration'))]";
            var context = GetContext();
            var expected = JObject.Parse("{ \"value\": \"2021-05-01T00:00:00Z\", \"duration\": \"P10Y\" }");
            Assert.Equal(JTokenType.Date, expected["value"].Type);
            Assert.Equal(JTokenType.String, expected["duration"].Type);

            context.Parameter("startDate", expected["value"]);
            context.Parameter("duration", expected["duration"]);
            var actual = Build(context, expression);
            Assert.NotNull(actual);
        }

        [Fact]
        public void BuildExpressionWithDateTimeAdd()
        {
            // Ensure examples pass
            var add3Years = "[dateTimeAdd(parameters('baseTime'), 'P3Y')]";
            var subtract9Days = "[dateTimeAdd(parameters('baseTime'), '-P9D')]";
            var add1Hour = "[dateTimeAdd(parameters('baseTime'), 'PT1H')]";
            var context = GetContext();
            context.Parameter("baseTime", "2020-04-07 14:53:14Z");
            var actual1 = Build(context, add3Years);
            var actual2 = Build(context, subtract9Days);
            var actual3 = Build(context, add1Hour);

            Assert.Equal("4/7/2023 2:53:14 PM", actual1);
            Assert.Equal("3/29/2020 2:53:14 PM", actual2);
            Assert.Equal("4/7/2020 3:53:14 PM", actual3);
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
