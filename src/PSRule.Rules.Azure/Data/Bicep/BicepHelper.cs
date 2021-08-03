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
using System.Threading;

namespace PSRule.Rules.Azure.Data.Bicep
{
    internal sealed class BicepHelper
    {
        private readonly PipelineContext Context;
        private readonly ResourceGroupOption _ResourceGroup;
        private readonly SubscriptionOption _Subscription;

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
                if (!bicep.HasExited)
                    bicep.WaitForExit();

                if (bicep.ExitCode != 0)
                {
                    var error = bicep.StandardError.ReadToEnd();
                    throw new BicepCompileException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.BicepCompileError, path, error), null, path);
                }

                using (var reader = new JsonTextReader(bicep.StandardOutput))
                {
                    return JObject.Load(reader);
                }
            }
            finally
            {
                bicep.Dispose();
            }
        }

        private Process GetBicep(string sourcePath)
        {
            if (!TryBicepPath(out string binaryPath) || string.IsNullOrEmpty(binaryPath))
                return null;

            var args = $"build --stdout --no-summary \"{sourcePath}\"";
            var startInfo = new ProcessStartInfo(binaryPath, args)
            {
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                WorkingDirectory = PSRuleOption.GetWorkingPath(),
            };
            Context.Writer.WriteDebug(Diagnostics.DebugRunningBicep, binaryPath);
            var p = Process.Start(startInfo);
            return p;
        }

        private static bool TryBicepPath(out string binaryPath)
        {
            if (TryBicepEnvVariable(out binaryPath))
                return true;

            var envPath = System.Environment.GetEnvironmentVariable("PATH");
            var paths = envPath.Split(';');
            var binName = GetBinaryName();
            for (var i = 0; paths != null && i < paths.Length; i++)
            {
                binaryPath = Path.Combine(paths[i], binName);
                if (File.Exists(binaryPath))
                    return true;
            }
            binaryPath = null;
            return false;
        }

        private static bool TryBicepEnvVariable(out string binaryPath)
        {
            binaryPath = System.Environment.GetEnvironmentVariable("PSRULE_AZURE_BICEP_PATH");
            return !string.IsNullOrEmpty(binaryPath);
        }

        private static string GetBinaryName()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                return "bicep";

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return "bicep.bin";

            return "bicep.exe";
        }
    }
}
