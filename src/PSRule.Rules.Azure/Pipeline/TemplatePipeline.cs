using Newtonsoft.Json;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using System.Collections;
using System.IO;
using System.Management.Automation;
using System.Text;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplatePipelineBuilder : IPipelineBuilder
    {
        void ResourceGroup(PSObject resourceGroup);

        void Subscription(PSObject subscription);

        void PassThru(bool passThru);

        void OutputPath(string outputPath);
    }

    internal sealed class TemplatePipelineBuilder : PipelineBuilderBase, ITemplatePipelineBuilder
    {
        private Subscription _Subscription;
        private ResourceGroup _ResourceGroup;
        private bool _PassThru;
        private string _OutputPath;

        internal TemplatePipelineBuilder()
            : base()
        {
            _Subscription = Data.Template.Subscription.Default;
            _ResourceGroup = Data.Template.ResourceGroup.Default;
        }

        public void ResourceGroup(PSObject resourceGroup)
        {
            _ResourceGroup = new ResourceGroup(
                id: GetProperty<string>(resourceGroup, "ResourceId"),
                name: GetProperty<string>(resourceGroup, "ResourceGroupName"),
                location: GetProperty<string>(resourceGroup, "Location"),
                managedBy: GetProperty<string>(resourceGroup, "ManagedBy"),
                tags: GetProperty<Hashtable>(resourceGroup, "Tags")
            );
        }

        public void Subscription(PSObject subscription)
        {
            _Subscription = new Subscription(
                subscriptionId: GetProperty<string>(subscription, "SubscriptionId"),
                tenantId: GetProperty<string>(subscription, "TenantId"),
                displayName: GetProperty<string>(subscription, "Name")
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
            return null == obj.Properties[propertyName] ? default : (T)obj.Properties[propertyName].Value;
        }

        protected override PipelineWriter PrepareWriter()
        {
            WriteOutput output = (o, enumerate) => WriteToFile(_OutputPath, ShouldProcess, Encoding.UTF8, o);
            return _PassThru ? base.PrepareWriter() : new JsonPipelineWriter(output);
        }

        public override IPipeline Build()
        {
            return new TemplatePipeline(PrepareContext(), PrepareWriter(), _ResourceGroup, _Subscription);
        }
    }

    internal sealed class TemplatePipeline : PipelineBase
    {
        private readonly PipelineWriter _Writer;
        private readonly ResourceGroup _ResourceGroup;
        private readonly Subscription _Subscription;

        internal TemplatePipeline(PipelineContext context, PipelineWriter writer, ResourceGroup resourceGroup, Subscription subscription)
            : base(context)
        {
            _Writer = writer;
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
            var templateObject = ReadFile<DeploymentTemplate>(PSRuleOption.GetRootedPath(templateFile));
            if (templateObject == null)
                throw new FileNotFoundException();

            var parametersObject = ReadFile<DeploymentParameters>(PSRuleOption.GetRootedPath(parametersFile));
            var visitor = new RuleDataExportVisitor(_Subscription, _ResourceGroup);
            return visitor.Visit(templateObject, parametersObject);
        }

        private static T ReadFile<T>(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                return default;

            return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
        }
    }
}
