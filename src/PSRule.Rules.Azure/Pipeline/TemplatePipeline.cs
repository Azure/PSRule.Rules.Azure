// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline.Output;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Text;
using System.Threading;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplatePipelineBuilder : IPipelineBuilder
    {
        void Deployment(string deploymentName);

        void ResourceGroup(PSObject resourceGroup);

        void Subscription(PSObject subscription);

        void PassThru(bool passThru);
    }

    internal sealed class TemplatePipelineBuilder : PipelineBuilderBase, ITemplatePipelineBuilder
    {
        private const string OUTPUTFILE_PREFIX = "resources-";
        private const string OUTPUTFILE_EXTENSION = ".json";

        private const string DEPLOYMENTNAME_PREFIX = "export-";

        private const string RESOURCEGROUP_RESOURCEID = "ResourceId";
        private const string RESOURCEGROUP_RESOURCEGROUPNAME = "ResourceGroupName";
        private const string RESOURCEGROUP_LOCATION = "Location";
        private const string RESOURCEGROUP_MANAGEDBY = "ManagedBy";
        private const string RESOURCEGROUP_TAGS = "Tags";
        private const string SUBSCRIPTION_SUBSCRIPTIONID = "SubscriptionId";
        private const string SUBSCRIPTION_TENANTID = "TenantId";
        private const string SUBSCRIPTION_NAME = "Name";

        private string _DeploymentName;
        private ResourceGroup _ResourceGroup;
        private Subscription _Subscription;
        private bool _PassThru;

        internal TemplatePipelineBuilder(PSRuleOption option)
            : base()
        {
            _DeploymentName = string.Concat(DEPLOYMENTNAME_PREFIX, Guid.NewGuid().ToString().Substring(0, 8));
            _ResourceGroup = Data.Template.ResourceGroup.Default;
            _Subscription = Data.Template.Subscription.Default;
            Configure(option);
        }

        public void Deployment(string deploymentName)
        {
            if (string.IsNullOrEmpty(deploymentName))
                return;

            _DeploymentName = deploymentName;
        }

        public void ResourceGroup(PSObject resourceGroup)
        {
            _ResourceGroup = new ResourceGroup(
                id: GetProperty<string>(resourceGroup, RESOURCEGROUP_RESOURCEID),
                name: GetProperty<string>(resourceGroup, RESOURCEGROUP_RESOURCEGROUPNAME),
                location: GetProperty<string>(resourceGroup, RESOURCEGROUP_LOCATION),
                managedBy: GetProperty<string>(resourceGroup, RESOURCEGROUP_MANAGEDBY),
                tags: GetProperty<Hashtable>(resourceGroup, RESOURCEGROUP_TAGS)
            );
        }

        public void Subscription(PSObject subscription)
        {
            _Subscription = new Subscription(
                subscriptionId: GetProperty<string>(subscription, SUBSCRIPTION_SUBSCRIPTIONID),
                tenantId: GetProperty<string>(subscription, SUBSCRIPTION_TENANTID),
                displayName: GetProperty<string>(subscription, SUBSCRIPTION_NAME)
            );
        }

        public void PassThru(bool passThru)
        {
            _PassThru = passThru;
        }

        private T GetProperty<T>(PSObject obj, string propertyName)
        {
            return null == obj.Properties[propertyName] ? default(T) : (T)obj.Properties[propertyName].Value;
        }

        protected override PipelineWriter GetOutput()
        {
            // Redirect to file instead
            if (!string.IsNullOrEmpty(Option.Output.Path))
            {
                return new FileOutputWriter(
                    inner: base.GetOutput(),
                    option: Option,
                    encoding: GetEncoding(Option.Output.Encoding),
                    path: Option.Output.Path,
                    defaultFile: string.Concat(OUTPUTFILE_PREFIX, _DeploymentName, OUTPUTFILE_EXTENSION),
                    shouldProcess: CmdletContext.ShouldProcess
                );
            }
            return base.GetOutput();
        }

        protected override PipelineWriter PrepareWriter()
        {
            return _PassThru ? base.PrepareWriter() : new JsonOutputWriter(GetOutput(), Option);
        }

        public override IPipeline Build()
        {
            return new TemplatePipeline(PrepareContext(), PrepareWriter(), _DeploymentName, _ResourceGroup, _Subscription);
        }

        /// <summary>
        /// Get the character encoding for the specified output encoding.
        /// </summary>
        /// <param name="encoding"></param>
        /// <returns></returns>
        private static Encoding GetEncoding(OutputEncoding? encoding)
        {
            switch (encoding)
            {
                case OutputEncoding.UTF8:
                    return Encoding.UTF8;

                case OutputEncoding.UTF7:
                    return Encoding.UTF7;

                case OutputEncoding.Unicode:
                    return Encoding.Unicode;

                case OutputEncoding.UTF32:
                    return Encoding.UTF32;

                case OutputEncoding.ASCII:
                    return Encoding.ASCII;

                default:
                    return new UTF8Encoding(encoderShouldEmitUTF8Identifier: false);
            }
        }
    }

    internal sealed class TemplatePipeline : PipelineBase
    {
        private readonly string _DeploymentName;
        private readonly ResourceGroup _ResourceGroup;
        private readonly Subscription _Subscription;

        internal TemplatePipeline(PipelineContext context, PipelineWriter writer, string deploymentName, ResourceGroup resourceGroup, Subscription subscription)
            : base(context, writer)
        {
            _DeploymentName = deploymentName;
            _ResourceGroup = resourceGroup;
            _Subscription = subscription;
        }

        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !(sourceObject.BaseObject is TemplateSource source))
                return;

            if (source.ParametersFile == null || source.ParametersFile.Length == 0)
                ProcessCatch(source.TemplateFile, null);
            else
                for (var i = 0; i < source.ParametersFile.Length; i++)
                    ProcessCatch(source.TemplateFile, source.ParametersFile[i]);
        }

        private void ProcessCatch(string templateFile, string parameterFile)
        {
            try
            {
                Writer.WriteObject(ProcessTemplate(templateFile, parameterFile), true);
            }
            catch (PipelineException ex)
            {
                Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.InvalidData, parameterFile);
            }
            catch
            {
                throw;
            }
        }

        internal PSObject[] ProcessTemplate(string templateFile, string parameterFile)
        {
            var rootedTemplateFile = PSRuleOption.GetRootedPath(templateFile);
            if (!File.Exists(rootedTemplateFile))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, rootedTemplateFile), rootedTemplateFile);

            var templateObject = ReadFile<JObject>(rootedTemplateFile);
            var visitor = new RuleDataExportVisitor();

            // Load context
            var context = new TemplateVisitor.TemplateContext(_Subscription, _ResourceGroup);
            if (!string.IsNullOrEmpty(parameterFile))
            {
                var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);
                if (!File.Exists(rootedParameterFile))
                    throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterFileNotFound, rootedParameterFile), rootedParameterFile);

                var parametersObject = ReadFile<JObject>(rootedParameterFile);
                context.Load(parametersObject);
            }

            // Process
            try
            {
                visitor.Visit(context, _DeploymentName, templateObject);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, templateFile, parameterFile, inner.Message), inner, templateFile, parameterFile);
            }

            // Return results
            var results = new List<PSObject>();
            var serializer = new JsonSerializer();
            serializer.Converters.Add(new PSObjectJsonConverter());
            foreach (var resource in context.Resources)
                results.Add(resource.ToObject<PSObject>(serializer));

            return results.ToArray();
        }

        private static T ReadFile<T>(string path)
        {
            return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
        }
    }
}
