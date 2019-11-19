using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Management.Automation;
using System.Text;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplatePipelineBuilder : IPipelineBuilder
    {
        void Deployment(string deploymentName);

        void ResourceGroup(PSObject resourceGroup);

        void Subscription(PSObject subscription);

        void PassThru(bool passThru);

        void OutputPath(string outputPath);
    }

    internal sealed class TemplatePipelineBuilder : PipelineBuilderBase, ITemplatePipelineBuilder
    {
        private const string OUTPUTFILE_PREFIX = "resources-";
        private const string OUTPUTFILE_EXTENSION = ".json";

        private const string DEPLOYMENTNAME_PREFIX = "export-";
        private const string DEPLOYMENTNAME_TIMEFORMAT = "yyyy-MM-dd-hh-mm";

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
        private string _OutputPath;

        internal TemplatePipelineBuilder()
            : base()
        {
            _DeploymentName = string.Concat(DEPLOYMENTNAME_PREFIX, DateTime.Now.ToString(DEPLOYMENTNAME_TIMEFORMAT, new CultureInfo("en-US")));
            _ResourceGroup = Data.Template.ResourceGroup.Default;
            _Subscription = Data.Template.Subscription.Default;
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

        public void OutputPath(string outputPath)
        {
            _OutputPath = outputPath;
        }

        private T GetProperty<T>(PSObject obj, string propertyName)
        {
            return null == obj.Properties[propertyName] ? default(T) : (T)obj.Properties[propertyName].Value;
        }

        protected override PipelineWriter PrepareWriter()
        {
            var defaultFile = string.Concat(OUTPUTFILE_PREFIX, _DeploymentName, OUTPUTFILE_EXTENSION);
            WriteOutput output = (o, enumerate) => WriteToFile(_OutputPath, defaultFile, ShouldProcess, Encoding.UTF8, o);
            return _PassThru ? base.PrepareWriter() : new JsonPipelineWriter(output);
        }

        public override IPipeline Build()
        {
            return new TemplatePipeline(PrepareContext(), PrepareWriter(), _DeploymentName, _ResourceGroup, _Subscription);
        }
    }

    internal sealed class TemplatePipeline : PipelineBase
    {
        private readonly PipelineWriter _Writer;
        private readonly string _DeploymentName;
        private readonly ResourceGroup _ResourceGroup;
        private readonly Subscription _Subscription;

        internal TemplatePipeline(PipelineContext context, PipelineWriter writer, string deploymentName, ResourceGroup resourceGroup, Subscription subscription)
            : base(context)
        {
            _Writer = writer;
            _DeploymentName = deploymentName;
            _ResourceGroup = resourceGroup;
            _Subscription = subscription;
        }

        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !(sourceObject.BaseObject is TemplateSource source))
                return;

            for (var i = 0; i < source.ParametersFile.Length; i++)
            {
                var output = ProcessTemplate(source.TemplateFile, source.ParametersFile[i]);
                _Writer.Write(output, true);
            }
        }

        public override void End()
        {
            _Writer.End();
        }

        internal PSObject[] ProcessTemplate(string templateFile, string parametersFile)
        {
            var templateObject = ReadFile<JObject>(PSRuleOption.GetRootedPath(templateFile));
            if (templateObject == null)
                throw new FileNotFoundException();

            var parametersObject = ReadFile<JObject>(PSRuleOption.GetRootedPath(parametersFile));
            var visitor = new RuleDataExportVisitor();

            // Load context
            var context = new TemplateVisitor.TemplateContext(_Subscription, _ResourceGroup);
            context.Load(parametersObject);
            visitor.Visit(context, _DeploymentName, templateObject);

            // Return results
            var results = new List<PSObject>();
            var serializer = new JsonSerializer();
            serializer.Converters.Add(new PSObjectJsonConverter());
            foreach (var resource in context.Resources)
            {
                results.Add(resource.ToObject<PSObject>(serializer));
            }
            return results.ToArray();
        }

        private static T ReadFile<T>(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                return default(T);

            return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
        }
    }
}
