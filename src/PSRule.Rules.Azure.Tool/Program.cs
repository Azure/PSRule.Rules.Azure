// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Tool;

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
