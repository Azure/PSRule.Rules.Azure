// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;

namespace PSRule.Rules.Azure.BuildTool;

static class Program
{
    /// <summary>
    /// Entry point for tool.
    /// </summary>
    static async Task<int> Main(string[] args)
    {
        return await ClientBuilder.New().Parse(args).InvokeAsync();
    }
}
