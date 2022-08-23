// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Pipeline
{
    internal sealed class TemplatePipeline : PipelineBase
    {
        private readonly TemplateHelper _TemplateHelper;

        internal TemplatePipeline(PipelineContext context)
            : base(context)
        {
            _TemplateHelper = new TemplateHelper(context);
        }

        /// <inheritdoc/>
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
                Context.Writer.WriteObject(ProcessTemplate(templateFile, parameterFile), true);
            }
            catch (PipelineException ex)
            {
                Context.Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.InvalidData, parameterFile);
            }
            catch
            {
                throw;
            }
        }

        internal PSObject[] ProcessTemplate(string templateFile, string parameterFile)
        {
            return _TemplateHelper.ProcessTemplate(templateFile, parameterFile, out _);
        }
    }
}
