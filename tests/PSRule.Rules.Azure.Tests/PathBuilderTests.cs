// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;
using System;
using System.IO;
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
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual3[0].FullName);
            Assert.Equal(GetSourcePath("Resources.Parameters2.json"), actual3[1].FullName);

            builder.Add(GetSourcePath("*Parameters?.json"));
            var actual4 = builder.Build();
            Assert.Equal(2, actual4.Length);
            Assert.Equal(GetSourcePath("Resources.Parameters.json"), actual4[0].FullName);
            Assert.Equal(GetSourcePath("Resources.Parameters2.json"), actual4[1].FullName);
        }

        private static string GetSourcePath(string fileName)
        {
            return Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName));
        }
    }
}
