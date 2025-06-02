// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// Unit tests for <see cref="ExpressionParser"/>.
/// </summary>
public sealed class ExpressionParserTests
{
    [Fact]
    public void ParseExpression1()
    {
        var expression = "[parameters( 'vnetName' ) ]";
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
        var expression = "[concat('route-', parameters('subnets')[ copyIndex('routeIndex') ].name)]";
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
        var expression = "[concat(split(parameters('addressPrefix')[ 0 ], '/')[0], '/27')]";
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
        Assert.Equal(ExpressionTokenType.Numeric, actual[9].Type); // 0
        Assert.Equal(0, actual[9].Value);
        Assert.Equal(ExpressionTokenType.IndexEnd, actual[10].Type);
        Assert.Equal(ExpressionTokenType.String, actual[11].Type); // '/'
        Assert.Equal("/", actual[11].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[12].Type);
        Assert.Equal(ExpressionTokenType.IndexStart, actual[13].Type);
        Assert.Equal(ExpressionTokenType.Numeric, actual[14].Type); // 0
        Assert.Equal(0, actual[14].Value);
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
        Assert.Equal(ExpressionTokenType.Numeric, actual[8].Type); // 0
        Assert.Equal(0, actual[8].Value);
        Assert.Equal(ExpressionTokenType.IndexEnd, actual[9].Type);
        Assert.Equal(ExpressionTokenType.Property, actual[10].Type); // .route
        Assert.Equal("route", actual[10].Content);
        Assert.Equal(ExpressionTokenType.IndexStart, actual[11].Type);
        Assert.Equal(ExpressionTokenType.Numeric, actual[12].Type); // 1
        Assert.Equal(1, actual[12].Value);
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
    public void ParseExpression7()
    {
        var expression = "[variables('eventGridSubscription').filter.includedEventTypes]";
        var actual = ExpressionParser.Parse(expression).ToArray();
        Assert.Equal(6, actual.Length);
        Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // variables
        Assert.Equal("variables", actual[0].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
        Assert.Equal(ExpressionTokenType.String, actual[2].Type); // eventGridSubscription
        Assert.Equal("eventGridSubscription", actual[2].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[3].Type);
        Assert.Equal(ExpressionTokenType.Property, actual[4].Type); // filter
        Assert.Equal("filter", actual[4].Content);
        Assert.Equal(ExpressionTokenType.Property, actual[5].Type); // includedEventTypes
        Assert.Equal("includedEventTypes", actual[5].Content);
    }

    [Fact]
    public void ParseExpressionMultiline()
    {
        var expression = "[\r\nparameters(\r\n                 'vnetName'\r\n)\r\n]";
        var actual = ExpressionParser.Parse(expression).ToArray();
        Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // parameters
        Assert.Equal("parameters", actual[0].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
        Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'vnetName'
        Assert.Equal("vnetName", actual[2].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[3].Type);
    }

    [Fact]
    public void ParseExpressionWithStringIndexProperty()
    {
        var expression = "[ variables('configurations')[ variables('environment') ][ 'defaults' ][\r\n'item1'] ]";
        var actual = ExpressionParser.Parse(expression).ToArray();

        Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // variables
        Assert.Equal("variables", actual[0].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
        Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'configurations'
        Assert.Equal("configurations", actual[2].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[3].Type);
        Assert.Equal(ExpressionTokenType.IndexStart, actual[4].Type);
        Assert.Equal(ExpressionTokenType.Element, actual[5].Type);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[6].Type);
        Assert.Equal(ExpressionTokenType.String, actual[7].Type); // 'environment'
        Assert.Equal("environment", actual[7].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[8].Type);
        Assert.Equal(ExpressionTokenType.IndexEnd, actual[9].Type);
        Assert.Equal(ExpressionTokenType.IndexStart, actual[10].Type);
        Assert.Equal(ExpressionTokenType.String, actual[11].Type); // 'defaults'
        Assert.Equal("defaults", actual[11].Content);
        Assert.Equal(ExpressionTokenType.IndexEnd, actual[12].Type);
        Assert.Equal(ExpressionTokenType.IndexStart, actual[13].Type);
        Assert.Equal(ExpressionTokenType.String, actual[14].Type); // 'item1'
        Assert.Equal("item1", actual[14].Content);
        Assert.Equal(ExpressionTokenType.IndexEnd, actual[15].Type);
    }

    [Fact]
    public void ParseQuoting()
    {
        var expression = "[format('A''{0}''', string(variables('task').parameters))]";
        var actual = ExpressionParser.Parse(expression).ToArray();

        Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // format
        Assert.Equal("format", actual[0].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
        Assert.Equal(ExpressionTokenType.String, actual[2].Type); // 'A'{0}''
        Assert.Equal("A'{0}'", actual[2].Content);
        Assert.Equal(ExpressionTokenType.Element, actual[3].Type); // string
        Assert.Equal("string", actual[3].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[4].Type);
        Assert.Equal(ExpressionTokenType.Element, actual[5].Type); // variables
        Assert.Equal("variables", actual[5].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[6].Type);
        Assert.Equal(ExpressionTokenType.String, actual[7].Type); // 'task'
        Assert.Equal("task", actual[7].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[8].Type);
        Assert.Equal(ExpressionTokenType.Property, actual[9].Type); // parameters
        Assert.Equal("parameters", actual[9].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[10].Type);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[11].Type);
    }

    [Fact]
    public void ParseQuotingDoubles()
    {
        var expression = "[format('''{0}''', replace(replace(join(parameters('principalTypes'), ','), '\\\"', ''''), ',', ''','''))]";
        var actual = ExpressionParser.Parse(expression).ToArray();

        Assert.Equal(ExpressionTokenType.Element, actual[0].Type); // format
        Assert.Equal("format", actual[0].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[1].Type);
        Assert.Equal(ExpressionTokenType.String, actual[2].Type); // '''{0}'''
        Assert.Equal("'{0}'", actual[2].Content);
        Assert.Equal(ExpressionTokenType.Element, actual[3].Type); // replace
        Assert.Equal("replace", actual[3].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[4].Type);
        Assert.Equal(ExpressionTokenType.Element, actual[5].Type); // replace
        Assert.Equal("replace", actual[5].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[6].Type);
        Assert.Equal(ExpressionTokenType.Element, actual[7].Type); // join
        Assert.Equal("join", actual[7].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[8].Type);
        Assert.Equal(ExpressionTokenType.Element, actual[9].Type); // parameters
        Assert.Equal("parameters", actual[9].Content);
        Assert.Equal(ExpressionTokenType.GroupStart, actual[10].Type);
        Assert.Equal(ExpressionTokenType.String, actual[11].Type); // 'principalTypes'
        Assert.Equal("principalTypes", actual[11].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[12].Type);
        Assert.Equal(ExpressionTokenType.String, actual[13].Type); // ','
        Assert.Equal(",", actual[13].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[14].Type);
        Assert.Equal(ExpressionTokenType.String, actual[15].Type); // '\"'
        Assert.Equal("\\\"", actual[15].Content);
        Assert.Equal(ExpressionTokenType.String, actual[16].Type); // ''''
        Assert.Equal("'", actual[16].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[17].Type);
        Assert.Equal(ExpressionTokenType.String, actual[18].Type); // ','
        Assert.Equal(",", actual[18].Content);
        Assert.Equal(ExpressionTokenType.String, actual[19].Type); // ''','''
        Assert.Equal("','", actual[19].Content);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[20].Type);
        Assert.Equal(ExpressionTokenType.GroupEnd, actual[21].Type);
    }
}
