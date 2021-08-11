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
        private StringBuilder _Output;
        private StringBuilder _Error;

        public BicepHelper(PipelineContext context, ResourceGroupOption resourceGroup, SubscriptionOption subscription)
        {
            Context = context;
            _ResourceGroup = resourceGroup;
            _Subscription = subscription;
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

        private JObject ReadFile(string path)
        {
            var bicep = GetBicep(path);
            if (bicep == null)
                throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepNotFound), null, path);

            try
            {
                _Output = new StringBuilder();
                _Error = new StringBuilder();

                bicep.ErrorDataReceived += Bicep_ErrorDataReceived;
                bicep.OutputDataReceived += Bicep_OutputDataReceived;

                bicep.BeginErrorReadLine();
                bicep.BeginOutputReadLine();

                if (!bicep.HasExited)
                {
                    var timeoutCount = 0;
                    while (!bicep.WaitForExit(1000) && !bicep.HasExited && timeoutCount < 3)
                        timeoutCount++;
                }

                if (!bicep.HasExited || bicep.ExitCode != 0)
                {
                    var error = bicep.HasExited ? _Error.ToString() : PSRuleResources.BicepCompileTimeout;
                    throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCompileError, path, error), null, path);
                }

                using (var reader = new JsonTextReader(new StringReader(_Output.ToString())))
                    return JObject.Load(reader);
            }
            finally
            {
                bicep.Dispose();
            }
        }

        private void Bicep_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            _Output.AppendLine(e.Data);
        }

        private void Bicep_ErrorDataReceived(object sender, DataReceivedEventArgs e)
        {
            _Error.AppendLine(e.Data);
        }

        private Process GetBicep(string sourcePath)
        {
            var useAzCLI = false;
            if (!(TryBicepPath(out string binPath) || TryAzCLIPath(out binPath, out useAzCLI)) || string.IsNullOrEmpty(binPath))
                return null;

            var args = GetBicepBuildArgs(sourcePath, useAzCLI);
            var startInfo = new ProcessStartInfo(binPath, args)
            {
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                //RedirectStandardInput = true,
                UseShellExecute = false,
                WorkingDirectory = PSRuleOption.GetWorkingPath(),
            };
            //Context.Writer.WriteDebug(Diagnostics.DebugRunningBicep, binaryPath);
            var p = Process.Start(startInfo);
            return p;
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
