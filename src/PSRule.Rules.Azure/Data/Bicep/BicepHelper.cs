// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace PSRule.Rules.Azure.Data.Bicep
{
    internal sealed class BicepHelper
    {
        private static readonly char[] LINUX_PATH_ENV_SEPARATOR = new char[] { ':' };
        private static readonly char[] WINDOWS_PATH_ENV_SEPARATOR = new char[] { ';' };

        private readonly PipelineContext Context;
        private readonly ResourceGroupOption _ResourceGroup;
        private readonly SubscriptionOption _Subscription;

        private static BicepInfo _Bicep;

        public BicepHelper(PipelineContext context, ResourceGroupOption resourceGroup, SubscriptionOption subscription)
        {
            Context = context;
            _ResourceGroup = resourceGroup;
            _Subscription = subscription;
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

            internal BicepProcess Create(string sourcePath)
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
                return new BicepProcess(Process.Start(startInfo), _Version);
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
                var p = new BicepProcess(Process.Start(versionStartInfo));
                try
                {
                    if (p.WaitForExit(out _))
                        _Version = TrimVersion(p.GetOutput());
                }
                finally
                {
                    p.Process.Dispose();
                }
            }

            private static string TrimVersion(string s)
            {
                if (string.IsNullOrEmpty(s))
                    return string.Empty;

                s = s.Trim(' ', '\r', '\n');
                var versionParts = s.Split(' ');
                if (versionParts.Length < 3)
                    return string.Empty;

                return versionParts[versionParts.Length - 2];
            }
        }

        internal sealed class BicepProcess
        {
            private StringBuilder _Output;
            private StringBuilder _Error;

            public BicepProcess(Process process, string version = null)
            {
                _Output = new StringBuilder();
                _Error = new StringBuilder();

                Version = version;

                Process = process;
                Process.ErrorDataReceived += Bicep_ErrorDataReceived;
                Process.OutputDataReceived += Bicep_OutputDataReceived;

                Process.BeginErrorReadLine();
                Process.BeginOutputReadLine();
            }

            public Process Process { get; }

            public string Version { get; }

            public bool WaitForExit(out int exitCode)
            {
                if (!Process.HasExited)
                {
                    var timeoutCount = 0;
                    while (!Process.WaitForExit(1000) && !Process.HasExited && timeoutCount < 5)
                        timeoutCount++;
                }
                exitCode = Process.HasExited ? Process.ExitCode : -1;
                return Process.HasExited;
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
                _Output.AppendLine(e.Data);
            }

            private void Bicep_ErrorDataReceived(object sender, DataReceivedEventArgs e)
            {
                _Error.AppendLine(e.Data);
            }
        }

        internal PSObject[] ProcessFile(string sourcePath)
        {
            if (!File.Exists(sourcePath))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, sourcePath), sourcePath);

            var json = ReadFile(sourcePath);
            if (json == null)
                return Array.Empty<PSObject>();

            return ProcessJson(json, sourcePath);
        }

        internal PSObject[] ProcessJson(JObject templateObject, string sourcePath)
        {
            var visitor = new RuleDataExportVisitor();

            // Load context
            var templateContext = new TemplateVisitor.TemplateContext(Context, _Subscription, _ResourceGroup);

            // Process
            try
            {
                templateContext.SetSource(sourcePath, null);
                visitor.Visit(templateContext, "helper", templateObject);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepExpandInvalid, sourcePath, inner.Message), inner, sourcePath, null);
            }

            // Return results
            var results = new List<PSObject>();
            var serializer = new JsonSerializer();
            serializer.Converters.Add(new PSObjectJsonConverter());
            foreach (var resource in templateContext.GetResources())
                results.Add(resource.Value.ToObject<PSObject>(serializer));

            return results.ToArray();
        }

        private static JObject ReadFile(string path)
        {
            var bicep = GetBicep(path);
            if (bicep == null)
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepNotFound), null, path, null);

            try
            {
                if (!bicep.WaitForExit(out int exitCode) || exitCode != 0)
                {
                    var error = bicep.Process.HasExited ? bicep.GetError() : PSRuleResources.BicepCompileTimeout;
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
                bicep.Process.Dispose();
            }
        }

        private static BicepProcess GetBicep(string sourcePath)
        {
            if (_Bicep == null)
                _Bicep = GetBicepInfo();

            return _Bicep?.Create(sourcePath);
        }

        private static BicepInfo GetBicepInfo()
        {
            var useAzCLI = false;
            if (!(TryBicepPath(out string binPath) || TryAzCLIPath(out binPath, out useAzCLI)) || string.IsNullOrEmpty(binPath))
                return null;

            var info = new BicepInfo(binPath, useAzCLI);
            info.GetVersionInfo();
            return info;
        }

        private static bool TryBicepPath(out string binPath)
        {
            if (TryBicepEnvVariable(out binPath))
                return true;

            return TryBinaryPath(GetBicepBinaryName(), out binPath);
        }

        private static bool TryAzCLIPath(out string binPath, out bool useAzCLI)
        {
            useAzCLI = false;
            binPath = null;
            if (!UseAzCLI())
                return false;

            return TryBinaryPath(GetAzBinaryName(), out binPath);
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
            var envPath = System.Environment.GetEnvironmentVariable("PATH");
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return envPath.Split(LINUX_PATH_ENV_SEPARATOR, StringSplitOptions.RemoveEmptyEntries);

            return envPath.Split(WINDOWS_PATH_ENV_SEPARATOR, StringSplitOptions.RemoveEmptyEntries);
        }

        private static bool TryBicepEnvVariable(out string binaryPath)
        {
            binaryPath = System.Environment.GetEnvironmentVariable("PSRULE_AZURE_BICEP_PATH");
            return !string.IsNullOrEmpty(binaryPath);
        }

        private static string GetBicepBinaryName()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return "bicep";

            return "bicep.exe";
        }

        private static string GetAzBinaryName()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX) || RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return "az";

            return "az.exe";
        }

        private static string GetBicepBuildArgs(string sourcePath, bool useAzCLI)
        {
            GetBicepBuildAdditionalArgs(out string args);
            return string.Concat("build --stdout ", args, useAzCLI ? " --file" : string.Empty , " \"", sourcePath, "\"");
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
            return EnvironmentHelper.Default.TryBool("PSRULE_AZURE_BICEP_USE_AZURE_CLI", out bool value) ? value : false;
        }
    }
}
