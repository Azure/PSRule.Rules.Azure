// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Invocation;
using PSRule.Rules.Azure.BuildTool.Resources;

namespace PSRule.Rules.Azure.BuildTool;

internal sealed class ClientBuilder : CommandBuilder
{
    private ClientBuilder(RootCommand cmd) : base(cmd) { }

    public static ClientBuilder New()
    {
        var cmd = new RootCommand();
        return new ClientBuilder(cmd);
    }

    public ClientBuilder AddProviderResource()
    {
        var cmd = new Command("provider", CmdStrings.Provider_Description);
        cmd.AddOption(new Option<string>(
            ["--output-path"]
        ));
        cmd.Handler = CommandHandler.Create<ProviderResourceOption, InvocationContext>(ProviderResource.Build);
        Command.AddCommand(cmd);
        return this;
    }
}
