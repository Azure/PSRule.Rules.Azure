// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;
using System;
using System.IO;
using System.Linq;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class PathBuilderTests
    {
        [Fact]
        public void Build()
        {
            var builder = new PathBuilder(new NullLogger(), GetSourcePath(""),  "*.json");

            builder.Add(GetSourcePath("Resources.Parameters.json"));
            var actual1 = builder.Build();
            Assert.Single(actual1);
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual1[0].FullName);

            builder.Add(GetSourcePath("Resources.Parameter?.json"));
            var actual2 = builder.Build();
            Assert.Single(actual2);
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual2[0].FullName);

            builder.Add(GetSourcePath("*Parameters*.json"));
            var actual3 = builder.Build();
            Assert.Equal(2, actual3.Length);
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters.json")));
            Assert.NotNull(actual3.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters2.json")));

            builder.Add(GetSourcePath("*Parameters?.json"));
            var actual4 = builder.Build();
            Assert.Equal(2, actual4.Length);
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters.json")));
            Assert.NotNull(actual4.SingleOrDefault(f => f.FullName == GetSourcePath("Resources.Parameters2.json")));

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
