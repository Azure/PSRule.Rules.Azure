// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplateLinkPipelineBuilder : IPipelineBuilder
    {
        void SkipUnlinked(bool skipUnlinked);
    }

    internal sealed class TemplateLinkPipelineBuilder : PipelineBuilderBase, ITemplateLinkPipelineBuilder
    {
        private readonly string _BasePath;

        private bool _SkipUnlinked;

        internal TemplateLinkPipelineBuilder(string basePath)
        {
            _BasePath = basePath;
        }

        public void SkipUnlinked(bool skipUnlinked)
        {
            _SkipUnlinked = skipUnlinked;
        }

        public override IPipeline Build()
        {
            return new TemplateLinkPipeline(PrepareContext(), _BasePath, _SkipUnlinked);
        }
    }

    internal sealed class TemplateLinkPipeline : PipelineBase
    {
        private const string DEFAULT_TEMPLATESEARCH_PATTERN = "*.parameters.json";

        private readonly string _BasePath;
        private readonly PathBuilder _PathBuilder;
        private readonly TemplateLinkHelper _TemplateHelper;

        internal TemplateLinkPipeline(PipelineContext context, string basePath, bool skipUnlinked)
            : base(context)
        {
            _BasePath = PSRuleOption.GetRootedBasePath(basePath);
            _PathBuilder = new PathBuilder(context.Writer, basePath, DEFAULT_TEMPLATESEARCH_PATTERN);
            _TemplateHelper = new TemplateLinkHelper(context, _BasePath, skipUnlinked);
        }

        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !GetPath(sourceObject, out var path))
                return;

            _PathBuilder.Add(path);
            var fileInfos = _PathBuilder.Build();
            foreach (var info in fileInfos)
                ProcessParameterFile(info.FullName);
        }

        private void ProcessParameterFile(string parameterFile)
        {
            try
            {
                var templateLink = _TemplateHelper.ProcessParameterFile(parameterFile);
                Context.Writer.WriteObject(templateLink, false);
            }
            catch (InvalidOperationException ex)
            {
                Context.Writer.WriteError(ex, nameof(InvalidOperationException), ErrorCategory.InvalidOperation, parameterFile);
            }
            catch (FileNotFoundException ex)
            {
                Context.Writer.WriteError(ex, nameof(FileNotFoundException), ErrorCategory.ObjectNotFound, parameterFile);
            }
            catch (PipelineException ex)
            {
                Context.Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.WriteError, parameterFile);
            }
        }

        private static bool GetPath(PSObject sourceObject, out string path)
        {
            path = null;
            if (sourceObject.BaseObject is string s)
            {
                path = s;
                return true;
            }
            if (sourceObject.BaseObject is FileInfo info && info.Extension == ".json")
            {
                path = info.FullName;
                return true;
            }
            return false;
        }
    }
}
