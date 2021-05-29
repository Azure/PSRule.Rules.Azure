// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Threading;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class TemplateHelper
    {
        private readonly PipelineContext Context;
        private readonly string _DeploymentName;
        private readonly ResourceGroupOption _ResourceGroup;
        private readonly SubscriptionOption _Subscription;

        public TemplateHelper(PipelineContext context, string deploymentName, ResourceGroupOption resourceGroup, SubscriptionOption subscription)
        {
            Context = context;
            _DeploymentName = deploymentName;
            _ResourceGroup = resourceGroup;
            _Subscription = subscription;
        }

        internal PSObject[] ProcessTemplate(string templateFile, string parameterFile, out TemplateVisitor.TemplateContext templateContext)
        {
            var rootedTemplateFile = PSRuleOption.GetRootedPath(templateFile);
            if (!File.Exists(rootedTemplateFile))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, rootedTemplateFile), rootedTemplateFile);

            var templateObject = ReadFile(rootedTemplateFile);
            var visitor = new RuleDataExportVisitor();

            // Load context
            templateContext = new TemplateVisitor.TemplateContext(Context, _Subscription, _ResourceGroup);
            if (!string.IsNullOrEmpty(parameterFile))
            {
                var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);
                if (!File.Exists(rootedParameterFile))
                    throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterFileNotFound, rootedParameterFile), rootedParameterFile);

                try
                {
                    var parametersObject = ReadFile(rootedParameterFile);
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
                visitor.Visit(templateContext, _DeploymentName, templateObject);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, templateFile, parameterFile, inner.Message), inner, templateFile, parameterFile);
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
            using (var stream = new StreamReader(path))
            {
                using (var reader = new JsonTextReader(stream))
                {
                    return JObject.Load(reader);
                }
            }
        }
    }
}
