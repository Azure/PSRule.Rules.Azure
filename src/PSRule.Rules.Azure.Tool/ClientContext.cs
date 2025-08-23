// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Extensions.Logging;

namespace PSRule.Rules.Azure.Tool;

internal sealed class ClientContext(string workspacePath, bool debug)
{
    public string WorkspacePath { get; } = workspacePath;

    public ILogger Logger { get; } = LoggerFactory.Create(builder =>
    {
        builder.SetMinimumLevel(debug ? LogLevel.Debug : LogLevel.Information);
        builder.AddConsole();
    }).CreateLogger<ClientContext>();
}
