// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Management.Automation;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// A delegate to allow callback to PowerShell to get current working path.
/// </summary>
internal delegate string PathDelegate();

/// <summary>
/// Options for configuration PSRule for Azure.
/// </summary>
public sealed class PSRuleOption
{
    private const string DEFAULT_FILENAME = "ps-rule.yaml";

    private string _SourcePath;

    internal static readonly PSRuleOption Default = new()
    {
        Configuration = ConfigurationOption.Default,
        Output = OutputOption.Default
    };

    /// <summary>
    /// A callback that is overridden by PowerShell so that the current working path can be retrieved.
    /// </summary>
    private static PathDelegate _GetWorkingPath = () => Directory.GetCurrentDirectory();

    /// <summary>
    /// Create an empty PSRule option.
    /// </summary>
    public PSRuleOption()
    {
        // Set defaults
        Configuration = new ConfigurationOption();
        Output = new OutputOption();
    }

    private PSRuleOption(string sourcePath, PSRuleOption option)
    {
        _SourcePath = sourcePath;

        // Set from existing option instance
        Configuration = new ConfigurationOption(option?.Configuration);
        Output = new OutputOption(option?.Output);
    }

    /// <summary>
    /// Options for configuring PSRule for Azure.
    /// </summary>
    public ConfigurationOption Configuration { get; set; }

    /// <summary>
    /// Options that affect how output is generated.
    /// </summary>
    public OutputOption Output { get; set; }

    /// <summary>
    /// Set working path from PowerShell host environment.
    /// </summary>
    /// <param name="executionContext">An $ExecutionContext object.</param>
    /// <remarks>
    /// Called from PowerShell.
    /// </remarks>
    public static void UseExecutionContext(EngineIntrinsics executionContext)
    {
        if (executionContext == null)
        {
            _GetWorkingPath = () => Directory.GetCurrentDirectory();
            return;
        }
        _GetWorkingPath = () => executionContext.SessionState.Path.CurrentFileSystemLocation.Path;
    }

    /// <summary>
    /// Get the current working path.
    /// </summary>
    public static string GetWorkingPath()
    {
        return _GetWorkingPath();
    }

    /// <summary>
    /// Load a YAML formatted PSRuleOption object from disk.
    /// </summary>
    /// <param name="path">A file or directory to read options from.</param>
    /// <returns>An options object.</returns>
    /// <remarks>
    /// This method is called from PowerShell.
    /// </remarks>
    public static PSRuleOption FromFileOrDefault(string path)
    {
        // Get a rooted file path instead of directory or relative path
        var filePath = GetFilePath(path);

        // Return empty options if file does not exist
        var result = !File.Exists(filePath) ? new PSRuleOption() : FromYaml(path: filePath, yaml: File.ReadAllText(filePath));
        return Combine(result, Default);
    }

    private static PSRuleOption Combine(PSRuleOption o1, PSRuleOption o2)
    {
        var result = new PSRuleOption(o1?._SourcePath ?? o2?._SourcePath, o1)
        {
            Configuration = ConfigurationOption.Combine(o1?.Configuration, o2?.Configuration),
            Output = OutputOption.Combine(o1?.Output, o2?.Output)
        };
        return result;
    }

    private static PSRuleOption FromYaml(string path, string yaml)
    {
        var d = new DeserializerBuilder()
            .IgnoreUnmatchedProperties()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();

        var option = d.Deserialize<PSRuleOption>(yaml) ?? new PSRuleOption();
        option._SourcePath = path;
        return option;
    }

    /// <summary>
    /// Get a fully qualified file path.
    /// </summary>
    /// <param name="path">A file or directory path.</param>
    /// <returns></returns>
    public static string GetFilePath(string path)
    {
        var rootedPath = GetRootedPath(path);
        if (Path.HasExtension(rootedPath))
        {
            var ext = Path.GetExtension(rootedPath);
            if (string.Equals(ext, ".yaml", StringComparison.OrdinalIgnoreCase) || string.Equals(ext, ".yml", StringComparison.OrdinalIgnoreCase))
            {
                return rootedPath;
            }
        }

        // Check if default files exist and 
        return UseFilePath(path: rootedPath, name: "ps-rule.yaml") ??
            UseFilePath(path: rootedPath, name: "ps-rule.yml") ??
            UseFilePath(path: rootedPath, name: "psrule.yaml") ??
            UseFilePath(path: rootedPath, name: "psrule.yml") ??
            Path.Combine(rootedPath, DEFAULT_FILENAME);
    }

    /// <summary>
    /// Get a full path instead of a relative path that may be passed from PowerShell.
    /// </summary>
    internal static string GetRootedPath(string path)
    {
        if (string.IsNullOrEmpty(path))
            return GetWorkingPath();

        return Path.IsPathRooted(path) ? path : Path.GetFullPath(Path.Combine(GetWorkingPath(), path));
    }

    /// <summary>
    /// Get a full path instead of a relative path that may be passed from PowerShell.
    /// </summary>
    internal static string GetRootedBasePath(string path)
    {
        var rootedPath = GetRootedPath(path);
        if (rootedPath.Length > 0 && IsSeparator(rootedPath[rootedPath.Length - 1]))
            return rootedPath;

        return File.Exists(rootedPath) ? rootedPath : string.Concat(rootedPath, Path.DirectorySeparatorChar);
    }

    internal static Dictionary<string, object> BuildIndex(Hashtable hashtable)
    {
        var index = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        foreach (DictionaryEntry entry in hashtable)
            index.Add(entry.Key.ToString(), entry.Value);

        return index;
    }

    /// <summary>
    /// Determine if the combined file path is exists.
    /// </summary>
    /// <param name="path">A directory path where a options file may be stored.</param>
    /// <param name="name">A file name of an options file.</param>
    /// <returns>Returns a file path if the file exists or null if the file does not exist.</returns>
    private static string UseFilePath(string path, string name)
    {
        var filePath = Path.Combine(path, name);
        return File.Exists(filePath) ? filePath : null;
    }

    [DebuggerStepThrough]
    private static bool IsSeparator(char c)
    {
        return c == Path.DirectorySeparatorChar || c == Path.AltDirectorySeparatorChar;
    }
}
