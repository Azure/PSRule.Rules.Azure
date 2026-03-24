// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using PSRule.Rules.Azure.BuildTool.Resources;

namespace PSRule.Rules.Azure.BuildTool;

internal sealed class ClientBuilder
{
    private readonly Option<string> _Global_OutputPath;

    private ClientBuilder(RootCommand cmd)
    {
        Command = cmd;

        _Global_OutputPath = new Option<string>("--output-path");
    }

    /// <summary>
    /// Gets the configured root command.
    /// </summary>
    public RootCommand Command { get; }

    public static Command New()
    {
        var cmd = new RootCommand();
        var builder = new ClientBuilder(cmd)
            .AddProviderResource();

        return builder.Command;
    }

    public ClientBuilder AddProviderResource()
    {
        var cmd = new Command("provider", CmdStrings.Provider_Description)
        {
            _Global_OutputPath
        };

        cmd.SetAction(async (parse, cancellationToken) =>
        {
            var options = new ProviderResourceOption
            {
                OutputPath = parse.GetValue(_Global_OutputPath),
            };

            ProviderResource.Build(options);

        });

        Command.Add(cmd);
        return this;
    }
}
