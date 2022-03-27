// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
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

namespace PSRule.Rules.Azure.Data.Bicep
{
    internal sealed class BicepHelper
    {
        private const int BICEP_TIMEOUT_MIN = 1;
        private const int BICEP_TIMEOUT_MAX = 120;

        private static readonly char[] LINUX_PATH_ENV_SEPARATOR = new char[] { ':' };
        private static readonly char[] WINDOWS_PATH_ENV_SEPARATOR = new char[] { ';' };

        private readonly PipelineContext Context;
        private readonly int _Timeout;

        private static BicepInfo _Bicep;

        public BicepHelper(PipelineContext context, int timeout)
        {
            Context = context;
            _Timeout = timeout < BICEP_TIMEOUT_MIN ? BICEP_TIMEOUT_MIN : timeout;
            if (_Timeout > BICEP_TIMEOUT_MAX)
                _Timeout = BICEP_TIMEOUT_MAX;
        }

        internal sealed class BicepInfo
        {
            private readonly string _BinPath;
            private readonly bool _UseAzCLI;

            private string _Version;

            public BicepInfo(string binPath, bool useAzCLI)
            {
                _BinPath = binPath;
                _UseAzCLI = useAzCLI;
            }

            internal BicepProcess Create(string sourcePath, int timeout)
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
                return new BicepProcess(Process.Start(startInfo), timeout, _Version);
            }

            internal void GetVersionInfo()
            {
                var args = GetBicepVersionArgs(_UseAzCLI);
                var versionStartInfo = new ProcessStartInfo(_BinPath, args)
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
                        _Version = TrimVersion(bicep.GetOutput());
                }
                finally
                {
                    bicep.Dispose();
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
                if (!_Process.HasExited)
                {
                    var timeoutCount = 0;
                    while (!_Process.WaitForExit(_Interval) && !_Process.HasExited && timeoutCount < _Timeout)
                        timeoutCount++;
                }

                exitCode = _Process.HasExited ? _Process.ExitCode : -1;
                return _Process.HasExited && _ErrorWait.WaitOne(_Interval) && _OutputWait.WaitOne();
            }

            public string GetOutput()
            {
                return _Output.ToString();
            }

            public string GetError()
            {
                return _Error.ToString();
            }

            private void Bicep_OutputDataReceived(object sender, DataReceivedEventArgs e)
            {
                if (e.Data == null)
                {
                    _OutputWait.Set();
                }
                else
                {
                    _Output.AppendLine(e.Data);
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
                    for (var i = 0; i < errors.Length; i++)
                        _Error.AppendLine(errors[i]);
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
                    _Error.Clear();
                    _Output.Clear();
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

        internal PSObject[] ProcessFile(string templateFile, string parameterFile)
        {
            if (!File.Exists(templateFile))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, templateFile), templateFile);

            var json = ReadBicepFile(templateFile);
            return json == null ? Array.Empty<PSObject>() : ProcessJson(json, templateFile, parameterFile);
        }

        internal PSObject[] ProcessJson(JObject templateObject, string templateFile, string parameterFile)
        {
            var visitor = new RuleDataExportVisitor();

            // Load context
            var templateContext = new TemplateVisitor.TemplateContext(Context);
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
                    using (var reader = new JsonTextReader(new StringReader(bicep.GetOutput())))
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
            using (var stream = new StreamReader(path))
            {
                using (var reader = new JsonTextReader(stream))
                {
                    return JObject.Load(reader);
                }
            }
        }

        private static BicepProcess GetBicep(string sourcePath, int timeout)
        {
            if (_Bicep == null)
                _Bicep = GetBicepInfo();

            return _Bicep?.Create(sourcePath, timeout);
        }

        private static BicepInfo GetBicepInfo()
        {
            var useAzCLI = false;
            if (!(TryBicepPath(out var binPath) || TryAzCLIPath(out binPath, out useAzCLI)) || string.IsNullOrEmpty(binPath))
                return null;

            var info = new BicepInfo(binPath, useAzCLI);
            info.GetVersionInfo();
            return info;
        }

        private static bool TryBicepPath(out string binPath)
        {
            return TryBicepEnvVariable(out binPath) || TryBinaryPath(GetBicepBinaryName(), out binPath);
        }

        private static bool TryAzCLIPath(out string binPath, out bool useAzCLI)
        {
            useAzCLI = false;
            binPath = null;
            return UseAzCLI() && TryBinaryPath(GetAzBinaryName(), out binPath);
        }

        private static bool TryBinaryPath(string bin, out string binPath)
        {
            var paths = GetPathEnv();
            for (var i = 0; paths != null && i < paths.Length; i++)
            {
                binPath = Path.Combine(paths[i], bin);
                if (File.Exists(binPath))
                    return true;
            }
            binPath = null;
            return false;
        }

        private static string[] GetPathEnv()
        {
            var envPath = Environment.GetEnvironmentVariable("PATH");
            return RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux)
                ? envPath.Split(LINUX_PATH_ENV_SEPARATOR, StringSplitOptions.RemoveEmptyEntries)
                : envPath.Split(WINDOWS_PATH_ENV_SEPARATOR, StringSplitOptions.RemoveEmptyEntries);
        }

        private static bool TryBicepEnvVariable(out string binaryPath)
        {
            binaryPath = Environment.GetEnvironmentVariable("PSRULE_AZURE_BICEP_PATH");
            return !string.IsNullOrEmpty(binaryPath);
        }

        private static string GetBicepBinaryName()
        {
            return RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "bicep" : "bicep.exe";
        }

        private static string GetAzBinaryName()
        {
            return RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "az" : "az.exe";
        }

        private static string GetBicepBuildArgs(string sourcePath, bool useAzCLI)
        {
            GetBicepBuildAdditionalArgs(out var args);
            return string.Concat("build --stdout ", args, useAzCLI ? " --file" : string.Empty, " \"", sourcePath, "\"");
        }

        private static string GetBicepVersionArgs(bool useAzCLI)
        {
            return useAzCLI ? "version" : "--version";
        }

        private static void GetBicepBuildAdditionalArgs(out string args)
        {
            args = System.Environment.GetEnvironmentVariable("PSRULE_AZURE_BICEP_ARGS") ?? string.Empty;
        }

        private static bool UseAzCLI()
        {
            return EnvironmentHelper.Default.TryBool("PSRULE_AZURE_BICEP_USE_AZURE_CLI", out var value) && value;
        }
    }
}
