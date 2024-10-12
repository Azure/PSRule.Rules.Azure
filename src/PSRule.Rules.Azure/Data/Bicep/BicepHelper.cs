// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using PSRule.Rules.Azure.Runtime;

namespace PSRule.Rules.Azure.Data.Bicep;

/// <summary>
/// A helper for calling the Bicep CLI.
/// </summary>
internal sealed class BicepHelper
{
    private const int ERROR_FILE_NOT_FOUND = 2;
    private const string ENV_AZURE_BICEP_ARGS = "PSRULE_AZURE_BICEP_ARGS";
    private const string ENV_AZURE_BICEP_USE_AZURE_CLI = "PSRULE_AZURE_BICEP_USE_AZURE_CLI";

    private readonly PipelineContext _Context;
    private readonly RuntimeService _Service;
    private readonly int _Timeout;

    private static BicepInfo _Bicep;

    public BicepHelper(PipelineContext context, RuntimeService service)
    {
        _Context = context;
        _Service = service;
        _Timeout = _Service.Timeout;
    }

    internal sealed class BicepInfo
    {
        private readonly string _BinPath;
        private readonly bool _UseAzCLI;

        private BicepInfo(string version, string binPath, bool useAzCLI)
        {
            Version = version;
            _BinPath = binPath;
            _UseAzCLI = useAzCLI;
        }

        public string Version { get; }

        public static BicepInfo Create(string binPath, bool useAzCLI)
        {
            var version = GetVersionInfo(binPath, useAzCLI);
            return string.IsNullOrEmpty(version) ? null : new BicepInfo(version, binPath, useAzCLI);
        }

        public BicepProcess Spawn(string sourcePath, int timeout)
        {
            try
            {
                var args = GetBicepBuildArgs(sourcePath, _UseAzCLI);
                var startInfo = new ProcessStartInfo(_BinPath, args)
                {
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    WorkingDirectory = PSRuleOption.GetWorkingPath(),
                };
                return new BicepProcess(Process.Start(startInfo), timeout, Version);
            }
            catch (Exception ex)
            {
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCommandError, ex.Message), ex);
            }
        }

        private static string GetVersionInfo(string binPath, bool useAzCLI)
        {
            try
            {
                var args = GetBicepVersionArgs(useAzCLI);
                var versionStartInfo = new ProcessStartInfo(binPath, args)
                {
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    WorkingDirectory = PSRuleOption.GetWorkingPath(),
                };
                var bicep = new BicepProcess(Process.Start(versionStartInfo), 5);
                try
                {
                    if (bicep.WaitForExit(out _))
                        return TrimVersion(bicep.GetOutput());
                }
                finally
                {
                    bicep.Dispose();
                }
                return null;
            }
            catch (Exception ex)
            {
                if (ex is Win32Exception win32 && win32.NativeErrorCode == ERROR_FILE_NOT_FOUND)
                {
                    throw new BicepCompileException(PSRuleResources.BicepNotFound, ex);
                }
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCommandError, ex.Message), ex);
            }
        }

        private static string TrimVersion(string s)
        {
            if (string.IsNullOrEmpty(s))
                return string.Empty;

            s = s.Trim(' ', '\r', '\n');
            var versionParts = s.Split(' ');
            return versionParts.Length < 3 ? string.Empty : versionParts[versionParts.Length - 2];
        }
    }

    internal sealed class BicepProcess : IDisposable
    {
        private readonly Process _Process;
        private readonly StringBuilder _Output;
        private readonly StringBuilder _Error;
        private readonly AutoResetEvent _ErrorWait;
        private readonly AutoResetEvent _OutputWait;
        private readonly int _Interval;
        private readonly int _Timeout;

        private bool _Disposed;

        public BicepProcess(Process process, int timeout, string version = null)
        {
            _Output = new StringBuilder();
            _Error = new StringBuilder();
            _Interval = 1000;
            _Timeout = timeout;

            Version = version;
            _Process = process;
            _Process.ErrorDataReceived += Bicep_ErrorDataReceived;
            _Process.OutputDataReceived += Bicep_OutputDataReceived;

            _Process.BeginErrorReadLine();
            _Process.BeginOutputReadLine();

            _ErrorWait = new AutoResetEvent(false);
            _OutputWait = new AutoResetEvent(false);
        }

        public string Version { get; }

        public bool HasExited => _Process.HasExited;

        public bool WaitForExit(out int exitCode)
        {
            try
            {
                if (!_Process.HasExited)
                {
                    var timeoutCount = 0;
                    while (!_Process.WaitForExit(_Interval) && !_Process.HasExited && timeoutCount < _Timeout)
                        timeoutCount++;
                }

                exitCode = _Process.HasExited ? _Process.ExitCode : -1;
                return _Process.HasExited && _ErrorWait.WaitOne(_Interval) && _OutputWait.WaitOne();
            }
            catch (Exception ex)
            {
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCommandError, ex.Message), ex);
            }
        }

        public string GetOutput()
        {
            lock (_Output)
            {
                return _Output.ToString();
            }
        }

        public string GetError()
        {
            lock (_Error)
            {
                return _Error.ToString();
            }
        }

        private void Bicep_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            if (e.Data == null)
            {
                _OutputWait.Set();
            }
            else
            {
                lock (_Output)
                {
                    _Output.AppendLine(e.Data);
                }
            }
        }

        private void Bicep_ErrorDataReceived(object sender, DataReceivedEventArgs e)
        {
            if (e.Data == null)
            {
                _ErrorWait.Set();
            }
            else
            {
                var errors = GetErrorLine(e.Data);
                if (errors.Length == 0)
                    return;

                lock (_Error)
                {
                    for (var i = 0; i < errors.Length; i++)
                        _Error.AppendLine(errors[i]);
                }
            }
        }

        private static string[] GetErrorLine(string input)
        {
            var lines = input.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
            var result = new List<string>();
            for (var i = 0; i < lines.Length; i++)
                if (!lines[i].Contains(": Warning ") && !lines[i].Contains(": Info "))
                    result.Add(lines[i]);

            return result.ToArray();
        }

        private void Dispose(bool disposing)
        {
            if (!_Disposed)
            {
                if (disposing)
                {
                    _ErrorWait.Dispose();
                    _OutputWait.Dispose();
                    _Process.Dispose();
                }
                lock (_Error)
                {
                    _Error.Clear();
                }
                lock (_Output)
                {
                    _Output.Clear();
                }
                _Disposed = true;
            }
        }

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }

    /// <summary>
    /// The version of Bicep.
    /// </summary>
    internal string Version
    {
        get
        {
            _Bicep ??= GetBicepInfo();
            return _Bicep?.Version;
        }
    }

    internal PSObject[] ProcessFile(string templateFile, string parameterFile)
    {
        if (!File.Exists(templateFile))
            throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, templateFile), templateFile);

        var json = ReadBicepFile(templateFile);
        return json == null ? Array.Empty<PSObject>() : ProcessJson(json, templateFile, parameterFile);
    }

    internal PSObject[] ProcessParamFile(string parameterFile)
    {
        if (!File.Exists(parameterFile))
            throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, parameterFile), parameterFile);

        var json = ReadBicepFile(parameterFile);
        if (json == null || !json.TryGetProperty("templateJson", out var templateJson) || !json.TryGetProperty("parametersJson", out var parametersJson))
            return Array.Empty<PSObject>();

        return ProcessJson(JObject.Parse(templateJson), JObject.Parse(parametersJson), parameterFile);
    }

    private PSObject[] ProcessJson(JObject templateObject, string templateFile, string parameterFile)
    {
        var visitor = new RuleDataExportVisitor();

        // Load context
        var templateContext = new TemplateVisitor.TemplateContext(_Context);
        if (!string.IsNullOrEmpty(parameterFile))
        {
            var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);
            if (!File.Exists(rootedParameterFile))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterFileNotFound, rootedParameterFile), rootedParameterFile);

            try
            {
                var parametersObject = ReadJsonFile(rootedParameterFile);
                templateContext.Load(parametersObject);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, templateFile, parameterFile, inner.Message), inner, templateFile, parameterFile);
            }
        }

        // Process
        try
        {
            templateContext.SetSource(templateFile, parameterFile);
            visitor.Visit(templateContext, "helper", templateObject);
        }
        catch (Exception inner)
        {
            throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepExpandInvalid, templateFile, inner.Message), inner, templateFile, null);
        }

        // Return results
        return GetResources(templateContext);
    }

    private PSObject[] ProcessJson(JObject templateObject, JObject parametersObject, string parameterFile)
    {
        var visitor = new RuleDataExportVisitor();

        // Load context
        var templateContext = new TemplateVisitor.TemplateContext(_Context);
        try
        {
            templateContext.Load(parametersObject);
        }
        catch (Exception inner)
        {
            throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, null, parameterFile, inner.Message), inner, null, parameterFile);
        }

        // Process
        try
        {
            templateContext.SetSource(null, parameterFile);
            visitor.Visit(templateContext, "helper", templateObject);
        }
        catch (Exception inner)
        {
            throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepExpandInvalid, parameterFile, inner.Message), inner, null, parameterFile);
        }

        // Return results
        return GetResources(templateContext);
    }

    /// <summary>
    /// Get resulting resources from expansion.
    /// </summary>
    private static PSObject[] GetResources(TemplateVisitor.TemplateContext templateContext)
    {
        var results = new List<PSObject>();
        var serializer = new JsonSerializer();
        serializer.Converters.Add(new PSObjectJsonConverter());
        foreach (var resource in templateContext.GetResources())
            results.Add(resource.Value.ToObject<PSObject>(serializer));

        return results.ToArray();
    }

    private JObject ReadBicepFile(string path)
    {
        var bicep = GetBicep(path, _Timeout);
        if (bicep == null)
            throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepNotFound), null, path, null);

        try
        {
            if (!bicep.WaitForExit(out var exitCode) || exitCode != 0)
            {
                var error = bicep.HasExited ? bicep.GetError() : PSRuleResources.BicepCompileTimeout;
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCompileError, bicep.Version, path, error), null, path, bicep.Version);
            }

            try
            {
                using var reader = new JsonTextReader(new StringReader(bicep.GetOutput()));
                return JObject.Load(reader);
            }
            catch (Exception e)
            {
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCompileError, bicep.Version, path, e.Message), e, path, bicep.Version);
            }
        }
        finally
        {
            bicep.Dispose();
        }
    }

    private static JObject ReadJsonFile(string path)
    {
        using var stream = new StreamReader(path);
        using var reader = new JsonTextReader(stream);
        return JObject.Load(reader);
    }

    private BicepProcess GetBicep(string sourcePath, int timeout)
    {
        _Bicep ??= GetBicepInfo();
        return _Bicep?.Spawn(sourcePath, timeout);
    }

    private BicepInfo GetBicepInfo()
    {
        return _Service.Bicep ??= BicepInfo.Create(GetBinaryPath(out var useAzCLI), useAzCLI);
    }

    private string GetBinaryPath(out bool useAzCLI)
    {
        useAzCLI = false;
        return GetBicepEnvironmentVariable() ??
            GetAzCLIPath(out useAzCLI) ??
            GetBicepBinary();
    }

    private static string GetAzCLIPath(out bool useAzCLI)
    {
        useAzCLI = UseAzCLI();
        return useAzCLI ? GetAzBinaryName() : null;
    }

    /// <summary>
    /// Check if the <c>PSRULE_AZURE_BICEP_PATH</c> environment variable is set and use this path if set.
    /// </summary>
    private static string GetBicepEnvironmentVariable()
    {
        var binaryPath = Environment.GetEnvironmentVariable("PSRULE_AZURE_BICEP_PATH");
        return string.IsNullOrEmpty(binaryPath) ? null : binaryPath;
    }

    /// <summary>
    /// Get the file name of the Bicep CLI binary.
    /// </summary>
    private static string GetBicepBinary()
    {
        return RuntimeInformation.IsOSPlatform(OSPlatform.OSX) ||
            RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "bicep" : "bicep.exe";
    }

    /// <summary>
    /// Get the file name of the Azure CLI binary.
    /// </summary>
    private static string GetAzBinaryName()
    {
        return RuntimeInformation.IsOSPlatform(OSPlatform.OSX) ||
            RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "az" : "az.exe";
    }

    private static string GetBicepBuildArgs(string sourcePath, bool useAzCLI)
    {
        var command = GetBicepBuildCommand(sourcePath);
        var args = GetBicepBuildAdditionalArgs();
        return string.Concat(command, args, useAzCLI ? " --file" : string.Empty, " \"", sourcePath, "\"");
    }

    private static string GetBicepBuildCommand(string sourcePath)
    {
        return sourcePath.EndsWith(".bicepparam") ? "build-params --stdout " : "build --stdout ";
    }

    private static string GetBicepVersionArgs(bool useAzCLI)
    {
        return useAzCLI ? "version" : "--version";
    }

    /// <summary>
    /// Check if the <c>PSRULE_AZURE_BICEP_ARGS</c> environment variable is set.
    /// </summary>
    private static string GetBicepBuildAdditionalArgs()
    {
        return Environment.GetEnvironmentVariable(ENV_AZURE_BICEP_ARGS) ?? string.Empty;
    }

    /// <summary>
    /// Check if the <c>PSRULE_AZURE_BICEP_USE_AZURE_CLI</c> environment variable is set.
    /// </summary>
    private static bool UseAzCLI()
    {
        return EnvironmentHelper.Default.TryBool(ENV_AZURE_BICEP_USE_AZURE_CLI, out var value) && value;
    }
}
