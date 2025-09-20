// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using System.Reflection;

namespace PSRule.Rules.Azure.Tool;

/// <summary>
/// A helper to build the command-line commands and options offered to the caller.
/// </summary>
internal sealed class ClientBuilder
{
    private const string ARG_FORCE = "--force";

    internal static readonly string? Version = (Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly()).GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion;

    private readonly Option<string> _Global_Option;
    private readonly Option<bool> _Global_Debug;
    private readonly Option<bool> _Global_WaitForDebugger;
    private readonly Option<bool> _Global_InGitHubActions;
    private readonly Option<string> _Global_WorkspacePath;

    private ClientBuilder(RootCommand cmd)
    {
        Command = cmd;

        // Global options.
        _Global_Option = new Option<string>("--option")
        {
            Description = Resources.CmdStrings.Global_Option_Description,
            DefaultValueFactory = _ => "ps-rule.yaml"
        };
        _Global_Debug = new Option<bool>("--debug")
        {
            Description = Resources.CmdStrings.Global_Debug_Description,
            Recursive = true,
        };
        _Global_WorkspacePath = new Option<string>("--workspace-path")
        {
            Description = Resources.CmdStrings.Global_WorkspacePath_Description,
            DefaultValueFactory = _ => System.Environment.CurrentDirectory,
            Recursive = true,
        };

        // Arguments that are hidden because they are intercepted early in the process.
        _Global_WaitForDebugger = new Option<bool>("--wait-for-debugger")
        {
            Description = string.Empty,
            Hidden = true
        };
        _Global_InGitHubActions = new Option<bool>("--in-github-actions")
        {
            Description = string.Empty,
            Hidden = true
        };

        cmd.Add(_Global_Option);
        cmd.Add(_Global_Debug);
        cmd.Add(_Global_WorkspacePath);
        cmd.Add(_Global_WaitForDebugger);
        cmd.Add(_Global_InGitHubActions);
    }

    public RootCommand Command { get; }

    public static RootCommand New()
    {
        var cmd = new RootCommand(string.Concat(Resources.CmdStrings.Cmd_Description, " v", Version))
        {

        };
        var builder = new ClientBuilder(cmd);
        return builder.Command;
    }

    private ClientContext GetClientContext(ParseResult parseResult)
    {
        var option = parseResult.GetValue(_Global_Option);
        var debug = parseResult.GetValue(_Global_Debug);
        var workspacePath = parseResult.GetValue(_Global_WorkspacePath);

        if (string.IsNullOrWhiteSpace(workspacePath) || !Directory.Exists(workspacePath))
            throw new ArgumentException($"The workspace path '{workspacePath}' does not exist.");

        return new ClientContext(workspacePath, debug);
    }

    private static Uri? GetRegistryUri(string? registry)
    {
        return string.IsNullOrWhiteSpace(registry) ? null : new Uri($"https://{registry}");
    }
}
