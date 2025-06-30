// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Deployments;
using PSRule.Rules.Azure.Arm.Mocks;
using PSRule.Rules.Azure.Arm.Symbols;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data;
using PSRule.Rules.Azure.Data.Template;
using static PSRule.Rules.Azure.Arm.Deployments.DeploymentVisitor;

namespace PSRule.Rules.Azure.Arm.Expressions;

public sealed class FunctionTests
{
    private const string TRAIT = "Function";
    private const string TRAIT_ARRAY = "Array";
    private const string TRAIT_LOGICAL = "Logical";
    private const string TRAIT_COMPARISON = "Comparison";
    private const string TRAIT_DATE = "Date";
    private const string TRAIT_DEPLOYMENT = "Deployment";
    private const string TRAIT_NUMERIC = "Numeric";
    private const string TRAIT_STRING = "String";
    private const string TRAIT_RESOURCE = "Resource";
    private const string TRAIT_SCOPE = "Scope";
    private const string TRAIT_LAMBDA = "Lambda";
    private const string TRAIT_CIDR = "CIDR";
    private const string TRAIT_AVAILABILITY_ZONES = "AvailabilityZones";

    #region Array and object

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Array()
    {
        var context = GetContext();

        var actual1 = Functions.Array(context, [1]) as JArray;
        var actual2 = Functions.Array(context, ["efgh"]) as JArray;
        var actual3 = Functions.Array(context, [JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }")]) as JArray;
        var actual4 = Functions.Array(context, [new JArray()]) as JArray;
        Assert.Equal(1, actual1[0]);
        Assert.Equal("efgh", actual2[0]);
        Assert.Equal("b", actual3[0]["a"]);
        Assert.Empty(actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, ["abcd", "efgh"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Coalesce()
    {
        ExpressionFnOuter throws = (context) => throw new NotImplementedException();
        var context = GetContext();

        Assert.Equal(1, Functions.Coalesce(context, [null, null, 1, 2, 3]));
        Assert.Equal("a", Functions.Coalesce(context, [null, null, "a", "b", "c"]));
        Assert.Equal("b", (Functions.Coalesce(context, [null, JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }")]) as JToken)["a"]);
        Assert.Null(Functions.Coalesce(context, [null]));
        Assert.Null(Functions.Coalesce(context, [null, null]));
        Assert.Equal("a", Functions.Coalesce(context, [null, "a", throws]));

        Assert.Throws<ExpressionArgumentException>(() => Functions.Coalesce(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Coalesce(context, []));
        Assert.Throws<NotImplementedException>(() => Functions.Coalesce(context, [null, throws]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Concat()
    {
        var context = GetContext();

        // Concat arrays
        var actual1 = Functions.Concat(context, new string[][] { ["1-1", "1-2", "1-3"], ["2-1", "2-2", "2-3"] }) as object[];
        Assert.Equal(6, actual1.Length);

        // Concat strings
        var actual2 = Functions.Concat(context, new string[] { "left", "-", "right" }) as string;
        Assert.Equal("left-right", actual2);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Contains()
    {
        var context = GetContext();

        // String
        Assert.True((bool)Functions.Contains(context, ["OneTwoThree", "e"]));
        Assert.False((bool)Functions.Contains(context, ["OneTwoThree", "z"]));
        Assert.True((bool)Functions.Contains(context, ["abcd", new JValue("bc")]));
        Assert.False((bool)Functions.Not(context, [Functions.Contains(context, ["abcd", new JValue("bc")])]));
        Assert.True((bool)Functions.Contains(context, [new JValue("abcd"), new JValue("bc")]));
        Assert.False((bool)Functions.Not(context, [Functions.Contains(context, [new JValue("abcd"), new JValue("bc")])]));

        // Object
        Assert.True((bool)Functions.Contains(context, [JObject.Parse("{ \"one\": \"a\", \"two\": \"b\", \"three\": \"c\" }"), "two"]));
        Assert.True((bool)Functions.Contains(context, [JObject.Parse("{ \"one\": \"a\", \"two\": \"b\", \"three\": \"c\" }"), "Two"]));
        Assert.False((bool)Functions.Contains(context, [JObject.Parse("{ \"one\": \"a\", \"two\": \"b\", \"three\": \"c\" }"), "four"]));

        // Array
        Assert.True((bool)Functions.Contains(context, [new string[] { "one", "two", "three" }, "two"]));
        Assert.True((bool)Functions.Contains(context, [new object[] { "one", "two", "three" }, "two"]));
        Assert.True((bool)Functions.Contains(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), "two"]));
        Assert.True((bool)Functions.Contains(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), new JValue("two")]));
        Assert.False((bool)Functions.Contains(context, [new object[] { "one", "two", "three" }, "Two"]));
        Assert.False((bool)Functions.Contains(context, [new object[] { "one", "two", "three" }, "four"]));
        Assert.True((bool)Functions.Contains(context, [new object[] { 1, 2, 3 }, 3]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void CreateArray()
    {
        var context = GetContext();

        var actual1 = Functions.CreateArray(context, [1, 2, 3]) as JArray;
        var actual2 = Functions.CreateArray(context, ["efgh"]) as JArray;
        var actual3 = Functions.CreateArray(context, [JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }"), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }")]) as JArray;
        var actual4 = Functions.CreateArray(context, null) as JArray;
        var actual5 = Functions.CreateArray(context, System.Array.Empty<object>()) as JArray;
        var actual6 = Functions.CreateArray(context, [
            "value1",
            new Mock.MockResource("Microsoft.Resources/deployments/test1")["outputs"]["aksSubnetId"]["value"],
        ]) as JArray;
        Assert.Equal(3, actual1.Count);
        Assert.Equal(1, actual1[0]);
        Assert.Equal("efgh", actual2[0]);
        Assert.Equal("b", actual3[0]["a"]);
        Assert.Equal("h", actual3[1]["g"]);
        Assert.Empty(actual4);
        Assert.Empty(actual5);
        Assert.NotEmpty(actual6);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void CreateObject()
    {
        var context = GetContext();

        var actual1 = Functions.CreateObject(context, [
            "intProp",
            1,
            "stringProp",
            "abc",
            "boolProp",
            true,
            "arrayProp",
            Functions.CreateArray(context, ["a", "b", "c"]),
            "objectProp",
            Functions.CreateObject(context, ["key1", "value1"]),
            "mockProp",
            new Mock.MockResource("Microsoft.Resources/deployments/test1")["outputs"]["aksSubnetId"]["value"],
        ]) as JObject;
        var actual2 = Functions.CreateObject(context, []) as JObject;
        var actual3 = Functions.CreateObject(context, [
            "intProp",
            new Mock.MockValue(1),
            "stringProp",
            new Mock.MockValue("mock", secret:false),
            "boolProp",
            new Mock.MockValue(true),
            "arrayProp",
            Functions.CreateArray(context, ["a", "b", "c"]),
            "objectProp",
            Functions.CreateObject(context, ["key1", "value1"]),
            "mockProp",
            new Mock.MockObject(),
        ]) as JObject;

        Assert.Equal(1, actual1["intProp"]);
        Assert.Equal("abc", actual1["stringProp"]);
        Assert.Equal(true, actual1["boolProp"]);
        Assert.Equal("b", actual1["arrayProp"][1]);
        Assert.Equal("value1", actual1["objectProp"]["key1"]);
        //Assert.Equal("{{Resource.outputs.aksSubnetId.value}}", actual1["mockProp"].Path);
        Assert.Equal("{}", actual1["mockProp"].ToString());

        Assert.NotNull(actual2);
        Assert.NotNull(actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.CreateObject(context, ["intProp", 1, "stringProp"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Empty()
    {
        var context = GetContext();

        // String
        var actual1 = (bool)Functions.Empty(context, [""]);
        var actual2 = (bool)Functions.Empty(context, ["notEmpty"]);
        var actual3 = (bool)Functions.Empty(context, [new JValue("")]);
        Assert.True(actual1);
        Assert.False(actual2);
        Assert.True(actual3);

        // Object
        var actual4 = (bool)Functions.Empty(context, [JObject.Parse("{}")]);
        var actual5 = (bool)Functions.Empty(context, [JObject.Parse("{ \"name\": \"test\" }")]);
        var actual6 = (bool)Functions.Empty(context, [JToken.Parse("{}")]);
        Assert.True(actual4);
        Assert.False(actual5);
        Assert.True(actual6);

        // Array
        var actual7 = (bool)Functions.Empty(context, [new JArray()]);
        var actual8 = (bool)Functions.Empty(context, [new JArray(JObject.Parse("{}"))]);
        var actual9 = (bool)Functions.Empty(context, [JToken.Parse("[]")]);
        Assert.True(actual7);
        Assert.False(actual8);
        Assert.True(actual9);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void First()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.First(context, ["one"]) as string;
        Assert.Equal("o", actual1);

        // Array
        actual1 = Functions.First(context, [new string[] { "one", "two", "three" }]) as string;
        Assert.Equal("one", actual1);
        actual1 = Functions.First(context, [System.Array.Empty<string>()]) as string;
        Assert.Null(actual1);
        actual1 = Functions.First(context, [new JArray()]) as string;
        Assert.Null(actual1);
        actual1 = Functions.First(context, [null]) as string;
        Assert.Null(actual1);

        var actual2 = Functions.First(context, [new Mock.MockArray()]);
        Assert.Null(actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.First(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.First(context, []));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Flatten()
    {
        var context = GetContext();

        var actual = Functions.Flatten(context, [new object[] { new string[] { "one", "two" }, new string[] { "three" }, new string[] { "four", "five" } }]) as object[];
        Assert.Equal(new string[] { "one", "two", "three", "four", "five" }, actual);

        actual = Functions.Flatten(context, [new object[] { new string[] { "one", "two", "three" }, new object[] { "three" }, new object[] { "four", "five" } }]) as object[];
        Assert.Equal(new string[] { "one", "two", "three", "three", "four", "five" }, actual);

        actual = Functions.Flatten(context, [new object[] { new string[] { "one", "two", "three" }, new object[] { 3 }, new object[] { 4, 5 } }]) as object[];
        Assert.Equal(["one", "two", "three", 3, 4, 5], actual);

        actual = Functions.Flatten(context, [new object[] { }]) as object[];
        Assert.Equal([], actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Flatten(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Flatten(context, []));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Intersection()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.Intersection(context, [new JArray("one", "two", "three"), new JArray("two", "three")]) as JArray;
        Assert.Equal(2, actual1.Count);
        Assert.Equal("two", actual1[0]);
        Assert.Equal("three", actual1[1]);

        // Array
        var actual2 = Functions.Intersection(context, [JObject.Parse("{ \"one\": \"a\", \"two\": \"b\", \"three\": \"c\" }"), JObject.Parse("{ \"one\": \"a\", \"two\": \"z\", \"three\": \"c\" }")]) as JObject;
        Assert.Equal(2, actual2.Count);
        Assert.Equal("a", actual2["one"]);
        Assert.Equal("c", actual2["three"]);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Intersection(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Intersection(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Intersection(context, ["one", "two", "three"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Items()
    {
        var context = GetContext();

        // Object
        var actual = Functions.Items(context, [JObject.Parse("{ \"item002\": { \"enabled\": false, \"displayName\": \"Example item 2\", \"number\": 200 }, \"item001\": { \"enabled\": true, \"displayName\": \"Example item 1\", \"number\": 300 } }")]) as JArray;
        Assert.Equal(2, actual.Count);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Json()
    {
        var context = GetContext();

        // Object
        var actual1 = Functions.Json(context, ["{ \"a\": \"b\" }"]) as JObject;
        Assert.Equal("b", actual1["a"].Value<string>());
        actual1 = Functions.Json(context, ["{'a': 'b'}"]) as JObject;
        Assert.Equal("b", actual1["a"].Value<string>());
        actual1 = Functions.Json(context, ["{''a'': ''b''}"]) as JObject;
        Assert.Equal("b", actual1["a"].Value<string>());
        actual1 = Functions.Json(context, [Functions.Format(context, ["{{''a'': ''{0}''}}", "b"])]) as JObject;
        Assert.Equal("b", actual1["a"].Value<string>());
        var actual2 = Functions.Json(context, ["\"\""]) as string;
        Assert.Equal("", actual2);
        actual2 = Functions.Json(context, ["''"]) as string;
        Assert.Equal("", actual2);
        actual2 = Functions.Json(context, [""]) as string;
        Assert.Null(actual2);
        var actual3 = Functions.Json(context, ["null"]);
        Assert.Null(actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Json(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Json(context, []));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Null()
    {
        var context = GetContext();

        var actual1 = Functions.Null(context, null);
        var actual2 = Functions.Null(context, System.Array.Empty<object>());

        Assert.Null(actual1);
        Assert.Null(actual2);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Last()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.Last(context, ["one"]) as string;
        Assert.Equal("e", actual1);
        actual1 = Functions.Last(context, [System.Array.Empty<string>()]) as string;
        Assert.Null(actual1);
        actual1 = Functions.Last(context, [new JArray()]) as string;
        Assert.Null(actual1);
        actual1 = Functions.Last(context, [null]) as string;
        Assert.Null(actual1);

        // Array
        actual1 = Functions.Last(context, [new string[] { "one", "two", "three" }]) as string;
        Assert.Equal("three", actual1);
        var actual2 = Functions.Last(context, [new Mock.MockArray()]);
        Assert.Null(actual2);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Length()
    {
        var context = GetContext();

        // Length arrays
        var actual = (long)Functions.Length(context, [new string[] { "one", "two", "three" }]);
        Assert.Equal(3, actual);
        actual = (long)Functions.Length(context, [new JArray(new string[] { "one", "two", "three" })]);
        Assert.Equal(3, actual);
        actual = (long)Functions.Length(context, [JToken.Parse("[ \"one\", \"two\" ]")]);
        Assert.Equal(2, actual);

        // Length strings
        actual = (long)Functions.Length(context, ["One Two Three"]);
        Assert.Equal(13, actual);
        actual = (long)Functions.Length(context, [new JValue("One Two Three")]);
        Assert.Equal(13, actual);

        // Length objects
        actual = (long)Functions.Length(context, [new TestLengthObject()]);
        Assert.Equal(4, actual);
        actual = (long)Functions.Length(context, [JToken.Parse("{ \"one\": \"two\", \"three\": \"four\" }")]);
        Assert.Equal(2, actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Length(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Length(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Length(context, [null]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Max()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Max(context, [6, 4, 8, 1, 2]);
        var actual2 = (long)Functions.Max(context, [1, 1, 1]);
        var actual3 = (long)Functions.Max(context, [1]);
        Assert.Equal(8, actual1);
        Assert.Equal(1, actual2);
        Assert.Equal(1, actual3);

        // Array
        var actual4 = (long)Functions.Max(context, [new JArray(new int[] { 6, 4, 8, 1, 2 })]);
        var actual5 = (long)Functions.Max(context, [new JArray(new int[] { 6, 4 }), 8]);
        var actual6 = (long)Functions.Max(context, [new JArray(new int[] { 6, 4 }), new JArray(new int[] { 8 })]);
        Assert.Equal(8, actual4);
        Assert.Equal(8, actual5);
        Assert.Equal(8, actual6);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, ["one", "two"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, [1, "0"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Min()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Min(context, [6, 4, 8, 1, 2]);
        var actual2 = (long)Functions.Min(context, [1, 1, 1]);
        var actual3 = (long)Functions.Min(context, [1]);
        Assert.Equal(1, actual1);
        Assert.Equal(1, actual2);
        Assert.Equal(1, actual3);

        // Array
        var actual4 = (long)Functions.Min(context, [new JArray(new int[] { 6, 4, 8, 1, 2 })]);
        var actual5 = (long)Functions.Min(context, [new JArray(new long[] { 6, 4 }), 8]);
        var actual6 = (long)Functions.Min(context, [new JArray(new int[] { 6, 4 }), new JArray(new int[] { 8 })]);
        Assert.Equal(1, actual4);
        Assert.Equal(4, actual5);
        Assert.Equal(4, actual6);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, ["one", "two"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, [1, "0"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void ObjectKeys()
    {
        var context = GetContext();

        var actual = Functions.ObjectKeys(context, [JObject.Parse("{ \"a\": 1, \"b\": 2 }")]) as JArray;
        Assert.Equal(new string[] { "a", "b" }, actual.Values<string>().ToArray());

        actual = Functions.ObjectKeys(context, [JObject.Parse("{ }")]) as JArray;
        Assert.Equal(System.Array.Empty<string>(), actual.Values<string>().ToArray());

        actual = Functions.ObjectKeys(context, [JObject.Parse("{ \"b\": 2, \"a\": 1 }")]) as JArray;
        Assert.Equal(new string[] { "a", "b" }, actual.Values<string>().ToArray());

        actual = Functions.ObjectKeys(context, [JObject.Parse("{ \"A\": 2, \"a\": 1 }")]) as JArray;
        Assert.Equal(new string[] { "A", "a" }, actual.Values<string>().ToArray());

        actual = Functions.ObjectKeys(context, [JObject.Parse("{ \"a\": 1, \"A\": 2 }")]) as JArray;
        Assert.Equal(new string[] { "a", "A" }, actual.Values<string>().ToArray());

        Assert.Throws<ExpressionArgumentException>(() => Functions.ObjectKeys(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ObjectKeys(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ObjectKeys(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Range()
    {
        var context = GetContext();

        var actual1 = Functions.Range(context, [1, 3]) as JArray;
        var actual2 = Functions.Range(context, [3, 10]) as JArray;
        var actual3 = Functions.Range(context, [1, 0]) as JArray;
        Assert.Equal(3, actual1.Count);
        Assert.Equal(1, actual1[0]);
        Assert.Equal(2, actual1[1]);
        Assert.Equal(3, actual1[2]);
        Assert.Equal(10, actual2.Count);
        Assert.Equal(3, actual2[0]);
        Assert.Equal(12, actual2[9]);
        Assert.Empty(actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, [1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, ["one", "two"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, [1, "0"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void ShallowMerge()
    {
        var context = GetContext();
        var hashtable = new Hashtable
        {
            ["a"] = 200
        };

        var actual = Functions.ShallowMerge(context, [new object[] { JObject.Parse("{ \"foo\": \"foo\" }"), JObject.Parse("{ \"bar\": \"bar\" }") }]) as JObject;
        Assert.Equal(JObject.Parse("{ \"foo\": \"foo\", \"bar\": \"bar\" }"), actual);

        actual = Functions.ShallowMerge(context, [new object[] { JObject.Parse("{ \"foo\": \"foo\" }"), JObject.Parse("{ \"foo\": \"bar\" }") }]) as JObject;
        Assert.Equal(JObject.Parse("{ \"foo\": \"bar\" }"), actual);

        actual = Functions.ShallowMerge(context, [new JArray(JObject.Parse("{ \"foo\": \"foo\" }"), JObject.Parse("{ \"bar\": \"bar\" }"))]) as JObject;
        Assert.Equal(JObject.Parse("{ \"foo\": \"foo\", \"bar\": \"bar\" }"), actual);

        actual = Functions.ShallowMerge(context, [new object[] { JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }"), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"a\": \"100\" }") }]) as JObject;
        Assert.True(actual.ContainsKey("a"));
        Assert.Equal("100", actual["a"]);
        Assert.True(actual.ContainsKey("e"));
        Assert.Equal("f", actual["e"]);
        Assert.True(actual.ContainsKey("i"));
        Assert.Equal("j", actual["i"]);

        actual = Functions.ShallowMerge(context, [new object[] { new Hashtable(), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"a\": \"100\" }") }]) as JObject;
        Assert.True(actual.ContainsKey("a"));
        Assert.Equal("100", actual["a"]);
        Assert.True(actual.ContainsKey("e"));
        Assert.Equal("f", actual["e"]);

        actual = Functions.ShallowMerge(context, [new object[] { hashtable, JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }") }]) as JObject;
        Assert.True(actual.ContainsKey("a"));
        Assert.Equal(200, actual["a"]);
        Assert.True(actual.ContainsKey("e"));
        Assert.Equal("f", actual["e"]);

        actual = Functions.ShallowMerge(context, [new object[] { null, JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }") }]) as JObject;
        Assert.False(actual.ContainsKey("a"));
        Assert.True(actual.ContainsKey("e"));
        Assert.True(actual.ContainsKey("g"));

        actual = Functions.ShallowMerge(context, [new object[] { hashtable, null }]) as JObject;
        Assert.True(actual.ContainsKey("a"));
        Assert.False(actual.ContainsKey("e"));
        Assert.False(actual.ContainsKey("g"));

        Assert.Throws<ExpressionArgumentException>(() => Functions.ShallowMerge(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ShallowMerge(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ShallowMerge(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Skip()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.Skip(context, ["one two three", 4]) as string;
        var actual2 = Functions.Skip(context, ["one two three", 13]) as string;
        var actual3 = Functions.Skip(context, ["one two three", -100]) as string;
        Assert.Equal("two three", actual1);
        Assert.Equal("", actual2);
        Assert.Equal("one two three", actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, ["one two three"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, ["one two three", "0"]));

        // Array
        var actual4 = Functions.Skip(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 2]) as JArray;
        var actual5 = Functions.Skip(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 3]) as JArray;
        var actual6 = Functions.Skip(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), -100]) as JArray;
        Assert.Equal("three", actual4[0]);
        Assert.Empty(actual5);
        Assert.Equal(3, actual6.Count);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]")]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), "0"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, [1, "0"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Take()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.Take(context, ["one two three", 3]) as string;
        var actual2 = Functions.Take(context, ["one two three", 13]) as string;
        var actual3 = Functions.Take(context, ["one two three", -100]) as string;
        Assert.Equal("one", actual1);
        Assert.Equal("one two three", actual2);
        Assert.Equal("", actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, ["one two three"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, ["one two three", "0"]));

        // Array
        var actual4 = Functions.Take(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 2]) as JArray;
        var actual5 = Functions.Take(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 3]) as JArray;
        var actual6 = Functions.Take(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), -100]) as JArray;
        Assert.Equal("one", actual4[0]);
        Assert.Equal("two", actual4[1]);
        Assert.Equal(3, actual5.Count);
        Assert.Empty(actual6);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]")]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, [JArray.Parse("[ \"one\", \"two\", \"three\" ]"), "0"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, [1, "0"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void Union()
    {
        var context = GetContext();
        var hashtable = new Hashtable
        {
            ["a"] = 200
        };

        // Union objects
        var actual1 = Functions.Union(context, [JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }"), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"a\": \"100\" }")]) as JObject;
        Assert.True(actual1.ContainsKey("a"));
        Assert.Equal("100", actual1["a"]);
        Assert.True(actual1.ContainsKey("e"));
        Assert.Equal("f", actual1["e"]);
        Assert.True(actual1.ContainsKey("i"));
        Assert.Equal("j", actual1["i"]);
        actual1 = Functions.Union(context, [new Hashtable(), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"i\": \"j\" }"), JObject.Parse("{ \"a\": \"100\" }")]) as JObject;
        Assert.True(actual1.ContainsKey("a"));
        Assert.Equal("100", actual1["a"]);
        Assert.True(actual1.ContainsKey("e"));
        Assert.Equal("f", actual1["e"]);
        actual1 = Functions.Union(context, [hashtable, JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }")]) as JObject;
        Assert.True(actual1.ContainsKey("a"));
        Assert.Equal(200, actual1["a"]);
        Assert.True(actual1.ContainsKey("e"));
        Assert.Equal("f", actual1["e"]);
        actual1 = Functions.Union(context, [null, JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }")]) as JObject;
        Assert.False(actual1.ContainsKey("a"));
        Assert.True(actual1.ContainsKey("e"));
        Assert.True(actual1.ContainsKey("g"));
        actual1 = Functions.Union(context, [hashtable, null]) as JObject;
        Assert.True(actual1.ContainsKey("a"));
        Assert.False(actual1.ContainsKey("e"));
        Assert.False(actual1.ContainsKey("g"));
        actual1 = Functions.Union(context, [JObject.Parse("{ \"property\": { \"one\": \"a\", \"two\": \"b\", \"three\": \"c1\" }, \"nestedArray\": [ 1, 2 ] }"), JObject.Parse("{ \"property\": { \"three\": \"c2\", \"four\": \"d\", \"five\": \"e\" }, \"nestedArray\": [ 3, 4 ] }")]) as JObject;
        Assert.Equal("{\"property\":{\"one\":\"a\",\"two\":\"b\",\"three\":\"c2\",\"four\":\"d\",\"five\":\"e\"},\"nestedArray\":[3,4]}", actual1.ToString(Formatting.None));

        // Union arrays
        var actual2 = Functions.Union(context, new string[][] { ["one", "two", "three"], ["three", "four"] }) as object[];
        Assert.Equal(4, actual2.Length);
        actual2 = Functions.Union(context, new object[][] { new string[] { "one", "two" }, null, null }) as object[];
        Assert.Equal(2, actual2.Length);
        actual2 = Functions.Union(context, [new string[] { "one", "two" }, null, new string[] { "one", "three" }]) as object[];
        Assert.Equal(3, actual2.Length);
        actual2 = Functions.Union(context, [new string[] { "one", "two" }, null, new JArray { "one", "three" }]) as object[];
        Assert.Equal(3, actual2.Length);
        actual2 = Functions.Union(context, [new string[] { "one", "two" }, new Mock.MockArray()]) as object[];
        Assert.Equal(2, actual2.Length);
        actual2 = Functions.Union(context, [null, new string[] { "three", "four" }]) as object[];
        Assert.Equal(2, actual2.Length);
        actual2 = Functions.Union(context, [new Mock.MockUnknownObject(), new JArray { "one", "two" }]) as object[];
        Assert.Equal(2, actual2.Length);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Union(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Union(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Union(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void TryGet()
    {
        var context = GetContext();
        var testObject = new JObject
        {
            {
                "properties", new JObject
                {
                    { "displayName", "Test 001" },
                    { "values", new JArray("Value 1", "Value 2") }
                }
            }
        };

        Assert.Equal("Test 001", (Functions.TryGet(context, [testObject, "properties"]) as JObject)["displayName"].Value<string>());
        Assert.Equal("Test 001", (Functions.TryGet(context, [testObject, "properties", "displayName"]) as JValue).Value<string>());
        Assert.Equal("Value 2", (Functions.TryGet(context, [testObject, "properties", "values", 1]) as JValue).Value<string>());
        Assert.Null(Functions.TryGet(context, [testObject, "properties", "values", 2]));
        Assert.Null(Functions.TryGet(context, [testObject, "notValue"]));
        Assert.Null(Functions.TryGet(context, [testObject, "notValue", 0]));
        Assert.Null(Functions.TryGet(context, [testObject, "properties", "notValue"]));
        Assert.Null(Functions.TryGet(context, [testObject, "properties", "notValue", "value"]));

        var testObject2 = new JArray
        {
            "one",
            "two",
        };

        Assert.Equal("two", (Functions.TryGet(context, [testObject2, 1]) as JValue).Value<string>());

        Assert.Throws<ExpressionArgumentException>(() => Functions.TryGet(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TryGet(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TryGet(context, ["one"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void TryIndexFromEnd()
    {
        var context = GetContext();
        var testArray = new JArray("one", "two", "three");

        // Valid index from end
        Assert.Equal("three", (Functions.TryIndexFromEnd(context, [testArray, 1]) as JValue).Value<string>());
        Assert.Equal("two", (Functions.TryIndexFromEnd(context, [testArray, 2]) as JValue).Value<string>());
        Assert.Equal("one", (Functions.TryIndexFromEnd(context, [testArray, 3]) as JValue).Value<string>());

        Assert.Equal("three", Functions.TryIndexFromEnd(context, [new string[] { "one", "two", "three" }, 1]) as string);
        Assert.Equal("two", Functions.TryIndexFromEnd(context, [new string[] { "one", "two", "three" }, 2]) as string);
        Assert.Equal("one", Functions.TryIndexFromEnd(context, [new string[] { "one", "two", "three" }, 3]) as string);

        // Invalid index from end
        Assert.Null(Functions.TryIndexFromEnd(context, [testArray, 4]));
        Assert.Null(Functions.TryIndexFromEnd(context, [testArray, -1]));
        Assert.Null(Functions.TryIndexFromEnd(context, [testArray, "2"]));

        // Invalid input
        Assert.Null(Functions.TryIndexFromEnd(context, [null, 1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TryIndexFromEnd(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TryIndexFromEnd(context, ["one"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_ARRAY)]
    public void IndexFromEnd()
    {
        var context = GetContext();
        var testArray = new JArray("one", "two", "three");

        // Valid index from end
        Assert.Equal("three", (Functions.IndexFromEnd(context, [testArray, 1]) as JValue).Value<string>());
        Assert.Equal("two", (Functions.IndexFromEnd(context, [testArray, 2]) as JValue).Value<string>());
        Assert.Equal("one", (Functions.IndexFromEnd(context, [testArray, 3]) as JValue).Value<string>());

        Assert.Equal("three", Functions.IndexFromEnd(context, [new string[] { "one", "two", "three" }, 1]) as string);
        Assert.Equal("two", Functions.IndexFromEnd(context, [new string[] { "one", "two", "three" }, 2]) as string);
        Assert.Equal("one", Functions.IndexFromEnd(context, [new string[] { "one", "two", "three" }, 3]) as string);

        // Invalid index from end
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, [testArray, 4]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, [testArray, -1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, [testArray, "2"]));

        // Invalid input
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, [null, 1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexFromEnd(context, ["one"]));
    }

    #endregion Array and object

    #region Resource

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void ExtensionResourceId()
    {
        var context = GetContext();
        var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/a";

        var actual1 = Functions.ExtensionResourceId(context, [parentId, "Extension.Test/type", "a"]) as string;
        var actual2 = Functions.ExtensionResourceId(context, [parentId, "Extension.Test/type/subtype", "a", "b"]) as string;

        Assert.Equal($"{parentId}/providers/Extension.Test/type/a", actual1);
        Assert.Equal($"{parentId}/providers/Extension.Test/type/a/subtype/b", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, ["Extension.Test/type", "a"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.ExtensionResourceId(context, [parentId, "Extension.Test/type", "a", "b"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, [parentId, "Extension.Test/type", 1]));

        // With resource group deployment
        parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-001";
        actual1 = Functions.ExtensionResourceId(context, [parentId, "Microsoft.Resources/deployments", "a"]) as string;
        Assert.Equal($"{parentId}/providers/Microsoft.Resources/deployments/a", actual1);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void List()
    {
        var context = GetContext();
        var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a";

        var actual1 = Functions.List(context, [parentId, "2019-01-01"]) as Mock.MockSecret;
        Assert.NotNull(actual1);

        // TODO: Improve test cases
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void PickZones()
    {
        var context = GetContext();
        var actual = Functions.PickZones(context, ["Microsoft.Compute", "virtualMachines", "westus2"]) as JArray;
        Assert.Single(actual);
        Assert.Equal("1", actual[0]);

        actual = Functions.PickZones(context, ["Microsoft.Compute", "virtualMachines", "westus2", 2, 1]) as JArray;
        Assert.Equal(2, actual.Count);
        Assert.Equal("2", actual[0]);
        Assert.Equal("3", actual[1]);

        actual = Functions.PickZones(context, ["Microsoft.Compute", "virtualMachines", "northcentralus"]) as JArray;
        Assert.Empty(actual);

        actual = Functions.PickZones(context, ["Microsoft.Cdn", "profiles", "westus2"]) as JArray;
        Assert.Empty(actual);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void Providers()
    {
        var context = GetContext();

        var actual1 = Functions.Providers(context, ["Microsoft.Web", "sites"]) as ResourceProviderType;
        Assert.NotNull(actual1);
        Assert.Equal("sites", actual1.ResourceType);
        Assert.Equal("2024-11-01", actual1.ApiVersions[0]);
        Assert.Equal("Australia Central", actual1.Locations[0]);

        var actual2 = Functions.Providers(context, ["Microsoft.Web"]) as ResourceProviderType[];
        Assert.NotNull(actual1);
        Assert.Equal(106, actual2.Length);

        var actual3 = Functions.Providers(context, ["microsoft.web", "Sites"]) as ResourceProviderType;
        Assert.NotNull(actual3);
        Assert.Equal("sites", actual3.ResourceType);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Providers(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Providers(context, [1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Providers(context, ["Microsoft.Web", 1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Providers(context, ["Microsoft.Web", "n/a"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Providers(context, ["n/a", "n/a"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void Reference()
    {
        var context = GetContext();
        var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a";

        var actual = Functions.Reference(context, [parentId]) as Mock.MockObject;
        Assert.NotNull(actual);
        Assert.Equal("properties", actual.Path);
        Assert.Equal("properties.value", actual["value"].Path);
        Assert.Equal("properties.extra.value", actual["extra"]["value"].Path);

        actual = Functions.Reference(context, [parentId, "2023-01-01", "Full"]) as Mock.MockObject;
        Assert.NotNull(actual);
        Assert.Equal(string.Empty, actual.Path);
        Assert.Equal(parentId, actual["id"].Value<string>());
        Assert.Equal("a", actual["name"].Value<string>());
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void References()
    {
        var context = GetContext();
        var resourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a";
        var resource = new ResourceValue(resourceId, "a-0", "Unit.Test/type", "child_loop[0]", new JObject(), null);
        context.AddResource(resource);

        var symbol = DeploymentSymbol.NewArray("child_loop");
        symbol.Configure(resource);
        context.AddSymbol(symbol);

        var actual = (Functions.References(context, ["child_loop"]) as object[]).OfType<Mock.MockObject>().ToArray();
        Assert.NotNull(actual);

        actual = (Functions.References(context, ["child_loop", "Full"]) as object[]).OfType<Mock.MockObject>().ToArray();
        Assert.NotNull(actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.References(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.References(context, ["Unit.Test/type", "test"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void ResourceId()
    {
        var context = GetContext();

        var actual1 = Functions.ResourceId(context, ["Microsoft.Network/virtualNetworks", "vnet-001"]) as string;
        var actual2 = Functions.ResourceId(context, ["rg-test", "Microsoft.Network/virtualNetworks", "vnet-001"]) as string;
        var actual3 = Functions.ResourceId(context, ["00000000-0000-0000-0000-000000000000", "rg-test", "Microsoft.Network/virtualNetworks", "vnet-001"]) as string;
        var actual4 = Functions.ResourceId(context, ["Microsoft.Network/virtualNetworks/subnets", "vnet-001", "subnet-001"]) as string;
        var actual5 = Functions.ResourceId(context, ["rg-test", "Microsoft.Network/virtualNetworks/subnets", "vnet-001", "subnet-001"]) as string;
        var actual6 = Functions.ResourceId(context, ["00000000-0000-0000-0000-000000000000", "rg-test", "Microsoft.Network/virtualNetworks/subnets", "vnet-001", "subnet-001"]) as string;
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001", actual1);
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-001", actual2);
        Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-001", actual3);
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/subnet-001", actual4);
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/subnet-001", actual5);
        Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/subnet-001", actual6);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, ["Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.ResourceId(context, ["Unit.Test/type", "a", "b"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, ["Unit.Test/type", 1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void SubscriptionResourceId()
    {
        var context = GetContext();

        var actual1 = Functions.SubscriptionResourceId(context, ["Unit.Test/type", "a"]) as string;
        var actual2 = Functions.SubscriptionResourceId(context, ["00000000-0000-0000-0000-000000000000", "Unit.Test/type", "a"]) as string;
        var actual3 = Functions.SubscriptionResourceId(context, ["Unit.Test/type/subtype", "a", "b"]) as string;
        var actual4 = Functions.SubscriptionResourceId(context, ["00000000-0000-0000-0000-000000000000", "Unit.Test/type/subtype", "a", "b"]) as string;
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/providers/Unit.Test/type/a", actual1);
        Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/a", actual2);
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/providers/Unit.Test/type/a/subtype/b", actual3);
        Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/a/subtype/b", actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, ["Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.SubscriptionResourceId(context, ["Unit.Test/type", "a", "b"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, ["Unit.Test/type", 1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void TenantResourceId()
    {
        var context = GetContext();

        var actual1 = Functions.TenantResourceId(context, ["Unit.Test/type", "a"]) as string;
        var actual2 = Functions.TenantResourceId(context, ["Unit.Test/type/subtype", "a", "b"]) as string;
        var actual3 = Functions.TenantResourceId(context, ["Unit.Test/type/subtype/subsubtype", "a", "b", "c"]) as string;
        Assert.Equal("/providers/Unit.Test/type/a", actual1);
        Assert.Equal("/providers/Unit.Test/type/a/subtype/b", actual2);
        Assert.Equal("/providers/Unit.Test/type/a/subtype/b/subsubtype/c", actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, ["Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.TenantResourceId(context, ["00000000-0000-0000-0000-000000000000", "Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.TenantResourceId(context, ["Unit.Test/type", "a", "b"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, ["Unit.Test/type", 1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_RESOURCE)]
    public void ManagementGroupResourceId()
    {
        var context = GetContext();

        var actual = Functions.ManagementGroupResourceId(context, ["Unit.Test/type", "a"]) as string;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/psrule-test/providers/Unit.Test/type/a", actual);

        context.ManagementGroup.Name = "mg1";
        actual = Functions.ManagementGroupResourceId(context, ["Unit.Test/type/subtype", "a", "b"]) as string;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg1/providers/Unit.Test/type/a/subtype/b", actual);

        actual = Functions.ManagementGroupResourceId(context, ["Unit.Test/type/subtype/subsubtype", "a", "b", "c"]) as string;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg1/providers/Unit.Test/type/a/subtype/b/subsubtype/c", actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ManagementGroupResourceId(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ManagementGroupResourceId(context, ["Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.ManagementGroupResourceId(context, ["00000000-0000-0000-0000-000000000000", "Unit.Test/type"]));
        Assert.Throws<TemplateFunctionException>(() => Functions.ManagementGroupResourceId(context, ["Unit.Test/type", "a", "b"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ManagementGroupResourceId(context, ["Unit.Test/type", 1]));
    }

    #endregion Resource

    #region Scope

    [Fact]
    [Trait(TRAIT, TRAIT_SCOPE)]
    public void ResourceGroup()
    {
        var context = GetContext();

        var actual1 = Functions.ResourceGroup(context, null) as ResourceGroupOption;
        Assert.Equal("ps-rule-test-rg", actual1.Name);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_SCOPE)]
    public void Subscription()
    {
        var context = GetContext();

        var actual1 = Functions.Subscription(context, null) as SubscriptionOption;
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual1.SubscriptionId);
        Assert.Equal("PSRule Test Subscription", actual1.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual1.TenantId);
        Assert.Equal("NotDefined", actual1.State);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_SCOPE)]
    public void Tenant()
    {
        var context = GetContext();
        var actual = Functions.Tenant(context, null) as TenantOption;
        Assert.Equal("/tenants/ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Id);
        Assert.Equal("PSRule", actual.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.TenantId);
        Assert.Equal("US", actual.CountryCode);

        context = GetContext(GetOption("test-template-options.yaml"));
        actual = Functions.Tenant(context, null) as TenantOption;
        Assert.Equal("/tenants/ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Id);
        Assert.Equal("PSRule", actual.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.TenantId);
        Assert.Equal("US", actual.CountryCode);

        context = GetContext(GetOption("ps-rule-options.yaml"));
        actual = Functions.Tenant(context, null) as TenantOption;
        Assert.Equal("/tenants/11111111-1111-1111-1111-111111111111", actual.Id);
        Assert.Equal("Unit Test Tenant", actual.DisplayName);
        Assert.Equal("11111111-1111-1111-1111-111111111111", actual.TenantId);
        Assert.Equal("AU", actual.CountryCode);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_SCOPE)]
    public void ManagementGroup()
    {
        var context = GetContext();
        var actual = Functions.ManagementGroup(context, null) as ManagementGroupOption;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/psrule-test", actual.Id);
        Assert.Equal("psrule-test", actual.Name);
        Assert.Equal("/providers/Microsoft.Management/managementGroups", actual.Type);
        Assert.NotNull(actual.Properties);
        Assert.Equal("PSRule Test Management Group", actual.Properties.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.TenantId);
        Assert.Equal("Tenant Root Group", actual.Properties.Details.Parent.DisplayName);
        Assert.Equal("/providers/Microsoft.Management/managementGroups/ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Id);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Name);
        Assert.Equal("00000000-0000-0000-0000-000000000000", actual.Properties.Details.UpdatedBy);
        Assert.Equal("2020-07-23T21:05:52.661306Z", actual.Properties.Details.UpdatedTime);
        Assert.Equal("1", actual.Properties.Details.Version);

        context = GetContext(GetOption("test-template-options.yaml"));
        actual = Functions.ManagementGroup(context, null) as ManagementGroupOption;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/psrule-test", actual.Id);
        Assert.Equal("psrule-test", actual.Name);
        Assert.Equal("/providers/Microsoft.Management/managementGroups", actual.Type);
        Assert.NotNull(actual.Properties);
        Assert.Equal("PSRule Test Management Group", actual.Properties.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.TenantId);
        Assert.Equal("Tenant Root Group", actual.Properties.Details.Parent.DisplayName);
        Assert.Equal("/providers/Microsoft.Management/managementGroups/ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Id);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Name);
        Assert.Equal("00000000-0000-0000-0000-000000000000", actual.Properties.Details.UpdatedBy);
        Assert.Equal("2020-07-23T21:05:52.661306Z", actual.Properties.Details.UpdatedTime);
        Assert.Equal("1", actual.Properties.Details.Version);

        context = GetContext(GetOption("ps-rule-options.yaml"));
        actual = Functions.ManagementGroup(context, null) as ManagementGroupOption;
        Assert.Equal("/providers/Microsoft.Management/managementGroups/unit-test-mg", actual.Id);
        Assert.Equal("unit-test-mg", actual.Name);
        Assert.Equal("/providers/Microsoft.Management/managementGroups", actual.Type);
        Assert.NotNull(actual.Properties);
        Assert.Equal("My test management group", actual.Properties.DisplayName);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.TenantId);
        Assert.Equal("Tenant Root Group", actual.Properties.Details.Parent.DisplayName);
        Assert.Equal("/providers/Microsoft.Management/managementGroups/ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Id);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.Properties.Details.Parent.Name);
        Assert.Equal("00000000-0000-0000-0000-000000000000", actual.Properties.Details.UpdatedBy);
        Assert.Equal("2020-07-23T21:05:52.661306Z", actual.Properties.Details.UpdatedTime);
        Assert.Equal("1", actual.Properties.Details.Version);
    }

    #endregion Scope

    #region Deployment

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Deployment()
    {
        var context = GetContext();
        context.EnterDeployment("unit-test", JObject.Parse("{ \"contentVersion\": \"1.0.0.0\" }"), isNested: false);

        var actual1 = Functions.Deployment(context, null) as DeploymentValue;
        Assert.Equal("unit-test", actual1.Value["name"]);
        Assert.Equal("1.0.0.0", actual1.Value["properties"]["template"]["contentVersion"]);
        Assert.Equal("abcdef", actual1.Value["properties"]["parameters"]["name"]["value"]);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Deployment(context, [123]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Environment()
    {
        var context = GetContext();

        var actual = Functions.Environment(context, null) as JObject;
        Assert.Equal("AzureCloud", actual["name"]);
        Assert.Equal("https://graph.windows.net/", actual["graph"]);
        Assert.Equal("https://management.azure.com/", actual["resourceManager"]);
        Assert.Equal("https://login.microsoftonline.com/", actual["authentication"]["loginEndpoint"]);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Parameters()
    {
        var context = GetContext();
        context.Parameter("vnetName", ParameterType.String, "vnet1");
        context.Parameter("test", ParameterType.Object, new TestLengthObject());

        // Parameters string
        var actual1 = Functions.Parameters(context, ["vnetName"]);
        Assert.Equal("vnet1", actual1);

        // Parameters object
        var actual2 = Functions.Parameters(context, ["test"]) as TestLengthObject;
        Assert.Equal("two", actual2.propB);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Variables()
    {
        var context = GetContext();
        context.Variable("vnetName", "vnet1");
        context.Variable("test", new TestLengthObject());

        // Parameters string
        var actual1 = Functions.Variables(context, ["vnetName"]);
        Assert.Equal("vnet1", actual1);

        // Parameters object
        var actual2 = Functions.Variables(context, ["test"]) as TestLengthObject;
        Assert.Equal("two", actual2.propB);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Deployer()
    {
        var context = GetContext();

        var actual = Functions.Deployer(context, null) as DeployerOption;
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.ObjectId);
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual.TenantId);
        Assert.Equal("psrule-test@contoso.com", actual.UserPrincipalName);

        context.Deployer.ObjectId = "00000000-0000-0000-0000-000000000000";
        context.Deployer.TenantId = "00000000-0000-0000-0000-000000000000";
        context.Deployer.UserPrincipalName = "other@contoso.com";
        actual = Functions.Deployer(context, null) as DeployerOption;
        Assert.Equal("00000000-0000-0000-0000-000000000000", actual.ObjectId);
        Assert.Equal("00000000-0000-0000-0000-000000000000", actual.TenantId);
        Assert.Equal("other@contoso.com", actual.UserPrincipalName);

        // Accepts no arguments.
        Assert.Throws<ExpressionArgumentException>(() => Functions.Deployer(context, [123]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DEPLOYMENT)]
    public void Fail()
    {
        var context = GetContext();

        // Check for out of range and invalid errors.
        Assert.Throws<ExpressionArgumentException>(() => Functions.Fail(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Fail(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Fail(context, [1, 2]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Fail(context, [1]));

        // Check for intended failure message.
        Assert.Throws<DeploymentFailureException>(() => Functions.Fail(context, ["test"]));
    }

    #endregion Deployment

    #region Comparison

    [Fact]
    [Trait(TRAIT, TRAIT_COMPARISON)]
    public void Equal()
    {
        var context = GetContext();

        // int
        var actual1 = (bool)Functions.Equals(context, [1, 2]);
        var actual2 = (bool)Functions.Equals(context, [2, 1]);
        var actual3 = (bool)Functions.Equals(context, [new JValue(1), 1]);
        Assert.False(actual1);
        Assert.False(actual2);
        Assert.True(actual3);

        // string
        actual1 = (bool)Functions.Equals(context, ["Test1", "Test2"]);
        actual2 = (bool)Functions.Equals(context, ["Test2", "Test1"]);
        actual3 = (bool)Functions.Equals(context, ["Test1", "Test1"]);
        Assert.False(actual1);
        Assert.False(actual2);
        Assert.True(actual3);

        // array
        actual1 = (bool)Functions.Equals(context, [new string[] { "a", "a" }, new string[] { "b", "b" }]);
        actual2 = (bool)Functions.Equals(context, [new string[] { "a", "b" }, new string[] { "a", "b" }]);
        actual3 = (bool)Functions.Equals(context, [new JArray(), JToken.Parse("[]")]);
        Assert.False(actual1);
        Assert.True(actual2);
        Assert.True(actual3);

        // object
        actual1 = (bool)Functions.Equals(context, [new TestLengthObject() { propC = "four", propD = null }, new TestLengthObject() { propD = null }]);
        actual2 = (bool)Functions.Equals(context, [new TestLengthObject() { propD = null }, new TestLengthObject() { propD = null }]);
        actual3 = (bool)Functions.Equals(context, [new JObject(), JToken.Parse("{}")]);
        Assert.False(actual1);
        Assert.True(actual2);
        Assert.True(actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_COMPARISON)]
    public void Greater()
    {
        var context = GetContext();

        // int
        var actual1 = (bool)Functions.Greater(context, [1, 2]);
        var actual2 = (bool)Functions.Greater(context, [2, 1]);
        var actual3 = (bool)Functions.Greater(context, [new JValue(1), 1]);
        Assert.False(actual1);
        Assert.True(actual2);
        Assert.False(actual3);

        // string
        var actual4 = (bool)Functions.Greater(context, ["Test1", "Test2"]);
        var actual5 = (bool)Functions.Greater(context, ["Test2", "Test1"]);
        var actual6 = (bool)Functions.Greater(context, [new JValue("Test1"), "Test1"]);
        Assert.False(actual4);
        Assert.True(actual5);
        Assert.False(actual6);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_COMPARISON)]
    public void GreaterOrEquals()
    {
        var context = GetContext();

        // int
        var actual1 = (bool)Functions.GreaterOrEquals(context, [1, 2]);
        var actual2 = (bool)Functions.GreaterOrEquals(context, [2, 1]);
        var actual3 = (bool)Functions.GreaterOrEquals(context, [new JValue(1), 1]);
        Assert.False(actual1);
        Assert.True(actual2);
        Assert.True(actual3);

        // string
        var actual4 = (bool)Functions.GreaterOrEquals(context, ["Test1", "Test2"]);
        var actual5 = (bool)Functions.GreaterOrEquals(context, ["Test2", "Test1"]);
        var actual6 = (bool)Functions.GreaterOrEquals(context, [new JValue("Test1"), "Test1"]);
        Assert.False(actual4);
        Assert.True(actual5);
        Assert.True(actual6);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_COMPARISON)]
    public void Less()
    {
        var context = GetContext();

        // int
        var actual1 = (bool)Functions.Less(context, [1, 2]);
        var actual2 = (bool)Functions.Less(context, [2, 1]);
        var actual3 = (bool)Functions.Less(context, [new JValue(1), 1]);
        Assert.True(actual1);
        Assert.False(actual2);
        Assert.False(actual3);

        // string
        var actual4 = (bool)Functions.Less(context, ["Test1", "Test2"]);
        var actual5 = (bool)Functions.Less(context, ["Test2", "Test1"]);
        var actual6 = (bool)Functions.Less(context, [new JValue("Test1"), "Test1"]);
        Assert.True(actual4);
        Assert.False(actual5);
        Assert.False(actual6);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_COMPARISON)]
    public void LessOrEquals()
    {
        var context = GetContext();

        // int
        var actual1 = (bool)Functions.LessOrEquals(context, [1, 2]);
        var actual2 = (bool)Functions.LessOrEquals(context, [2, 1]);
        var actual3 = (bool)Functions.LessOrEquals(context, [new JValue(1), 1]);
        Assert.True(actual1);
        Assert.False(actual2);
        Assert.True(actual3);

        // string
        var actual4 = (bool)Functions.LessOrEquals(context, ["Test1", "Test2"]);
        var actual5 = (bool)Functions.LessOrEquals(context, ["Test2", "Test1"]);
        var actual6 = (bool)Functions.LessOrEquals(context, [new JValue("Test1"), "Test1"]);
        Assert.True(actual4);
        Assert.False(actual5);
        Assert.True(actual6);
    }

    #endregion Comparison

    #region Date

    [Fact]
    [Trait(TRAIT, TRAIT_DATE)]
    public void DateTimeAdd()
    {
        var context = GetContext();
        var utc = DateTime.Parse("2020-04-07 14:53:14Z", new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        Assert.Equal(DateTimeKind.Utc, utc.Kind);

        var actual1 = DateTime.Parse(Functions.DateTimeAdd(context, [utc.ToString("u"), "P3Y"]) as string, new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        var actual2 = DateTime.Parse(Functions.DateTimeAdd(context, [utc.ToString("u"), "-P9D"]) as string, new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        var actual3 = DateTime.Parse(Functions.DateTimeAdd(context, [utc.ToString("u"), "PT1H"]) as string, new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        var actual4 = DateTime.Parse(Functions.DateTimeAdd(context, [utc.ToString("u"), "P3Y", "u"]) as string, new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        var actual5 = DateTime.Parse(Functions.DateTimeAdd(context, [Functions.UtcNow(context, System.Array.Empty<object>()), "P3Y", "u"]) as string, new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);

        Assert.Equal(utc.AddYears(3), actual1);
        Assert.Equal(utc.AddDays(-9), actual2);
        Assert.Equal(utc.AddHours(1), actual3);
        Assert.Equal(utc.AddYears(3), actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeAdd(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeAdd(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeAdd(context, [1, 2]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeAdd(context, [utc.ToString("u"), 2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DATE)]
    public void DateTimeFromEpoch()
    {
        var context = GetContext();
        var utc = DateTime.Parse("2020-04-07 14:53:14Z", new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        Assert.Equal(DateTimeKind.Utc, utc.Kind);

        var actual1 = Functions.DateTimeFromEpoch(context, [new DateTimeOffset(utc).ToUnixTimeSeconds()]) as string;
        var actual2 = Functions.DateTimeFromEpoch(context, [1683040573]) as string;

        Assert.Equal("2020-04-07T14:53:14Z", actual1);
        Assert.Equal("2023-05-02T15:16:13Z", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeFromEpoch(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeFromEpoch(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeFromEpoch(context, [1, 2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DATE)]
    public void DateTimeToEpoch()
    {
        var context = GetContext();
        var utc = DateTime.Parse("2020-04-07 14:53:14Z", new CultureInfo("en-US"), DateTimeStyles.AdjustToUniversal);
        Assert.Equal(DateTimeKind.Utc, utc.Kind);

        var actual1 = (long)Functions.DateTimeToEpoch(context, ["2020-04-07T14:53:14Z"]);
        var actual2 = (long)Functions.DateTimeToEpoch(context, ["2023-05-02T15:16:13Z"]);

        Assert.Equal(1586271194, actual1);
        Assert.Equal(1683040573, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeToEpoch(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeToEpoch(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DateTimeToEpoch(context, [1, 2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_DATE)]
    public void UtcNow()
    {
        var context = GetContext();
        var utc = DateTime.UtcNow;

        var actual1 = Functions.UtcNow(context, System.Array.Empty<object>()) as string;
        var actual2 = Functions.UtcNow(context, ["d"]) as string;
        var actual3 = Functions.UtcNow(context, ["M d"]) as string;
        Assert.Matches("[0-9]{8}T[0-9]{6}Z", actual1);
        Assert.Equal(utc.ToString("d", new CultureInfo("en-US")), actual2);
        Assert.Equal(utc.ToString("M d", new CultureInfo("en-US")), actual3);
    }

    #endregion Date

    #region Logical

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void And()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.And(context, [true, true, true]);
        var actual2 = (bool)Functions.And(context, [true, true, false]);
        var actual3 = (bool)Functions.And(context, [false, false]);
        var actual4 = (bool)Functions.And(context, [new JValue(true), true]);

        Assert.True(actual1);
        Assert.False(actual2);
        Assert.False(actual3);
        Assert.True(actual4);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void Bool()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.Bool(context, ["true"]);
        var actual2 = (bool)Functions.Bool(context, ["false"]);
        var actual3 = (bool)Functions.Bool(context, [1]);
        var actual4 = (bool)Functions.Bool(context, [0]);
        var actual5 = (bool)Functions.Bool(context, [new JValue(1)]);
        Assert.True(actual1);
        Assert.False(actual2);
        Assert.True(actual3);
        Assert.False(actual4);
        Assert.True(actual5);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void False()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.False(context, null);
        var actual2 = (bool)Functions.False(context, System.Array.Empty<object>());
        Assert.False(actual1);
        Assert.False(actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.False(context, ["true"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void If()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.If(context, [true, true, false]);
        var actual2 = (bool)Functions.If(context, [false, true, false]);
        var actual3 = (bool)Functions.If(context, [new JValue(true), true, false]);
        Assert.True(actual1);
        Assert.False(actual2);
        Assert.True(actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void Not()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.Not(context, [true]);
        var actual2 = (bool)Functions.Not(context, [false]);
        var actual3 = (bool)Functions.Not(context, [new JValue(false)]);
        Assert.False(actual1);
        Assert.True(actual2);
        Assert.True(actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void Or()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.Or(context, [true, true, true]);
        var actual2 = (bool)Functions.Or(context, [true, false]);
        var actual3 = (bool)Functions.Or(context, [false, false, false]);
        var actual4 = (bool)Functions.Or(context, [new JValue(true), true]);
        Assert.True(actual1);
        Assert.True(actual2);
        Assert.False(actual3);
        Assert.True(actual4);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LOGICAL)]
    public void True()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.True(context, null);
        var actual2 = (bool)Functions.True(context, System.Array.Empty<object>());
        Assert.True(actual1);
        Assert.True(actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.True(context, ["true"]));
    }

    #endregion Logical

    #region Numeric

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Add()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Add(context, [5, (long)3]);
        var actual2 = (long)Functions.Add(context, [new JValue(5), 3]);
        Assert.Equal(8, actual1);
        Assert.Equal(8, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, ["one", "two"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void CopyIndex()
    {
        var context = GetContext();
        var copy = new CopyIndexState
        {
            Name = "test1",
            Count = 5
        };
        context.CopyIndex.Push(copy);
        copy.Next();

        // Integer
        var actual1 = (int)Functions.CopyIndex(context, [(long)3]);
        var actual2 = (int)Functions.CopyIndex(context, [new JValue(3)]);
        Assert.Equal(3, actual1);
        Assert.Equal(3, actual2);

        // String + Integer
        var actual3 = (int)Functions.CopyIndex(context, ["test1", 3]);
        var actual4 = (int)Functions.CopyIndex(context, [new JValue("test1"), new JValue(3)]);
        Assert.Equal(3, actual3);
        Assert.Equal(3, actual4);

        // String
        var actual5 = (int)Functions.CopyIndex(context, ["test1"]);
        var actual6 = (int)Functions.CopyIndex(context, [new JValue("test1")]);
        Assert.Equal(0, actual5);
        Assert.Equal(0, actual6);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Div()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Div(context, [8, (long)3]);
        var actual2 = (long)Functions.Div(context, [new JValue(8), 3]);
        Assert.Equal(2, actual1);
        Assert.Equal(2, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, ["one", "two"]));
        Assert.Throws<DivideByZeroException>(() => Functions.Div(context, [1, "0"]));
        Assert.Throws<DivideByZeroException>(() => Functions.Div(context, [8, 0]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Float()
    {
        var context = GetContext();

        // Integer
        var actual1 = (float)Functions.Float(context, [3]);
        Assert.Equal(3.0f, actual1);

        // String
        var actual2 = (float)Functions.Float(context, ["3.0"]);
        Assert.Equal(3.0f, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Float(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Float(context, System.Array.Empty<object>()));
        Assert.Throws<FormatException>(() => Functions.Float(context, ["one"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Int()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Int(context, [4]);
        Assert.Equal(4, actual1);

        // String
        var actual2 = (long)Functions.Int(context, ["4"]);
        Assert.Equal(4, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, ["one"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Mod()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Mod(context, [7, "3"]);
        Assert.Equal(1, actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, ["one", "two"]));
        Assert.Throws<DivideByZeroException>(() => Functions.Mod(context, [1, "0"]));
        Assert.Throws<DivideByZeroException>(() => Functions.Mod(context, [7, 0]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Mul()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Mul(context, [5, "3"]);
        var actual2 = (long)Functions.Mul(context, [new JValue(5), (long)3]);
        Assert.Equal(15, actual1);
        Assert.Equal(15, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, ["one", "two"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_NUMERIC)]
    public void Sub()
    {
        var context = GetContext();

        // Integer
        var actual1 = (long)Functions.Sub(context, [7, 3]);
        var actual2 = (long)Functions.Sub(context, [new JValue(7), 3]);
        Assert.Equal(4, actual1);
        Assert.Equal(4, actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, ["one", "two"]));
    }

    #endregion Numeric

    #region String

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Base64()
    {
        var context = GetContext();

        var actual1 = Functions.Base64(context, ["one, two, three"]) as string;
        var actual2 = Functions.Base64(context, ["{'one': 'a', 'two': 'b'}"]) as string;
        Assert.Equal("b25lLCB0d28sIHRocmVl", actual1);
        Assert.Equal("eydvbmUnOiAnYScsICd0d28nOiAnYid9", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Base64ToJson()
    {
        var context = GetContext();

        var actual1 = Functions.Base64ToJson(context, ["eydvbmUnOiAnYScsICd0d28nOiAnYid9"]) as JObject;
        Assert.Equal("a", actual1["one"]);
        Assert.Equal("b", actual1["two"]);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToJson(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToJson(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToJson(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Base64ToString()
    {
        var context = GetContext();

        var actual1 = Functions.Base64ToString(context, ["b25lLCB0d28sIHRocmVl"]) as string;
        Assert.Equal("one, two, three", actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToString(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToString(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToString(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void BuildUri()
    {
        var context = GetContext();

        var actual = Functions.BuildUri(context, [new JObject
        {
            {"scheme", "https" },
            {"host", "example.com"},
            {"port", 1234},
            {"path", "/foo/bar"},
        }]) as string;
        Assert.Equal("https://example.com:1234/foo/bar", actual);

        actual = Functions.BuildUri(context, [new JObject
        {
            {"scheme", "https" },
            {"host", "example.com"},
        }]) as string;
        Assert.Equal("https://example.com/", actual);

        actual = Functions.BuildUri(context, [new JObject
        {
            {"scheme", "https" },
            {"host", "example.com"},
            {"path", "/foo/bar"},
            {"query", "?a=1&b=2"},
        }]) as string;
        Assert.Equal("https://example.com/foo/bar?a=1&b=2", actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.BuildUri(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.BuildUri(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.BuildUri(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void DataUri()
    {
        var context = GetContext();

        var actual1 = Functions.DataUri(context, ["Hello"]) as string;
        Assert.Equal("data:text/plain;charset=utf8;base64,SGVsbG8=", actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.DataUri(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DataUri(context, System.Array.Empty<object>()));
        Assert.Throws<ArgumentException>(() => Functions.DataUri(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void DataUriToString()
    {
        var context = GetContext();

        var actual1 = Functions.DataUriToString(context, ["data:;base64,SGVsbG8sIFdvcmxkIQ=="]) as string;
        var actual2 = Functions.DataUriToString(context, ["data:,SGVsbG8sIFdvcmxkIQ=="]) as string;
        var actual3 = Functions.DataUriToString(context, ["data:text/plain;charset=utf8;base64,SGVsbG8="]) as string;
        Assert.Equal("Hello, World!", actual1);
        Assert.Equal("SGVsbG8sIFdvcmxkIQ==", actual2);
        Assert.Equal("Hello", actual3);

        Assert.Throws<ExpressionArgumentException>(() => Functions.DataUriToString(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.DataUriToString(context, System.Array.Empty<object>()));
        Assert.Throws<ArgumentException>(() => Functions.DataUriToString(context, [1]));
        Assert.Throws<ArgumentException>(() => Functions.DataUriToString(context, ["SGVsbG8sIFdvcmxkIQ=="]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void ParseUri()
    {
        var context = GetContext();

        var actual = Functions.ParseUri(context, ["https://example.com:1234/foo/bar"]) as JObject;
        Assert.Equal("https", actual["scheme"]);
        Assert.Equal("example.com", actual["host"]);
        Assert.Equal(1234, actual["port"]);
        Assert.Equal("/foo/bar", actual["path"]);
        Assert.False(actual.ContainsKey("query"));

        actual = Functions.ParseUri(context, ["https://example.com/"]) as JObject;
        Assert.Equal("https", actual["scheme"]);
        Assert.Equal("example.com", actual["host"]);
        Assert.Equal(JTokenType.Null, actual["port"].Type);
        Assert.False(actual.ContainsKey("path"));
        Assert.False(actual.ContainsKey("query"));

        actual = Functions.ParseUri(context, ["https://example.com/foo/bar?a=1&b=2"]) as JObject;
        Assert.Equal("https", actual["scheme"]);
        Assert.Equal("example.com", actual["host"]);
        Assert.Equal(JTokenType.Null, actual["port"].Type);
        Assert.Equal("/foo/bar", actual["path"]);
        Assert.Equal("?a=1&b=2", actual["query"]);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseUri(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseUri(context, []));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseUri(context, [1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void EndsWith()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.EndsWith(context, ["abcdef", "ef"]);
        var actual2 = (bool)Functions.EndsWith(context, ["abcdef", "F"]);
        var actual3 = (bool)Functions.EndsWith(context, ["abcdef", "e"]);
        Assert.True(actual1);
        Assert.True(actual2);
        Assert.False(actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Format()
    {
        var context = GetContext();

        var actual1 = Functions.Format(context, ["{0}, {1}. Formatted number: {2:N0}", "Hello", "User", 8175133]) as string;
        Assert.Equal("Hello, User. Formatted number: 8,175,133", actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Format(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Format(context, ["{0}"]));
        Assert.Throws<ArgumentException>(() => Functions.Format(context, [1, "1"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Guid()
    {
        var context = GetContext();

        var actual1 = Functions.Guid(context, ["abc"]) as string;
        var actual2 = Functions.Guid(context, ["abc", "efg"]) as string;
        var actual3 = Functions.Guid(context, ["abc"]) as string;
        Assert.Equal(36, actual1.Length);
        Assert.Equal("aea04463-c5e4-0660-08c9-c1a9fbfccf0b", actual1);
        Assert.NotEqual(actual2, actual1);
        Assert.Equal(actual3, actual1);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void IndexOf()
    {
        var context = GetContext();

        // String
        var actual1 = (long)Functions.IndexOf(context, ["test", "t"]);
        var actual2 = (long)Functions.IndexOf(context, ["abcdef", "CD"]);
        var actual3 = (long)Functions.IndexOf(context, ["abcdef", "z"]);
        Assert.Equal(0, actual1);
        Assert.Equal(2, actual2);
        Assert.Equal(-1, actual3);

        // Array
        var actual4 = (long)Functions.IndexOf(context, [new object[] { "one", "two", JToken.Parse("\"three\""), JToken.Parse("\"two\"") }, "two"]);
        var actual5 = (long)Functions.IndexOf(context, [new JArray(new object[] { "one", "two", "three", "two" }), JToken.Parse("\"two\"")]);
        var actual6 = (long)Functions.IndexOf(context, [new object[] { 1, 2, JToken.Parse("3"), JToken.Parse("2") }, 2]);
        var actual7 = (long)Functions.IndexOf(context, [new JArray(new object[] { 1, 2, 3, 2 }), JToken.Parse("2")]);
        var actual8 = (long)Functions.IndexOf(context, [new object[] { new object[] { 1, 2, 3 }, new object[] { 2, 3, 4 }, JToken.Parse("[ 3, 4, 5 ]"), JToken.Parse("[ 2, 3, 4 ]") }, JToken.Parse("[ 2, 3, 4 ]")]);
        var actual9 = (long)Functions.IndexOf(context, [new object[] { new object[] { 1, 2, 3 }, new object[] { 2, 3, 4 }, JToken.Parse("[ 3, 4, 5 ]"), JToken.Parse("[ 2, 3, 4 ]") }, new int[] { 2, 3, 4 }]);
        var actual10 = (long)Functions.IndexOf(context, [new object[] { JToken.Parse("{ \"items\": [ 1, 2, 3 ] }"), JToken.Parse("{ \"items\": [ 2, 3, 4] }"), JToken.Parse("{ \"items\": [ 2, 3, 4] }") }, JToken.Parse("{ \"items\": [ 2, 3, 4] }")]);

        Assert.Equal(1, actual4);
        Assert.Equal(1, actual5);
        Assert.Equal(1, actual6);
        Assert.Equal(1, actual7);
        Assert.Equal(1, actual8);
        Assert.Equal(1, actual9);
        Assert.Equal(1, actual10);

        // Array case-sensitive
        var actual12 = (long)Functions.IndexOf(context, [new object[] { "one", "Two", JToken.Parse("\"three\""), JToken.Parse("\"two\"") }, "two"]);
        var actual13 = (long)Functions.IndexOf(context, [new object[] { "one", "two", JToken.Parse("\"three\""), JToken.Parse("\"two\"") }, "Two"]);

        Assert.Equal(3, actual12);
        Assert.Equal(-1, actual13);

        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexOf(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.IndexOf(context, ["test"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void LastIndexOf()
    {
        var context = GetContext();

        // String
        var actual1 = (long)Functions.LastIndexOf(context, ["test", "t"]);
        var actual2 = (long)Functions.LastIndexOf(context, ["abcdef", "AB"]);
        var actual3 = (long)Functions.LastIndexOf(context, ["abcdef", "z"]);
        Assert.Equal(3, actual1);
        Assert.Equal(0, actual2);
        Assert.Equal(-1, actual3);

        // Array
        var actual4 = (long)Functions.LastIndexOf(context, [new object[] { "one", "two", JToken.Parse("\"three\""), JToken.Parse("\"two\"") }, "two"]);
        var actual5 = (long)Functions.LastIndexOf(context, [new JArray(new object[] { "one", "two", "three", "two" }), JToken.Parse("\"two\"")]);
        var actual6 = (long)Functions.LastIndexOf(context, [new object[] { 1, 2, JToken.Parse("3"), JToken.Parse("2") }, 2]);
        var actual7 = (long)Functions.LastIndexOf(context, [new JArray(new object[] { 1, 2, 3, 2 }), JToken.Parse("2")]);
        var actual8 = (long)Functions.LastIndexOf(context, [new JArray(new object[] { 1, 2, 3 }, new object[] { 2, 3, 4 }, JToken.Parse("[ 3, 4, 5 ]"), JToken.Parse("[ 2, 3, 4 ]")), JToken.Parse("[ 2, 3, 4 ]")]);
        var actual9 = (long)Functions.LastIndexOf(context, [new JArray(new object[] { 1, 2, 3 }, new object[] { 2, 3, 4 }, JToken.Parse("[ 3, 4, 5 ]"), JToken.Parse("[ 2, 3, 4 ]")), new int[] { 2, 3, 4 }]);
        var actual10 = (long)Functions.LastIndexOf(context, [new object[] { JToken.Parse("{ \"items\": [ 1, 2, 3 ] }"), JToken.Parse("{ \"items\": [ 2, 3, 4] }"), JToken.Parse("{ \"items\": [ 2, 3, 4] }") }, JToken.Parse("{ \"items\": [ 2, 3, 4] }")]);

        Assert.Equal(3, actual4);
        Assert.Equal(3, actual5);
        Assert.Equal(3, actual6);
        Assert.Equal(3, actual7);
        Assert.Equal(3, actual8);
        Assert.Equal(3, actual9);
        Assert.Equal(2, actual10);

        // Array case-sensitive
        var actual12 = (long)Functions.LastIndexOf(context, [new object[] { "one", "two", JToken.Parse("\"three\""), JToken.Parse("\"Two\"") }, "two"]);
        var actual13 = (long)Functions.LastIndexOf(context, [new object[] { "one", "two", JToken.Parse("\"three\""), JToken.Parse("\"two\"") }, "Two"]);
        Assert.Equal(1, actual12);
        Assert.Equal(-1, actual13);

        Assert.Throws<ExpressionArgumentException>(() => Functions.LastIndexOf(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.LastIndexOf(context, ["test"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Join()
    {
        var context = GetContext();

        var actual = Functions.Join(context, [new object[] { "one", JToken.Parse("\"two\""), "three" }, ","]) as string;
        Assert.Equal("one,two,three", actual);

        actual = Functions.Join(context, [new JArray("one", JToken.Parse("\"two\""), "three"), new JValue(",")]) as string;
        Assert.Equal("one,two,three", actual);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Join(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Join(context, ["test"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Join(context, [1, 1]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Join(context, [new int[] { 1, 2 }, 1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void NewGuid()
    {
        var context = GetContext();

        var actual1 = Functions.NewGuid(context, System.Array.Empty<object>()) as string;
        Assert.Equal(36, actual1.Length);

        Assert.Throws<ExpressionArgumentException>(() => Functions.NewGuid(context, ["test"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void PadLeft()
    {
        var context = GetContext();

        var actual1 = Functions.PadLeft(context, ["123", 10, "0"]) as string;
        var actual2 = Functions.PadLeft(context, ["123", 10]) as string;
        Assert.Equal("0000000123", actual1);
        Assert.Equal("       123", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, ["test"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, ["test", 10, "test", "test"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, [10, "10"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Replace()
    {
        var context = GetContext();

        var actual1 = Functions.Replace(context, ["This is a test", "i", "b"]) as string;
        var actual2 = Functions.Replace(context, ["This is a test", "test", "unit"]) as string;
        Assert.Equal("Thbs bs a test", actual1);
        Assert.Equal("This is a unit", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Replace(context, ["This is a test"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Replace(context, ["This is a test", 0, 0]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Split()
    {
        var context = GetContext();

        var actual = Functions.Split(context, ["This is a test", new string[] { " " }]) as JArray;
        Assert.Equal("This", actual[0]);
        Assert.Equal("test", actual[3]);

        actual = Functions.Split(context, ["This is a test", new object[] { new JValue(" ") }]) as JArray;
        Assert.Equal("This", actual[0]);
        Assert.Equal("test", actual[3]);

        actual = Functions.Split(context, [new JValue("This is a test"), new JArray(new object[] { " " })]) as JArray;
        Assert.Equal("This", actual[0]);
        Assert.Equal("test", actual[3]);

        actual = Functions.Split(context, [new JValue("one;two,three"), new JArray(new object[] { ";", "," })]) as JArray;
        Assert.Equal("one", actual[0]);
        Assert.Equal("two", actual[1]);
        Assert.Equal("three", actual[2]);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Split(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Split(context, ["test"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Split(context, [1, 1]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void StartsWith()
    {
        var context = GetContext();

        var actual1 = (bool)Functions.StartsWith(context, ["abcdef", "ab"]);
        var actual2 = (bool)Functions.StartsWith(context, ["abcdef", "A"]);
        var actual3 = (bool)Functions.StartsWith(context, ["abcdef", "e"]);
        Assert.True(actual1);
        Assert.True(actual2);
        Assert.False(actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void StringFn()
    {
        var context = GetContext();

        var actual1 = Functions.String(context, [JsonConvert.DeserializeObject("{\"valueA\":10,\"valueB\":\"Example Text\"}")]) as string;
        var actual2 = Functions.String(context, [JsonConvert.DeserializeObject("[\"a\",\"b\",\"c\"]")]) as string;
        var actual3 = Functions.String(context, [5]) as string;
        Assert.Equal("{\"valueA\":10,\"valueB\":\"Example Text\"}", actual1);
        Assert.Equal("[\"a\",\"b\",\"c\"]", actual2);
        Assert.Equal("5", actual3);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Substring()
    {
        var context = GetContext();

        var actual1 = Functions.Substring(context, ["This is a test", 0, 4]) as string;
        var actual2 = Functions.Substring(context, ["This is a test", 10]) as string;
        Assert.Equal("This", actual1);
        Assert.Equal("test", actual2);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void ToLower()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.ToLower(context, ["One Two Three"]) as string;
        var actual2 = Functions.ToLower(context, ["one two three"]) as string;
        Assert.Equal("one two three", actual1);
        Assert.Equal("one two three", actual2);

        // Char
        var actual3 = Functions.ToLower(context, ['o']) as string;
        var actual4 = Functions.ToLower(context, ['O']) as string;
        Assert.Equal("o", actual3);
        Assert.Equal("o", actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, ["One", "Two", "Three"]));
        Assert.Throws<ArgumentException>(() => Functions.ToLower(context, [2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void ToUpper()
    {
        var context = GetContext();

        // String
        var actual1 = Functions.ToUpper(context, ["One Two Three"]) as string;
        var actual2 = Functions.ToUpper(context, ["ONE TWO THREE"]) as string;
        Assert.Equal("ONE TWO THREE", actual1);
        Assert.Equal("ONE TWO THREE", actual2);

        // Char
        var actual3 = Functions.ToUpper(context, ['o']) as string;
        var actual4 = Functions.ToUpper(context, ['O']) as string;
        Assert.Equal("O", actual3);
        Assert.Equal("O", actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, ["One", "Two", "Three"]));
        Assert.Throws<ArgumentException>(() => Functions.ToUpper(context, [2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Trim()
    {
        var context = GetContext();

        var actual1 = Functions.Trim(context, ["    one two three   "]) as string;
        var actual2 = Functions.Trim(context, ["one two three"]) as string;
        Assert.Equal("one two three", actual1);
        Assert.Equal("one two three", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, ["One", "Two", "Three"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, [2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void UniqueString()
    {
        var context = GetContext();

        var actual1 = Functions.UniqueString(context, ["One"]) as string;
        var actual2 = Functions.UniqueString(context, ["One", "Two", "Three"]) as string;
        Assert.Equal("b0ef330613636", actual1);
        Assert.Equal("4b9fe86f643d6", actual2);

        Assert.Throws<ExpressionArgumentException>(() => Functions.UniqueString(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UniqueString(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UniqueString(context, ["One", 2, "Three"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void Uri()
    {
        var context = GetContext();

        var actual1 = Functions.Uri(context, ["http://contoso.org/firstpath", "myscript.sh"]) as string;
        var actual2 = Functions.Uri(context, ["http://contoso.org/firstpath/", "myscript.sh"]) as string;
        var actual3 = Functions.Uri(context, ["http://contoso.org/firstpath/azuredeploy.json", "myscript.sh"]) as string;
        var actual4 = Functions.Uri(context, ["http://contoso.org/firstpath/azuredeploy.json/", "myscript.sh"]) as string;
        Assert.Equal("http://contoso.org/myscript.sh", actual1);
        Assert.Equal("http://contoso.org/firstpath/myscript.sh", actual2);
        Assert.Equal("http://contoso.org/firstpath/myscript.sh", actual3);
        Assert.Equal("http://contoso.org/firstpath/azuredeploy.json/myscript.sh", actual4);

        Assert.Throws<ExpressionArgumentException>(() => Functions.Uri(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Uri(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.Uri(context, ["http://contoso.org/firstpath", 2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void UriComponent()
    {
        var context = GetContext();

        var actual1 = Functions.UriComponent(context, ["http://contoso.com/resources/nested/azuredeploy.json"]) as string;
        Assert.Equal("http%3a%2f%2fcontoso.com%2fresources%2fnested%2fazuredeploy.json", actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponent(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponent(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponent(context, [2]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_STRING)]
    public void UriComponentToString()
    {
        var context = GetContext();

        var actual1 = Functions.UriComponentToString(context, ["http%3a%2f%2fcontoso.com%2fresources%2fnested%2fazuredeploy.json"]) as string;
        Assert.Equal("http://contoso.com/resources/nested/azuredeploy.json", actual1);

        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponentToString(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponentToString(context, System.Array.Empty<object>()));
        Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponentToString(context, [2]));
    }

    #endregion String

    #region Lambda

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void Filter()
    {
        var context = GetContext();
        var dogs = JArray.Parse(@"[{""name"":""Evie"",""age"":5,""interests"":[""Ball"",""Frisbee""]},{""name"":""Casper"",""age"":3,""interests"":[""Other dogs""]},{""name"":""Indy"",""age"":2,""interests"":[""Butter""]},{""name"":""Kira"",""age"":8,""interests"":[""Rubs""]}]");
        var i = 0;

        ExpressionFnOuter comparer = c => dogs[i++]["age"].Value<int>() >= 5;
        var actual = Functions.Filter(context, [dogs, new LambdaExpressionFn("dog", comparer)]) as object[];
        Assert.Equal(2, actual.Length);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void Map()
    {
        var context = GetContext();
        var dogs = JArray.Parse(@"[{""name"":""Evie"",""age"":5,""interests"":[""Ball"",""Frisbee""]},{""name"":""Casper"",""age"":3,""interests"":[""Other dogs""]},{""name"":""Indy"",""age"":2,""interests"":[""Butter""]},{""name"":""Kira"",""age"":8,""interests"":[""Rubs""]}]");
        var i = 0;

        ExpressionFnOuter mapper = c => dogs[i++]["name"].Value<string>();
        var actual = Functions.Map(context, [dogs, new LambdaExpressionFn("dog", mapper)]) as object[];
        Assert.Equal(4, actual.Length);
        Assert.Equal("Evie", actual.OfType<string>().First());
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void Reduce()
    {
        var context = GetContext();
        var dogs = JArray.Parse(@"[{""name"":""Evie"",""age"":5,""interests"":[""Ball"",""Frisbee""]},{""name"":""Casper"",""age"":3,""interests"":[""Other dogs""]},{""name"":""Indy"",""age"":2,""interests"":[""Butter""]},{""name"":""Kira"",""age"":8,""interests"":[""Rubs""]}]");

        ExpressionFnOuter reducer = c =>
        {
            c.TryLambdaVariable("cur", out int cur);
            c.TryLambdaVariable("next", out JObject next);
            cur += next["age"].Value<int>();
            return cur;
        };
        var actual = (int)Functions.Reduce(context, [dogs, 0, new LambdaExpressionFn("cur", "next", reducer)]);
        Assert.Equal(18, actual);
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void Sort()
    {
        var context = GetContext();
        var dogs = JArray.Parse(@"[{""name"":""Evie"",""age"":5,""interests"":[""Ball"",""Frisbee""]},{""name"":""Casper"",""age"":3,""interests"":[""Other dogs""]},{""name"":""Indy"",""age"":2,""interests"":[""Butter""]},{""name"":""Kira"",""age"":8,""interests"":[""Rubs""]}]");

        ExpressionFnOuter sorter = c =>
        {
            c.TryLambdaVariable("a", out JObject a);
            c.TryLambdaVariable("b", out JObject b);
            return a["age"].Value<int>() < b["age"].Value<int>();
        };
        var actual = Functions.Sort(context, [dogs, new LambdaExpressionFn("a", "b", sorter)]) as object[];
        Assert.Equal(4, actual.Length);
        Assert.Equal("Kira", actual.OfType<JObject>().First()["name"].Value<string>());
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void MapValues()
    {
        var context = GetContext();
        var o = JObject.Parse("{ \"foo\": \"foo\" }");

        ExpressionFnOuter valueMapper = c =>
        {
            c.TryLambdaVariable("val", out JValue val);
            return val.Value<string>().ToUpper();
        };
        var actual = Functions.MapValues(context, [o, new LambdaExpressionFn("val", valueMapper)]) as JObject;
        Assert.Equal("FOO", actual["foo"].Value<string>());
    }

    [Fact]
    [Trait(TRAIT, TRAIT_LAMBDA)]
    public void GroupBy()
    {
        var context = GetContext();
        var o = JArray.Parse("[ \"foo\", \"bar\", \"baz\" ]");

        ExpressionFnOuter groupMapper = c =>
        {
            c.TryLambdaVariable("x", out JValue val);
            return val.Value<string>().Substring(0, 1);
        };
        var actual = Functions.GroupBy(context, [o, new LambdaExpressionFn("x", groupMapper)]) as JObject;
        Assert.Equal(new string[] { "foo" }, actual["f"].Values<string>());
        Assert.Equal(new string[] { "bar", "baz" }, actual["b"].Values<string>());
    }

    #endregion Lambda

    #region CIDR

    [Fact]
    [Trait(TRAIT, TRAIT_CIDR)]
    public void ParseCidr()
    {
        var context = GetContext();

        var actual = Functions.ParseCidr(context, ["10.144.0.0/20"]) as JObject;
        Assert.NotNull(actual);
        Assert.Equal("10.144.0.0", actual["network"].Value<string>());
        Assert.Equal("255.255.240.0", actual["netmask"].Value<string>());
        Assert.Equal("10.144.15.255", actual["broadcast"].Value<string>());
        Assert.Equal("10.144.0.1", actual["firstUsable"].Value<string>());
        Assert.Equal("10.144.15.254", actual["lastUsable"].Value<string>());
        Assert.Equal(20, actual["cidr"].Value<int>());

        actual = Functions.ParseCidr(context, ["10.144.1.1/32"]) as JObject;
        Assert.NotNull(actual);
        Assert.Equal("10.144.1.1", actual["network"].Value<string>());
        Assert.Equal("255.255.255.255", actual["netmask"].Value<string>());
        Assert.Equal("10.144.1.1", actual["broadcast"].Value<string>());
        Assert.Equal("10.144.1.1", actual["firstUsable"].Value<string>());
        Assert.Equal("10.144.1.1", actual["lastUsable"].Value<string>());
        Assert.Equal(32, actual["cidr"].Value<int>());

        actual = Functions.ParseCidr(context, ["fdad:3236:5555::/48"]) as JObject;
        Assert.NotNull(actual);
        Assert.Equal("fdad:3236:5555::", actual["network"].Value<string>());
        Assert.Equal("ffff:ffff:ffff::", actual["netmask"].Value<string>());
        Assert.False(actual.ContainsKeyInsensitive("broadcast"));
        Assert.Equal("fdad:3236:5555::", actual["firstUsable"].Value<string>());
        Assert.Equal("fdad:3236:5555:ffff:ffff:ffff:ffff:ffff", actual["lastUsable"].Value<string>());
        Assert.Equal(48, actual["cidr"].Value<int>());

        actual = Functions.ParseCidr(context, ["fdad:3236:5555::/128"]) as JObject;
        Assert.NotNull(actual);
        Assert.Equal("fdad:3236:5555::", actual["network"].Value<string>());
        Assert.Equal("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", actual["netmask"].Value<string>());
        Assert.False(actual.ContainsKeyInsensitive("broadcast"));
        Assert.Equal("fdad:3236:5555::", actual["firstUsable"].Value<string>());
        Assert.Equal("fdad:3236:5555::", actual["lastUsable"].Value<string>());
        Assert.Equal(128, actual["cidr"].Value<int>());

        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, ["one", "two"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, ["1000.144.0.0/20"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, ["1000.144.0.0.0.0.0.0.0.0.0.0.0.0/20"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ParseCidr(context, ["fdad:nnnn:5555::/48"]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_CIDR)]
    public void CidrSubnet()
    {
        var context = GetContext();

        // IPv4
        Assert.Equal("10.144.0.0/20", Functions.CidrSubnet(context, ["10.144.0.0/20", 20, 0]) as string);
        Assert.Equal("10.144.16.0/20", Functions.CidrSubnet(context, ["10.144.0.0/20", 20, 1]) as string);
        Assert.Equal("10.144.0.0/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 0]) as string);
        Assert.Equal("10.144.0.32/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 1]) as string);
        Assert.Equal("10.144.0.64/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 2]) as string);
        Assert.Equal("10.144.0.96/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 3]) as string);
        Assert.Equal("10.144.0.128/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 4]) as string);
        Assert.Equal("10.144.0.160/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 5]) as string);
        Assert.Equal("10.144.0.192/27", Functions.CidrSubnet(context, ["10.144.0.0/27", 27, 6]) as string);
        Assert.Equal("10.144.1.1/32", Functions.CidrSubnet(context, ["10.144.1.1/32", 32, 0]) as string);

        Assert.Equal("10.144.0.0/24", Functions.CidrSubnet(context, ["10.144.0.0/20", 24, 0]) as string);
        Assert.Equal("10.144.1.0/24", Functions.CidrSubnet(context, ["10.144.0.0/20", 24, 1]) as string);
        Assert.Equal("10.144.2.0/24", Functions.CidrSubnet(context, ["10.144.0.0/20", 24, 2]) as string);
        Assert.Equal("10.144.3.0/24", Functions.CidrSubnet(context, ["10.144.0.0/20", 24, 3]) as string);
        Assert.Equal("10.144.4.0/24", Functions.CidrSubnet(context, ["10.144.0.0/20", 24, 4]) as string);

        // IPv6
        Assert.Equal("fdad:3236:5555::/52", Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 52, 0]) as string);
        Assert.Equal("fdad:3236:5555:1000::/52", Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 52, 1]) as string);
        Assert.Equal("fdad:3236:5555:2000::/52", Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 52, 2]) as string);
        Assert.Equal("fdad:3236:5555:3000::/52", Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 52, 3]) as string);
        Assert.Equal("fdad:3236:5555:4000::/52", Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 52, 4]) as string);
        Assert.Equal("fdad:3236:5555::/128", Functions.CidrSubnet(context, ["fdad:3236:5555::/128", 128, 0]) as string);

        Assert.Throws<ExpressionArgumentException>(() => Functions.CidrSubnet(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.CidrSubnet(context, [5]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.CidrSubnet(context, ["fdad:3236:5555::/48", 200, 0]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_CIDR)]
    public void CidrHost()
    {
        var context = GetContext();

        // IPv4
        Assert.Equal("10.144.3.1", Functions.CidrHost(context, ["10.144.3.0/24", 0]) as string);
        Assert.Equal("10.144.3.2", Functions.CidrHost(context, ["10.144.3.0/24", 1]) as string);
        Assert.Equal("10.144.3.3", Functions.CidrHost(context, ["10.144.3.0/24", 2]) as string);
        Assert.Equal("10.144.3.4", Functions.CidrHost(context, ["10.144.3.0/24", 3]) as string);
        Assert.Equal("10.144.3.5", Functions.CidrHost(context, ["10.144.3.0/24", 4]) as string);

        // IPv6
        Assert.Equal("fdad:3236:5555:3000::1", Functions.CidrHost(context, ["fdad:3236:5555:3000::/52", 0]) as string);
        Assert.Equal("fdad:3236:5555:3000::2", Functions.CidrHost(context, ["fdad:3236:5555:3000::/52", 1]) as string);
        Assert.Equal("fdad:3236:5555:3000::3", Functions.CidrHost(context, ["fdad:3236:5555:3000::/52", 2]) as string);
        Assert.Equal("fdad:3236:5555:3000::4", Functions.CidrHost(context, ["fdad:3236:5555:3000::/52", 3]) as string);
        Assert.Equal("fdad:3236:5555:3000::5", Functions.CidrHost(context, ["fdad:3236:5555:3000::/52", 4]) as string);

        Assert.Throws<ExpressionArgumentException>(() => Functions.CidrHost(context, null));
        Assert.Throws<ExpressionArgumentException>(() => Functions.CidrHost(context, [5]));
    }

    #endregion CIDR

    #region Availability Zones

    [Fact]
    [Trait(TRAIT, TRAIT_AVAILABILITY_ZONES)]
    public void ToLogicalZone()
    {
        var context = GetContext();

        var actual1 = Functions.ToLogicalZone(context, ["00000000-0000-0000-0000-000000000000", "West US2", "westus2-az1"]) as string;
        var actual2 = Functions.ToLogicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus2", "eastus2-az3"]) as string;
        var actual3 = Functions.ToLogicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus2euap", "eastus2euap-az4"]) as string;
        var actual4 = Functions.ToLogicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus", "eastus-az4"]) as string;
        var actual5 = Functions.ToLogicalZone(context, ["00000000-0000-0000-0000-000000000000", "not-a-region", "not-a-region-az1"]) as string;
        Assert.Equal("1", actual1);
        Assert.Equal("3", actual2);
        Assert.Equal("4", actual3);
        Assert.Equal(string.Empty, actual4);
        Assert.Equal(string.Empty, actual5);

        // Invalid zone
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLogicalZone(context, ["n", "n"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLogicalZone(context, [5]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_AVAILABILITY_ZONES)]
    public void ToLogicalZones()
    {
        var context = GetContext();

        var actual1 = Functions.ToLogicalZones(context, ["00000000-0000-0000-0000-000000000000", "West US2", new string[] { "westus2-az1", "westus2-az2" }]) as JArray;
        var actual2 = Functions.ToLogicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus2", new string[] { "eastus2-az3" }]) as JArray;
        var actual3 = Functions.ToLogicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus2euap", new string[] { "eastus2euap-az4" }]) as JArray;
        var actual4 = Functions.ToLogicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus", new string[] { "eastus-az3", "eastus-az4" }]) as JArray;
        var actual5 = Functions.ToLogicalZones(context, ["00000000-0000-0000-0000-000000000000", "not-a-region", new string[] { "not-a-region-az1" }]) as JArray;
        Assert.Equal(["1", "2"], actual1.Values<string>());
        Assert.Equal(["3"], actual2.Values<string>());
        Assert.Equal(["4"], actual3.Values<string>());
        Assert.Equal(["3"], actual4.Values<string>());
        Assert.Equal([], actual5.Values<string>());

        // Invalid zone
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLogicalZones(context, ["n", "n"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToLogicalZones(context, [5]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_AVAILABILITY_ZONES)]
    public void ToPhysicalZone()
    {
        var context = GetContext();

        var actual1 = Functions.ToPhysicalZone(context, ["00000000-0000-0000-0000-000000000000", "West US2", "1"]) as string;
        var actual2 = Functions.ToPhysicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus2", "3"]) as string;
        var actual3 = Functions.ToPhysicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus2euap", "4"]) as string;
        var actual4 = Functions.ToPhysicalZone(context, ["00000000-0000-0000-0000-000000000000", "eastus", "4"]) as string;
        var actual5 = Functions.ToPhysicalZone(context, ["00000000-0000-0000-0000-000000000000", "not-a-region", "1"]) as string;
        Assert.Equal("westus2-az1", actual1);
        Assert.Equal("eastus2-az3", actual2);
        Assert.Equal("eastus2euap-az4", actual3);
        Assert.Equal(string.Empty, actual4);
        Assert.Equal(string.Empty, actual5);

        // Invalid zone
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToPhysicalZone(context, ["n", "n"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToPhysicalZone(context, [5]));
    }

    [Fact]
    [Trait(TRAIT, TRAIT_AVAILABILITY_ZONES)]
    public void ToPhysicalZones()
    {
        var context = GetContext();

        var actual1 = Functions.ToPhysicalZones(context, ["00000000-0000-0000-0000-000000000000", "West US2", new string[] { "1", "2" }]) as JArray;
        var actual2 = Functions.ToPhysicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus2", new string[] { "3" }]) as JArray;
        var actual3 = Functions.ToPhysicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus2euap", new string[] { "4" }]) as JArray;
        var actual4 = Functions.ToPhysicalZones(context, ["00000000-0000-0000-0000-000000000000", "eastus", new string[] { "3", "4" }]) as JArray;
        var actual5 = Functions.ToPhysicalZones(context, ["00000000-0000-0000-0000-000000000000", "not-a-region", new string[] { "1" }]) as JArray;
        Assert.Equal(["westus2-az1", "westus2-az2"], actual1.Values<string>());
        Assert.Equal(["eastus2-az3"], actual2.Values<string>());
        Assert.Equal(["eastus2euap-az4"], actual3.Values<string>());
        Assert.Equal(["eastus-az3"], actual4.Values<string>());
        Assert.Equal([], actual5.Values<string>());

        // Invalid zone
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToPhysicalZones(context, ["n", "n"]));
        Assert.Throws<ExpressionArgumentException>(() => Functions.ToPhysicalZones(context, [5]));
    }

    #endregion Availability Zones

    #region Complex scenarios

    [Fact]
    public void ComplexArrayReference()
    {
        var context = GetContext();
        var actual = Functions.Array(context, [Functions.Reference(context, [Functions.ExtensionResourceId(context, ["/subscriptions/000/resourceGroups/rg-001", "Microsoft.Resources/deployments", "deploy-001"])])]);

        Assert.IsType<JArray>(actual);
        Assert.Single(actual as JArray);
    }

    #endregion Complex scenarios

    #region Helper functions

    private static TemplateContext GetContext()
    {
        var context = new TemplateContext
        {
            ResourceGroup = ResourceGroupOption.Default,
            Subscription = SubscriptionOption.Default,
            Tenant = TenantOption.Default,
            ManagementGroup = ManagementGroupOption.Default,
            Deployer = DeployerOption.Default,
        };
        context.Load(JObject.Parse("{ \"parameters\": { \"name\": { \"value\": \"abcdef\" } } }"));
        return context;
    }

    private static TemplateContext GetContext(PSRuleOption option)
    {
        var context = new TemplateContext
        {
            ResourceGroup = option.Configuration.ResourceGroup,
            Subscription = option.Configuration.Subscription,
            Tenant = option.Configuration.Tenant,
            ManagementGroup = option.Configuration.ManagementGroup,
            Deployer = option.Configuration.Deployer,
        };
        context.Load(JObject.Parse("{ \"parameters\": { \"name\": { \"value\": \"abcdef\" } } }"));
        return context;
    }

    private static PSRuleOption GetOption(string fileName)
    {
        return PSRuleOption.FromFileOrDefault(GetSourcePath(fileName));
    }

    [DebuggerStepThrough]
    private static string GetSourcePath(string fileName)
    {
        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
    }

    #endregion Helper functions
}
