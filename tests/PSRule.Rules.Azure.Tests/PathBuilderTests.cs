// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure
{
    public sealed class PathBuilderTests
    {
        [Fact]
        public void Build()
        {
            var builder = new PathBuilder(new NullLogger(), GetSourcePath(""), "*.json");

            builder.Add(GetSourcePath("Resources.Parameters.json"));
            var actual1 = builder.Build();
            Assert.Single(actual1);
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual1[0].FullName);

            builder.Add(GetSourcePath("Resources.Parameter?.json"));
            var actual2 = builder.Build();
            Assert.Single(actual2);
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual2[0].FullName);

            builder.Add(GetSourcePath("*Parameters*.json"));
            builder.Add(GetSourcePath("*parameters*.json"));
            var actual3 = builder.Build();
            Assert.Equal(11, actual3.Length);
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters2.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.1.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.2.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.3.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.2.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.9.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.10.Parameters.json")));

            builder.Add(GetSourcePath("*Parameters?.json"));
            builder.Add(GetSourcePath("*parameters?.json"));
            var actual4 = builder.Build();
            Assert.Equal(11, actual4.Length);
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters2.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.1.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.2.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.StrongType.3.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.2.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.9.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Template.Parsing.10.Parameters.json")));

            // With file path
            builder = new PathBuilder(new NullLogger(), GetSourcePath("Resources.Parameters.json"), "*.json");
            builder.Add("*.parameters.json");
            var actual5 = builder.Build();
            Assert.NotNull(actual5.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters.json")));
        }

        private static string GetSourcePath(string fileName)
        {
            return Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName));
        }
    }
}
