using PSRule.Rules.Azure.Data.Template;
using Xunit;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class ExpressionParserTests
    {
        [Fact]
        public void ParseExpression1()
        {
            var expression = "[parameters('vnetName')]";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // parameters
            Assert.Equal("parameters", actual[0].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
            Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'vnetName'
            Assert.Equal("vnetName", actual[2].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[3].Type);
        }

        [Fact]
        public void ParseExpression2()
        {
            var expression = "[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // concat
            Assert.Equal("concat", actual[0].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
            Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'route-'
            Assert.Equal("route-", actual[2].Content);
            Assert.Equal(ExpressionTokenType.Element, actual[3].Type); // parameters
            Assert.Equal("parameters", actual[3].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[4].Type);
            Assert.Equal(ExpressionTokenType.String, actual[5].Type); // 'subnets'
            Assert.Equal("subnets", actual[5].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[6].Type);
            Assert.Equal(ExpressionTokenType.IndexStart, actual[7].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[8].Type); // copyIndex
            Assert.Equal("copyIndex", actual[8].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[9].Type);
            Assert.Equal(ExpressionTokenType.String, actual[10].Type); // 'routeIndex'
            Assert.Equal("routeIndex", actual[10].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[11].Type);
            Assert.Equal(ExpressionTokenType.IndexEnd, actual[12].Type);
            Assert.Equal(ExpressionTokenType.Property, actual[13].Type); // .name
            Assert.Equal("name", actual[13].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[14].Type);
        }

        [Fact]
        public void ParseExpression3()
        {
            var expression = "[concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // concat
            Assert.Equal("concat", actual[0].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[2].Type); // split
            Assert.Equal("split", actual[2].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[3].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[4].Type); // parameters
            Assert.Equal("parameters", actual[4].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[5].Type);
            Assert.Equal(ExpressionTokenType.String, actual[6].Type); // 'addressPrefix'
            Assert.Equal("addressPrefix", actual[6].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[7].Type);
            Assert.Equal(ExpressionTokenType.IndexStart, actual[8].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[9].Type); // 0
            Assert.Equal("0", actual[9].Content);
            Assert.Equal(ExpressionTokenType.IndexEnd, actual[10].Type);
            Assert.Equal(ExpressionTokenType.String, actual[11].Type); // '/'
            Assert.Equal("/", actual[11].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[12].Type);
            Assert.Equal(ExpressionTokenType.IndexStart, actual[13].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[14].Type); // 0
            Assert.Equal("0", actual[14].Content);
            Assert.Equal(ExpressionTokenType.IndexEnd, actual[15].Type);
            Assert.Equal(ExpressionTokenType.String, actual[16].Type); // '/27'
            Assert.Equal("/27", actual[16].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[17].Type);
        }

        [Fact]
        public void ParseExpression4()
        {
            var expression = "[concat('route-', parameters('subnets')[0].route[1])]";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // concat
            Assert.Equal("concat", actual[0].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
            Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'route-'
            Assert.Equal("route-", actual[2].Content);
            Assert.Equal(ExpressionTokenType.Element, actual[3].Type); // parameters
            Assert.Equal("parameters", actual[3].Content);
            Assert.Equal(ExpressionTokenType.GroupStart, actual[4].Type);
            Assert.Equal(ExpressionTokenType.String, actual[5].Type); // 'subnets'
            Assert.Equal("subnets", actual[5].Content);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[6].Type);
            Assert.Equal(ExpressionTokenType.IndexStart, actual[7].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[8].Type); // 0
            Assert.Equal("0", actual[8].Content);
            Assert.Equal(ExpressionTokenType.IndexEnd, actual[9].Type);
            Assert.Equal(ExpressionTokenType.Property, actual[10].Type); // .route
            Assert.Equal("route", actual[10].Content);
            Assert.Equal(ExpressionTokenType.IndexStart, actual[11].Type);
            Assert.Equal(ExpressionTokenType.Element, actual[12].Type); // 1
            Assert.Equal("1", actual[12].Content);
            Assert.Equal(ExpressionTokenType.IndexEnd, actual[13].Type);
            Assert.Equal(ExpressionTokenType.GroupEnd, actual[14].Type);
        }

        [Fact]
        public void ParseExpression5()
        {
            var expression = "['subnet1']";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(ExpressionTokenType.String, actual[0].Type); // concat
            Assert.Equal("subnet1", actual[0].Content);
        }

        [Fact]
        public void ParseExpression6()
        {
            var expression = "[resourceId ('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), variables ('subnetName'))]";
            var actual = ExpressionParser.Parse(expression).ToArray();
            Assert.Equal(12, actual.Length);
            Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // resourceId
            Assert.Equal("resourceId", actual[0].Content);
        }

        [Fact]
        public void BuildExpression1()
        {
            var expression = "[parameters('vnetName')]";
            var builder = new ExpressionBuilder();
            var context = new TemplateContext();
            context.Parameters["vnetName"] = "vnet1";

            var fn = builder.Build(expression);
            var actual = fn(context);

            Assert.Equal("vnet1", actual);
        }

        [Fact]
        public void BuildExpression2()
        {
            var expression = "[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]";
            var builder = new ExpressionBuilder();
            var context = new TemplateContext();
            context.CopyIndex.Push(new TemplateContext.CopyIndexState() { Name = "routeIndex", Index = 0 });
            context.Parameters["subnets"] = new TestSubnet[] { new TestSubnet("subnet1", new string[] { "routeA", "routeB" }) };

            var fn = builder.Build(expression);
            var actual = fn(context);

            Assert.Equal("route-subnet1", actual);
        }

        [Fact]
        public void BuildExpression4()
        {
            var expression = "[concat('route-', parameters('subnets')[0].route[1])]";
            var builder = new ExpressionBuilder();
            var context = new TemplateContext();
            context.Parameters["subnets"] = new TestSubnet[] { new TestSubnet("subnet1", new string[] { "routeA", "routeB" }) };

            var fn = builder.Build(expression);
            var actual = fn(context);

            Assert.Equal("route-routeB", actual);
        }

        [Fact]
        public void BuildExpression5()
        {
            var expression = "['subnet1']";
            var builder = new ExpressionBuilder();
            var context = new TemplateContext();
            var fn = builder.Build(expression);
            var actual = fn(context);

            Assert.Equal("subnet1", actual);
        }
    }
}
