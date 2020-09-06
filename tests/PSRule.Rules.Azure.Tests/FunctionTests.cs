// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using System;
using System.Globalization;
using Xunit;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class FunctionTests
    {
        private const string TRAIT = "Function";
        private const string TRAIT_ARRAY = "Array";
        private const string TRAIT_LOGICAL = "Logical";
        private const string TRAIT_COMPARISON = "Comparison";
        private const string TRAIT_DEPLOYMENT = "Deployment";
        private const string TRAIT_NUMERIC = "Numeric";
        private const string TRAIT_STRING = "String";
        private const string TRAIT_RESOURCE = "Resource";

        #region Array and object

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Array()
        {
            var context = GetContext();

            var actual1 = Functions.Array(context, new object[] { 1 }) as JArray;
            var actual2 = Functions.Array(context, new object[] { "efgh" }) as JArray;
            var actual3 = Functions.Array(context, new object[] { JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }") }) as JArray;
            Assert.Equal(1, actual1[0]);
            Assert.Equal("efgh", actual2[0]);
            Assert.Equal("b", actual3[0]["a"]);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Array(context, new object[] { "abcd", "efgh" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Coalesce()
        {
            var context = GetContext();

            var actual1 = Functions.Coalesce(context, new object[] { null, null, 1, 2, 3 });
            var actual2 = Functions.Coalesce(context, new object[] { null, null, "a", "b", "c" });
            var actual3 = Functions.Coalesce(context, new object[] { null, JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }") }) as JToken;
            var actual4 = Functions.Coalesce(context, new object[] { null });
            var actual5 = Functions.Coalesce(context, new object[] { null, null });
            Assert.Equal(1, actual1);
            Assert.Equal("a", actual2);
            Assert.Equal("b", actual3["a"]);
            Assert.Null(actual4);
            Assert.Null(actual5);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Coalesce(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Coalesce(context, new object[] { }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Concat()
        {
            var context = GetContext();

            // Concat arrays
            var actual1 = Functions.Concat(context, new string[][] { new string[] { "1-1", "1-2", "1-3" }, new string[] { "2-1", "2-2", "2-3" } }) as object[];
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
            var actual1 = (bool)Functions.Contains(context, new object[] { "OneTwoThree", "e" });
            var actual2 = (bool)Functions.Contains(context, new object[] { "OneTwoThree", "z" });
            Assert.True(actual1);
            Assert.False(actual2);

            // Object

            // Array
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void CreateArray()
        {
            var context = GetContext();

            var actual1 = Functions.CreateArray(context, new object[] { 1, 2, 3 }) as JArray;
            var actual2 = Functions.CreateArray(context, new object[] { "efgh" }) as JArray;
            var actual3 = Functions.CreateArray(context, new object[] { JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }"), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }") }) as JArray;
            Assert.Equal(3, actual1.Count);
            Assert.Equal(1, actual1[0]);
            Assert.Equal("efgh", actual2[0]);
            Assert.Equal("b", actual3[0]["a"]);
            Assert.Equal("h", actual3[1]["g"]);

            Assert.Throws<ExpressionArgumentException>(() => Functions.CreateArray(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.CreateArray(context, new object[] { }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Empty()
        {
            var context = GetContext();

            // String
            var actual1 = (bool)Functions.Empty(context, new object[] { "" });
            var actual2 = (bool)Functions.Empty(context, new object[] { "notEmpty"});
            Assert.True(actual1);
            Assert.False(actual2);

            // Object
            var actual3 = (bool)Functions.Empty(context, new object[] { JObject.Parse("{}") });
            var actual4 = (bool)Functions.Empty(context, new object[] { JObject.Parse("{ \"name\": \"test\" }") });
            Assert.True(actual3);
            Assert.False(actual4);

            // Array
            var actual5 = (bool)Functions.Empty(context, new object[] { new JArray() });
            var actual6 = (bool)Functions.Empty(context, new object[] { new JArray(JObject.Parse("{}")) });
            Assert.True(actual5);
            Assert.False(actual6);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void First()
        {
            var context = GetContext();

            // String
            var actual1 = (char)Functions.First(context, new object[] { "one" });
            Assert.Equal('o', actual1);

            // Array
            var actual2 = Functions.First(context, new object[] { new string[] { "one", "two", "three" } }) as string;
            Assert.Equal("one", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.First(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.First(context, new object[] { }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Intersection()
        {
            var context = GetContext();

            // String
            var actual1 = Functions.Intersection(context, new object[] { new JArray("one", "two", "three"), new JArray("two", "three") }) as JArray;
            Assert.Equal(2, actual1.Count);
            Assert.Equal("two", actual1[0]);
            Assert.Equal("three", actual1[1]);

            // Array
            var actual2 = Functions.Intersection(context, new object[] { JObject.Parse("{ \"one\": \"a\", \"two\": \"b\", \"three\": \"c\" }"), JObject.Parse("{ \"one\": \"a\", \"two\": \"z\", \"three\": \"c\" }") }) as JObject;
            Assert.Equal(2, actual2.Count);
            Assert.Equal("a", actual2["one"]);
            Assert.Equal("c", actual2["three"]);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Intersection(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Intersection(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Intersection(context, new object[] { "one", "two", "three" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Json()
        {
            var context = GetContext();

            var actual1 = Functions.Json(context, new object[] { "{ \"a\": \"b\" }" }) as JObject;
            Assert.Equal("b", actual1["a"]);

            Assert.Throws<ArgumentOutOfRangeException>(() => Functions.Json(context, null));
            Assert.Throws<ArgumentOutOfRangeException>(() => Functions.Json(context, new object[] { }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Last()
        {
            var context = GetContext();

            // String
            var actual1 = (char)Functions.Last(context, new object[] { "one" });
            Assert.Equal('e', actual1);

            // Array
            var actual2 = Functions.Last(context, new object[] { new string[] { "one", "two", "three" } }) as string;
            Assert.Equal("three", actual2);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Length()
        {
            var context = GetContext();

            // Length arrays
            var actual1 = (int)Functions.Length(context, new object[] { new string[] { "one", "two", "three" } });
            Assert.Equal(3, actual1);

            // Length strings
            var actual2 = (int)Functions.Length(context, new object[] { "One Two Three" });
            Assert.Equal(13, actual2);

            // Length objects
            var actual3 = (int)Functions.Length(context, new object[] { new TestLengthObject() });
            Assert.Equal(4, actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Length(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Length(context, new object[] { }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Max()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Max(context, new object[] { 6, 4, 8, 1, 2 });
            var actual2 = (int)Functions.Max(context, new object[] { 1, 1, 1 });
            var actual3 = (int)Functions.Max(context, new object[] { 1 });
            Assert.Equal(8, actual1);
            Assert.Equal(1, actual2);
            Assert.Equal(1, actual3);

            // Array
            var actual4 = (int)Functions.Max(context, new object[] { new JArray(new int[] { 6, 4, 8, 1, 2 }) });
            var actual5 = (int)Functions.Max(context, new object[] { new JArray(new int[] { 6, 4 }), 8 });
            var actual6 = (int)Functions.Max(context, new object[] { new JArray(new int[] { 6, 4 }), new JArray(new int[] { 8 }) });
            Assert.Equal(8, actual4);
            Assert.Equal(8, actual5);
            Assert.Equal(8, actual6);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Max(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Max(context, new object[] { "one", "two" }));
            Assert.Throws<ArgumentException>(() => Functions.Max(context, new object[] { 1, "0" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Min()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Min(context, new object[] { 6, 4, 8, 1, 2 });
            var actual2 = (int)Functions.Min(context, new object[] { 1, 1, 1 });
            var actual3 = (int)Functions.Min(context, new object[] { 1 });
            Assert.Equal(1, actual1);
            Assert.Equal(1, actual2);
            Assert.Equal(1, actual3);

            // Array
            var actual4 = (int)Functions.Min(context, new object[] { new JArray(new int[] { 6, 4, 8, 1, 2 }) });
            var actual5 = (int)Functions.Min(context, new object[] { new JArray(new int[] { 6, 4 }), 8 });
            var actual6 = (int)Functions.Min(context, new object[] { new JArray(new int[] { 6, 4 }), new JArray(new int[] { 8 }) });
            Assert.Equal(1, actual4);
            Assert.Equal(4, actual5);
            Assert.Equal(4, actual6);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Min(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Min(context, new object[] { "one", "two" }));
            Assert.Throws<ArgumentException>(() => Functions.Min(context, new object[] { 1, "0" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Range()
        {
            var context = GetContext();

            var actual1 = Functions.Range(context, new object[] { 1, 3 }) as JArray;
            var actual2 = Functions.Range(context, new object[] { 3, 10 }) as JArray;
            var actual3 = Functions.Range(context, new object[] { 1, 0 }) as JArray;
            Assert.Equal(3, actual1.Count);
            Assert.Equal(1, actual1[0]);
            Assert.Equal(2, actual1[1]);
            Assert.Equal(3, actual1[2]);
            Assert.Equal(10, actual2.Count);
            Assert.Equal(3, actual2[0]);
            Assert.Equal(12, actual2[9]);
            Assert.Empty(actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Range(context, new object[] { 1 }));
            Assert.Throws<ArgumentException>(() => Functions.Range(context, new object[] { "one", "two" }));
            Assert.Throws<ArgumentException>(() => Functions.Range(context, new object[] { 1, "0" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Skip()
        {
            var context = GetContext();

            // String
            var actual1 = Functions.Skip(context, new object[] { "one two three", 4 }) as string;
            var actual2 = Functions.Skip(context, new object[] { "one two three", 13 }) as string;
            var actual3 = Functions.Skip(context, new object[] { "one two three", -100 }) as string;
            Assert.Equal("two three", actual1);
            Assert.Equal("", actual2);
            Assert.Equal("one two three", actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, new object[] { "one two three" }));
            Assert.Throws<ArgumentException>(() => Functions.Skip(context, new object[] { "one two three", "0" }));

            // Array
            var actual4 = Functions.Skip(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 2 }) as JArray;
            var actual5 = Functions.Skip(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 3 }) as JArray;
            var actual6 = Functions.Skip(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), -100 }) as JArray;
            Assert.Equal("three", actual4[0]);
            Assert.Empty(actual5);
            Assert.Equal(3, actual6.Count);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Skip(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]") }));
            Assert.Throws<ArgumentException>(() => Functions.Skip(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), "0" }));
            Assert.Throws<ArgumentException>(() => Functions.Skip(context, new object[] { 1, "0" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Take()
        {
            var context = GetContext();

            // String
            var actual1 = Functions.Take(context, new object[] { "one two three", 3 }) as string;
            var actual2 = Functions.Take(context, new object[] { "one two three", 13 }) as string;
            var actual3 = Functions.Take(context, new object[] { "one two three", -100 }) as string;
            Assert.Equal("one", actual1);
            Assert.Equal("one two three", actual2);
            Assert.Equal("", actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, new object[] { "one two three" }));
            Assert.Throws<ArgumentException>(() => Functions.Take(context, new object[] { "one two three", "0" }));

            // Array
            var actual4 = Functions.Take(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 2 }) as JArray;
            var actual5 = Functions.Take(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), 3 }) as JArray;
            var actual6 = Functions.Take(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), -100 }) as JArray;
            Assert.Equal("one", actual4[0]);
            Assert.Equal("two", actual4[1]);
            Assert.Equal(3, actual5.Count);
            Assert.Empty(actual6);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Take(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]") }));
            Assert.Throws<ArgumentException>(() => Functions.Take(context, new object[] { JArray.Parse("[ \"one\", \"two\", \"three\" ]"), "0" }));
            Assert.Throws<ArgumentException>(() => Functions.Take(context, new object[] { 1, "0" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_ARRAY)]
        public void Union()
        {
            var context = GetContext();

            // Union objects
            var actual1 = Functions.Union(context, new object[] { JObject.Parse("{ \"a\": \"b\", \"c\": \"d\" }"), JObject.Parse("{ \"e\": \"f\", \"g\": \"h\" }"), JObject.Parse("{ \"i\": \"j\" }") }) as JObject;
            Assert.True(actual1.ContainsKey("a"));
            Assert.Equal("b", actual1["a"]);
            Assert.True(actual1.ContainsKey("e"));
            Assert.Equal("f", actual1["e"]);
            Assert.True(actual1.ContainsKey("i"));
            Assert.Equal("j", actual1["i"]);

            // Union arrays
            var actual2 = Functions.Union(context, new string[][] { new string[] { "one", "two", "three" }, new string[] { "three", "four" } }) as object[];
            Assert.Equal(4, actual2.Length);
        }

        #endregion Array and object

        #region Resource

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void ExtensionResourceId()
        {
            var context = GetContext();
            var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/a";

            var actual1 = Functions.ExtensionResourceId(context, new object[] { parentId, "Extension.Test/type", "a" }) as string;
            var actual2 = Functions.ExtensionResourceId(context, new object[] { parentId, "Extension.Test/type/subtype", "a", "b" }) as string;
            Assert.Equal(parentId + "/providers/Extension.Test/type/a", actual1);
            Assert.Equal(parentId + "/providers/Extension.Test/type/subtype/a/b", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, new object[] { "Extension.Test/type", "a" }));
            Assert.Throws<TemplateFunctionException>(() => Functions.ExtensionResourceId(context, new object[] { parentId, "Extension.Test/type", "a", "b" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ExtensionResourceId(context, new object[] { parentId, "Extension.Test/type", 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void List()
        {
            var context = GetContext();
            var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a";

            var actual1 = Functions.List(context, new object[] { parentId, "2019-01-01" }) as MockList;
            Assert.NotNull(actual1);

            // TODO: Improve test cases
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void Reference()
        {
            var context = GetContext();
            var parentId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a";

            var actual1 = Functions.Reference(context, new object[] { parentId }) as MockResource;
            Assert.NotNull(actual1);

            // TODO: Improve test cases
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void ResourceGroup()
        {
            var context = GetContext();

            var actual1 = Functions.ResourceGroup(context, null) as ResourceGroup;
            Assert.Equal("{{ResourceGroup.Name}}", actual1.Name);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void ResourceId()
        {
            var context = GetContext();

            var actual1 = Functions.ResourceId(context, new object[] { "Unit.Test/type", "a" }) as string;
            var actual2 = Functions.ResourceId(context, new object[] { "rg-test", "Unit.Test/type", "a" }) as string;
            var actual3 = Functions.ResourceId(context, new object[] { "00000000-0000-0000-0000-000000000000", "rg-test", "Unit.Test/type", "a" }) as string;
            var actual4 = Functions.ResourceId(context, new object[] { "Unit.Test/type/subtype", "a", "b" }) as string;
            var actual5 = Functions.ResourceId(context, new object[] { "rg-test", "Unit.Test/type/subtype", "a", "b" }) as string;
            var actual6 = Functions.ResourceId(context, new object[] { "00000000-0000-0000-0000-000000000000", "rg-test", "Unit.Test/type/subtype", "a", "b" }) as string;
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/resourceGroups/{{ResourceGroup.Name}}/providers/Unit.Test/type/a", actual1);
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/resourceGroups/rg-test/providers/Unit.Test/type/a", actual2);
            Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/a", actual3);
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/resourceGroups/{{ResourceGroup.Name}}/providers/Unit.Test/type/subtype/a/b", actual4);
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/resourceGroups/rg-test/providers/Unit.Test/type/subtype/a/b", actual5);
            Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Unit.Test/type/subtype/a/b", actual6);

            Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, new object[] { "Unit.Test/type" }));
            Assert.Throws<TemplateFunctionException>(() => Functions.ResourceId(context, new object[] { "Unit.Test/type", "a", "b" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ResourceId(context, new object[] { "Unit.Test/type", 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void Subscription()
        {
            var context = GetContext();

            var actual1 = Functions.Subscription(context, null) as Subscription;
            Assert.Equal("{{Subscription.Name}}", actual1.DisplayName);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void SubscriptionResourceId()
        {
            var context = GetContext();

            var actual1 = Functions.SubscriptionResourceId(context, new object[] { "Unit.Test/type", "a" } ) as string;
            var actual2 = Functions.SubscriptionResourceId(context, new object[] { "00000000-0000-0000-0000-000000000000", "Unit.Test/type", "a" }) as string;
            var actual3 = Functions.SubscriptionResourceId(context, new object[] { "Unit.Test/type/subtype", "a", "b" }) as string;
            var actual4 = Functions.SubscriptionResourceId(context, new object[] { "00000000-0000-0000-0000-000000000000", "Unit.Test/type/subtype", "a", "b" }) as string;
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/providers/Unit.Test/type/a", actual1);
            Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/a", actual2);
            Assert.Equal("/subscriptions/{{Subscription.SubscriptionId}}/providers/Unit.Test/type/subtype/a/b", actual3);
            Assert.Equal("/subscriptions/00000000-0000-0000-0000-000000000000/providers/Unit.Test/type/subtype/a/b", actual4);

            Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, new object[] { "Unit.Test/type" }));
            Assert.Throws<TemplateFunctionException>(() => Functions.SubscriptionResourceId(context, new object[] { "Unit.Test/type", "a", "b" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.SubscriptionResourceId(context, new object[] { "Unit.Test/type", 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_RESOURCE)]
        public void TenantResourceId()
        {
            var context = GetContext();

            var actual1 = Functions.TenantResourceId(context, new object[] { "Unit.Test/type", "a" }) as string;
            var actual2 = Functions.TenantResourceId(context, new object[] { "Unit.Test/type/subtype", "a", "b" }) as string;
            var actual3 = Functions.TenantResourceId(context, new object[] { "Unit.Test/type/subtype/subsubtype", "a", "b", "c" }) as string;
            Assert.Equal("/providers/Unit.Test/type/a", actual1);
            Assert.Equal("/providers/Unit.Test/type/subtype/a/b", actual2);
            Assert.Equal("/providers/Unit.Test/type/subtype/subsubtype/a/b/c", actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, new object[] { "Unit.Test/type" }));
            Assert.Throws<TemplateFunctionException>(() => Functions.TenantResourceId(context, new object[] { "00000000-0000-0000-0000-000000000000", "Unit.Test/type" }));
            Assert.Throws<TemplateFunctionException>(() => Functions.TenantResourceId(context, new object[] { "Unit.Test/type", "a", "b" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.TenantResourceId(context, new object[] { "Unit.Test/type", 1 }));
        }

        #endregion Resource

        #region Deployment

        [Fact]
        [Trait(TRAIT, TRAIT_DEPLOYMENT)]
        public void Deployment()
        {
            var context = GetContext();
            context.EnterDeployment("unit-test", JObject.Parse("{ \"contentVersion\": \"1.0.0.0\" }"));

            var actual1 = Functions.Deployment(context, null) as JObject;
            Assert.Equal("unit-test", actual1["name"]);
            Assert.Equal("1.0.0.0", actual1["properties"]["template"]["contentVersion"]);
            Assert.Equal("abcdef", actual1["properties"]["parameters"]["name"]["value"]);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Deployment(context, new object[] { 123 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_DEPLOYMENT)]
        public void Parameters()
        {
            var context = GetContext();
            context.Parameter("vnetName", "vnet1");
            context.Parameter("test", new TestLengthObject());

            // Parameters string
            var actual1 = Functions.Parameters(context, new object[] { "vnetName" });
            Assert.Equal("vnet1", actual1);

            // Parameters object
            var actual2 = Functions.Parameters(context, new object[] { "test" }) as TestLengthObject;
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
            var actual1 = Functions.Variables(context, new object[] { "vnetName" });
            Assert.Equal("vnet1", actual1);

            // Parameters object
            var actual2 = Functions.Variables(context, new object[] { "test" }) as TestLengthObject;
            Assert.Equal("two", actual2.propB);
        }

        #endregion Deployment

        #region Comparison

        [Fact]
        [Trait(TRAIT, TRAIT_COMPARISON)]
        public void Equal()
        {
            var context = GetContext();

            // int
            var actual1 = (bool)Functions.Equals(context, new object[] { 1, 2 });
            var actual2 = (bool)Functions.Equals(context, new object[] { 2, 1 });
            var actual3 = (bool)Functions.Equals(context, new object[] { 1, 1 });
            Assert.False(actual1);
            Assert.False(actual2);
            Assert.True(actual3);

            // string
            var actual4 = (bool)Functions.Equals(context, new object[] { "Test1", "Test2" });
            var actual5 = (bool)Functions.Equals(context, new object[] { "Test2", "Test1" });
            var actual6 = (bool)Functions.Equals(context, new object[] { "Test1", "Test1" });
            Assert.False(actual4);
            Assert.False(actual5);
            Assert.True(actual6);

            // array
            var actual7 = (bool)Functions.Equals(context, new object[] { new string[] { "a", "a" }, new string[] { "b", "b" } });
            var actual8 = (bool)Functions.Equals(context, new object[] { new string[] { "a", "b" }, new string[] { "a", "b" } });
            Assert.False(actual7);
            Assert.True(actual8);

            // object
            var actual9 = (bool)Functions.Equals(context, new object[] { new TestLengthObject() { propC = "four", propD = null }, new TestLengthObject() { propD = null }});
            var actual10 = (bool)Functions.Equals(context, new object[] { new TestLengthObject() { propD = null }, new TestLengthObject() { propD = null }});
            Assert.False(actual9);
            Assert.True(actual10);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_COMPARISON)]
        public void Greater()
        {
            var context = GetContext();

            // int
            var actual1 = (bool)Functions.Greater(context, new object[] { 1, 2 });
            var actual2 = (bool)Functions.Greater(context, new object[] { 2, 1 });
            var actual3 = (bool)Functions.Greater(context, new object[] { 1, 1 });
            Assert.False(actual1);
            Assert.True(actual2);
            Assert.False(actual3);

            // string
            var actual4 = (bool)Functions.Greater(context, new object[] { "Test1", "Test2" });
            var actual5 = (bool)Functions.Greater(context, new object[] { "Test2", "Test1" });
            var actual6 = (bool)Functions.Greater(context, new object[] { "Test1", "Test1" });
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
            var actual1 = (bool)Functions.GreaterOrEquals(context, new object[] { 1, 2 });
            var actual2 = (bool)Functions.GreaterOrEquals(context, new object[] { 2, 1 });
            var actual3 = (bool)Functions.GreaterOrEquals(context, new object[] { 1, 1 });
            Assert.False(actual1);
            Assert.True(actual2);
            Assert.True(actual3);

            // string
            var actual4 = (bool)Functions.GreaterOrEquals(context, new object[] { "Test1", "Test2" });
            var actual5 = (bool)Functions.GreaterOrEquals(context, new object[] { "Test2", "Test1" });
            var actual6 = (bool)Functions.GreaterOrEquals(context, new object[] { "Test1", "Test1" });
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
            var actual1 = (bool)Functions.Less(context, new object[] { 1, 2 });
            var actual2 = (bool)Functions.Less(context, new object[] { 2, 1 });
            var actual3 = (bool)Functions.Less(context, new object[] { 1, 1 });
            Assert.True(actual1);
            Assert.False(actual2);
            Assert.False(actual3);

            // string
            var actual4 = (bool)Functions.Less(context, new object[] { "Test1", "Test2" });
            var actual5 = (bool)Functions.Less(context, new object[] { "Test2", "Test1" });
            var actual6 = (bool)Functions.Less(context, new object[] { "Test1", "Test1" });
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
            var actual1 = (bool)Functions.LessOrEquals(context, new object[] { 1, 2 });
            var actual2 = (bool)Functions.LessOrEquals(context, new object[] { 2, 1 });
            var actual3 = (bool)Functions.LessOrEquals(context, new object[] { 1, 1 });
            Assert.True(actual1);
            Assert.False(actual2);
            Assert.True(actual3);

            // string
            var actual4 = (bool)Functions.LessOrEquals(context, new object[] { "Test1", "Test2" });
            var actual5 = (bool)Functions.LessOrEquals(context, new object[] { "Test2", "Test1" });
            var actual6 = (bool)Functions.LessOrEquals(context, new object[] { "Test1", "Test1" });
            Assert.True(actual4);
            Assert.False(actual5);
            Assert.True(actual6);
        }

        #endregion Comparison

        #region Logical

        [Fact]
        [Trait(TRAIT, TRAIT_LOGICAL)]
        public void And()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.And(context, new object[] { true, true, true });
            var actual2 = (bool)Functions.And(context, new object[] { true, true, false });
            var actual3 = (bool)Functions.And(context, new object[] { false, false });
            Assert.True(actual1);
            Assert.False(actual2);
            Assert.False(actual3);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_LOGICAL)]
        public void Bool()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.Bool(context, new object[] { "true" });
            var actual2 = (bool)Functions.Bool(context, new object[] { "false" });
            Assert.True(actual1);
            Assert.False(actual2);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_LOGICAL)]
        public void If()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.If(context, new object[] { true, true, false });
            var actual2 = (bool)Functions.If(context, new object[] { false, true, false });
            Assert.True(actual1);
            Assert.False(actual2);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_LOGICAL)]
        public void Not()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.Not(context, new object[] { true });
            var actual2 = (bool)Functions.Not(context, new object[] { false });
            Assert.False(actual1);
            Assert.True(actual2);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_LOGICAL)]
        public void Or()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.Or(context, new object[] { true, true, true });
            var actual2 = (bool)Functions.Or(context, new object[] { true, false });
            var actual3 = (bool)Functions.Or(context, new object[] { false, false, false });
            Assert.True(actual1);
            Assert.True(actual2);
            Assert.False(actual3);
        }

        #endregion Logical

        #region Numeric

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Add()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Add(context, new object[] { 5, 3 });
            Assert.Equal(8, actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, new object[] { 5 }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Add(context, new object[] { "one", "two" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Div()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Div(context, new object[] { 8, 3 });
            Assert.Equal(2, actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, new object[] { 5 }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Div(context, new object[] { "one", "two" }));
            Assert.Throws<DivideByZeroException>(() => Functions.Div(context, new object[] { 1, "0" }));
            Assert.Throws<DivideByZeroException>(() => Functions.Div(context, new object[] { 8, 0 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Float()
        {
            var context = GetContext();

            // Integer
            var actual1 = (float)Functions.Float(context, new object[] { 3 });
            Assert.Equal(3.0f, actual1);

            // String
            var actual2 = (float)Functions.Float(context, new object[] { "3.0" });
            Assert.Equal(3.0f, actual2);

            // String

            Assert.Throws<ExpressionArgumentException>(() => Functions.Float(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Float(context, new object[] { }));
            Assert.Throws<FormatException>(() => Functions.Float(context, new object[] { "one" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Int()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Int(context, new object[] { 4 });
            Assert.Equal(4, actual1);

            // String
            var actual2 = (int)Functions.Int(context, new object[] { "4" });
            Assert.Equal(4, actual2);

            // String

            Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Int(context, new object[] { "one" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Mod()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Mod(context, new object[] { 7, "3" });
            Assert.Equal(1, actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, new object[] { 5 }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Mod(context, new object[] { "one", "two" }));
            Assert.Throws<DivideByZeroException>(() => Functions.Mod(context, new object[] { 1, "0" }));
            Assert.Throws<DivideByZeroException>(() => Functions.Mod(context, new object[] { 7, 0 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Mul()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Mul(context, new object[] { 5, "3" });
            Assert.Equal(15, actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, new object[] { 5 }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Mul(context, new object[] { "one", "two" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_NUMERIC)]
        public void Sub()
        {
            var context = GetContext();

            // Integer
            var actual1 = (int)Functions.Sub(context, new object[] { 7, 3 });
            Assert.Equal(4, actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, new object[] { 5 }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Sub(context, new object[] { "one", "two" }));
        }

        #endregion Numeric

        #region String

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Base64()
        {
            var context = GetContext();

            var actual1 = Functions.Base64(context, new object[] { "one, two, three" }) as string;
            var actual2 = Functions.Base64(context, new object[] { "{'one': 'a', 'two': 'b'}" }) as string;
            Assert.Equal("b25lLCB0d28sIHRocmVl", actual1);
            Assert.Equal("eydvbmUnOiAnYScsICd0d28nOiAnYid9", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Base64(context, new object[] { 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Base64ToJson()
        {
            var context = GetContext();

            var actual1 = Functions.Base64ToJson(context, new object[] { "eydvbmUnOiAnYScsICd0d28nOiAnYid9" }) as JObject;
            Assert.Equal("a", actual1["one"]);
            Assert.Equal("b", actual1["two"]);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToJson(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToJson(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Base64ToJson(context, new object[] { 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Base64ToString()
        {
            var context = GetContext();

            var actual1 = Functions.Base64ToString(context, new object[] { "b25lLCB0d28sIHRocmVl" }) as string;
            Assert.Equal("one, two, three", actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToString(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Base64ToString(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Base64ToString(context, new object[] { 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void DataUri()
        {
            var context = GetContext();

            var actual1 = Functions.DataUri(context, new object[] { "Hello" }) as string;
            Assert.Equal("data:text/plain;charset=utf8;base64,SGVsbG8=", actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.DataUri(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.DataUri(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.DataUri(context, new object[] { 1 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void DataUriToString()
        {
            var context = GetContext();

            var actual1 = Functions.DataUriToString(context, new object[] { "data:;base64,SGVsbG8sIFdvcmxkIQ==" }) as string;
            var actual2 = Functions.DataUriToString(context, new object[] { "data:,SGVsbG8sIFdvcmxkIQ==" }) as string;
            var actual3 = Functions.DataUriToString(context, new object[] { "data:text/plain;charset=utf8;base64,SGVsbG8=" }) as string;
            Assert.Equal("Hello, World!", actual1);
            Assert.Equal("SGVsbG8sIFdvcmxkIQ==", actual2);
            Assert.Equal("Hello", actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.DataUriToString(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.DataUriToString(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.DataUriToString(context, new object[] { 1 }));
            Assert.Throws<ArgumentException>(() => Functions.DataUriToString(context, new object[] { "SGVsbG8sIFdvcmxkIQ==" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void EndsWith()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.EndsWith(context, new object[] { "abcdef", "ef" });
            var actual2 = (bool)Functions.EndsWith(context, new object[] { "abcdef", "F" });
            var actual3 = (bool)Functions.EndsWith(context, new object[] { "abcdef", "e" });
            Assert.True(actual1);
            Assert.True(actual2);
            Assert.False(actual3);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Format()
        {
            var context = GetContext();

            var actual1 = Functions.Format(context, new object[] { "{0}, {1}. Formatted number: {2:N0}", "Hello", "User", 8175133 }) as string;
            Assert.Equal("Hello, User. Formatted number: 8,175,133", actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Format(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Format(context, new object[] { "{0}" }));
            Assert.Throws<ArgumentException>(() => Functions.Format(context, new object[] { 1, "1" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Guid()
        {
            var context = GetContext();

            var actual1 = Functions.Guid(context, new object[] { "abc" }) as string;
            var actual2 = Functions.Guid(context, new object[] { "abc", "efg" }) as string;
            var actual3 = Functions.Guid(context, new object[] { "abc" }) as string;
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

            var actual1 = (int)Functions.IndexOf(context, new object[] { "test", "t" });
            var actual2 = (int)Functions.IndexOf(context, new object[] { "abcdef", "CD" });
            var actual3 = (int)Functions.IndexOf(context, new object[] { "abcdef", "z" });
            Assert.Equal(0, actual1);
            Assert.Equal(2, actual2);
            Assert.Equal(-1, actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.IndexOf(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.IndexOf(context, new object[] { "test" }));
            Assert.Throws<ArgumentException>(() => Functions.IndexOf(context, new object[] { 0, 0 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void LastIndexOf()
        {
            var context = GetContext();

            var actual1 = (int)Functions.LastIndexOf(context, new object[] { "test", "t" });
            var actual2 = (int)Functions.LastIndexOf(context, new object[] { "abcdef", "AB" });
            var actual3 = (int)Functions.LastIndexOf(context, new object[] { "abcdef", "z" });
            Assert.Equal(3, actual1);
            Assert.Equal(0, actual2);
            Assert.Equal(-1, actual3);

            Assert.Throws<ExpressionArgumentException>(() => Functions.LastIndexOf(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.LastIndexOf(context, new object[] { "test" }));
            Assert.Throws<ArgumentException>(() => Functions.LastIndexOf(context, new object[] { 0, 0 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void NewGuid()
        {
            var context = GetContext();

            var actual1 = Functions.NewGuid(context, new object[] { }) as string;
            Assert.Equal(36, actual1.Length);

            Assert.Throws<ExpressionArgumentException>(() => Functions.NewGuid(context, new object[] { "test" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void PadLeft()
        {
            var context = GetContext();

            var actual1 = Functions.PadLeft(context, new object[] { "123", 10, "0" }) as string;
            var actual2 = Functions.PadLeft(context, new object[] { "123", 10 }) as string;
            Assert.Equal("0000000123", actual1);
            Assert.Equal("       123", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, new object[] { "test" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, new object[] { "test", 10, "test", "test" }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.PadLeft(context, new object[] { 10, "10" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Replace()
        {
            var context = GetContext();

            var actual1 = Functions.Replace(context, new object[] { "This is a test", "i", "b" }) as string;
            var actual2 = Functions.Replace(context, new object[] { "This is a test", "test", "unit" }) as string;
            Assert.Equal("Thbs bs a test", actual1);
            Assert.Equal("This is a unit", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Replace(context, new object[] { "This is a test" }));
            Assert.Throws<ArgumentException>(() => Functions.Replace(context, new object[] { "This is a test", 0, 0 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Split()
        {
            var context = GetContext();

            var actual1 = Functions.Split(context, new object[] { "This is a test", new string[] { " " } }) as JArray;
            Assert.Equal("This", actual1[0]);
            Assert.Equal("test", actual1[3]);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void StartsWith()
        {
            var context = GetContext();

            var actual1 = (bool)Functions.StartsWith(context, new object[] { "abcdef", "ab" });
            var actual2 = (bool)Functions.StartsWith(context, new object[] { "abcdef", "A" });
            var actual3 = (bool)Functions.StartsWith(context, new object[] { "abcdef", "e" });
            Assert.True(actual1);
            Assert.True(actual2);
            Assert.False(actual3);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void StringFn()
        {
            var context = GetContext();

            var actual1 = Functions.String(context, new object[] { JsonConvert.DeserializeObject("{\"valueA\":10,\"valueB\":\"Example Text\"}") }) as string;
            var actual2 = Functions.String(context, new object[] { JsonConvert.DeserializeObject("[\"a\",\"b\",\"c\"]") }) as string;
            var actual3 = Functions.String(context, new object[] { 5 }) as string;
            Assert.Equal("{\"valueA\":10,\"valueB\":\"Example Text\"}", actual1);
            Assert.Equal("[\"a\",\"b\",\"c\"]", actual2);
            Assert.Equal("5", actual3);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Substring()
        {
            var context = GetContext();

            var actual1 = Functions.Substring(context, new object[] { "This is a test", 0, 4 }) as string;
            var actual2 = Functions.Substring(context, new object[] { "This is a test", 10 }) as string;
            Assert.Equal("This", actual1);
            Assert.Equal("test", actual2);
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void ToLower()
        {
            var context = GetContext();

            var actual1 = Functions.ToLower(context, new object[] { "One Two Three" }) as string;
            var actual2 = Functions.ToLower(context, new object[] { "one two three" }) as string;
            Assert.Equal("one two three", actual1);
            Assert.Equal("one two three", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ToLower(context, new object[] { "One", "Two", "Three" }));
            Assert.Throws<ArgumentException>(() => Functions.ToLower(context, new object[] { 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void ToUpper()
        {
            var context = GetContext();

            var actual1 = Functions.ToUpper(context, new object[] { "One Two Three" }) as string;
            var actual2 = Functions.ToUpper(context, new object[] { "ONE TWO THREE" }) as string;
            Assert.Equal("ONE TWO THREE", actual1);
            Assert.Equal("ONE TWO THREE", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.ToUpper(context, new object[] { "One", "Two", "Three" }));
            Assert.Throws<ArgumentException>(() => Functions.ToUpper(context, new object[] { 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Trim()
        {
            var context = GetContext();

            var actual1 = Functions.Trim(context, new object[] { "    one two three   " }) as string;
            var actual2 = Functions.Trim(context, new object[] { "one two three" }) as string;
            Assert.Equal("one two three", actual1);
            Assert.Equal("one two three", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, new object[] { }));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Trim(context, new object[] { "One", "Two", "Three" }));
            Assert.Throws<ArgumentException>(() => Functions.Trim(context, new object[] { 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void UniqueString()
        {
            var context = GetContext();

            var actual1 = Functions.UniqueString(context, new object[] { "One" }) as string;
            var actual2 = Functions.UniqueString(context, new object[] { "One", "Two", "Three" }) as string;
            Assert.Equal("b0ef330613636", actual1);
            Assert.Equal("4b9fe86f643d6", actual2);

            Assert.Throws<ExpressionArgumentException>(() => Functions.UniqueString(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.UniqueString(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.UniqueString(context, new object[] { "One", 2, "Three" }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void Uri()
        {
            var context = GetContext();

            var actual1 = Functions.Uri(context, new object[] { "http://contoso.org/firstpath", "myscript.sh" }) as string;
            var actual2 = Functions.Uri(context, new object[] { "http://contoso.org/firstpath/", "myscript.sh" }) as string;
            var actual3 = Functions.Uri(context, new object[] { "http://contoso.org/firstpath/azuredeploy.json", "myscript.sh" }) as string;
            var actual4 = Functions.Uri(context, new object[] { "http://contoso.org/firstpath/azuredeploy.json/", "myscript.sh" }) as string;
            Assert.Equal("http://contoso.org/myscript.sh", actual1);
            Assert.Equal("http://contoso.org/firstpath/myscript.sh", actual2);
            Assert.Equal("http://contoso.org/firstpath/myscript.sh", actual3);
            Assert.Equal("http://contoso.org/firstpath/azuredeploy.json/myscript.sh", actual4);

            Assert.Throws<ExpressionArgumentException>(() => Functions.Uri(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.Uri(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.Uri(context, new object[] { "http://contoso.org/firstpath", 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void UriComponent()
        {
            var context = GetContext();

            var actual1 = Functions.UriComponent(context, new object[] { "http://contoso.com/resources/nested/azuredeploy.json"}) as string;
            Assert.Equal("http%3a%2f%2fcontoso.com%2fresources%2fnested%2fazuredeploy.json", actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponent(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponent(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.UriComponent(context, new object[] { 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void UriComponentToString()
        {
            var context = GetContext();

            var actual1 = Functions.UriComponentToString(context, new object[] { "http%3a%2f%2fcontoso.com%2fresources%2fnested%2fazuredeploy.json" }) as string;
            Assert.Equal("http://contoso.com/resources/nested/azuredeploy.json", actual1);

            Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponentToString(context, null));
            Assert.Throws<ExpressionArgumentException>(() => Functions.UriComponentToString(context, new object[] { }));
            Assert.Throws<ArgumentException>(() => Functions.UriComponentToString(context, new object[] { 2 }));
        }

        [Fact]
        [Trait(TRAIT, TRAIT_STRING)]
        public void UtcNow()
        {
            var context = GetContext();
            var utc = DateTime.UtcNow;

            var actual1 = Functions.UtcNow(context, new object[] { }) as string;
            var actual2 = Functions.UtcNow(context, new object[] { "d" }) as string;
            var actual3 = Functions.UtcNow(context, new object[] { "M d" }) as string;
            Assert.Matches("[0-9]{8}T[0-9]{6}Z", actual1);
            Assert.Equal(utc.ToString("d", new CultureInfo("en-US")), actual2);
            Assert.Equal(utc.ToString("M d", new CultureInfo("en-US")), actual3);
        }

        #endregion String

        private static TemplateContext GetContext()
        {
            var context = new TemplateContext();
            context.ResourceGroup = new ResourceGroup();
            context.Subscription = new Subscription();
            context.Load(JObject.Parse("{ \"parameters\": { \"name\": { \"value\": \"abcdef\" } } }"));
            return context;
        }
    }

    internal sealed class TestLengthObject
    {
        public TestLengthObject()
        {
            propC = "three";
            propD = new ChildObject();
        }

        internal sealed class ChildObject
        {
            public string prop1 => "sub";

            public string prop2 => "sub";
        }

        public string propA => "one";

        public string propB => "two";

        public string propC { get; set; }

        public ChildObject propD { get; set; }
    }
}
