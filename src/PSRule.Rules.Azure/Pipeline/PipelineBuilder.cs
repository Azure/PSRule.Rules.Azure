// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline
{
    internal delegate bool ShouldProcess(string target, string action);

    /// <summary>
    /// A helper class for building a pipeline from PowerShell.
    /// </summary>
    public static class PipelineBuilder
    {
        /// <summary>
        /// Create a builder for a template expanding pipeline.
        /// </summary>
        /// <param name="option">Options that configure PSRule for Azure.</param>
        /// <returns>A builder object to configure the pipeline.</returns>
        public static ITemplatePipelineBuilder Template(PSRuleOption option)
        {
            return new TemplatePipelineBuilder(option);
        }

        /// <summary>
        /// Create a builder for a template link discovery pipeline.
        /// </summary>
        /// <param name="path">The base path to search from.</param>
        /// <returns>A builder object to configure the pipeline.</returns>
        public static ITemplateLinkPipelineBuilder TemplateLink(string path)
        {
            return new TemplateLinkPipelineBuilder(path);
        }

        /// <summary>
        /// Create a builder for a policy assignment export pipeline.
        /// </summary>
        /// <param name="option">Options that configure PSRule for Azure.</param>
        /// <returns>A builder object to configure the pipeline.</returns>
        public static IPolicyAssignmentPipelineBuilder Assignment(PSRuleOption option)
        {
            return new PolicyAssignmentPipelineBuilder(option);
        }

        /// <summary>
        /// Create a builder for a policy to rule generation pipeline.
        /// </summary>
        /// <param name="path">The base path to search from.</param>
        /// <returns>A builder object to configure the pipeline.</returns>
        public static IPolicyAssignmentSearchPipelineBuilder AssignmentSearch(string path)
        {
            return new PolicyAssignmentSearchPipelineBuilder(path);
        }

        /// <summary>
        /// Create a builder for creating a pipeline to exporting resource data from Azure.
        /// </summary>
        /// <param name="option">Options that configure PSRule for Azure.</param>
        /// <returns>A builder object to configure the pipeline.</returns>
        public static IResourceDataPipelineBuilder ResourceData(PSRuleOption option)
        {
            return new ResourceDataPipelineBuilder(option);
        }
    }

    /// <summary>
    /// A helper to build a PSRule for Azure pipeline.
    /// </summary>
    public interface IPipelineBuilder
    {
        /// <summary>
        /// Configure the pipeline with cmdlet runtime information.
        /// </summary>
        void UseCommandRuntime(PSCmdlet commandRuntime);

        /// <summary>
        /// Configure the pipeline with a PowerShell execution context.
        /// </summary>
        void UseExecutionContext(EngineIntrinsics executionContext);

        /// <summary>
        /// Configure the pipeline with options.
        /// </summary>
        /// <param name="option">Options that configure PSRule for Azure.</param>
        /// <returns></returns>
        IPipelineBuilder Configure(PSRuleOption option);

        /// <summary>
        /// Build the pipeline.
        /// </summary>
        /// <returns>An instance of a configured pipeline.</returns>
        IPipeline Build();
    }

    /// <summary>
    /// An instance of a PSRule for Azure pipeline.
    /// </summary>
    public interface IPipeline
    {
        /// <summary>
        /// Initalize the pipeline and results. Call this method once prior to calling Process.
        /// </summary>
        void Begin();

        /// <summary>
        /// Process an object through the pipeline.
        /// </summary>
        /// <param name="sourceObject">The object to process.</param>
        void Process(PSObject sourceObject);

        /// <summary>
        /// Clean up and flush pipeline results. Call this method once after processing any objects through the pipeline.
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Naming", "CA1716:Identifiers should not match keywords", Justification = "Matches PowerShell pipeline.")]
        void End();
    }

    internal abstract class PipelineBuilderBase : IPipelineBuilder
    {
        private readonly PSPipelineWriter _Output;

        protected readonly PSRuleOption Option;

        protected PSCmdlet CmdletContext;
        protected EngineIntrinsics ExecutionContext;

        protected PipelineBuilderBase()
        {
            Option = new PSRuleOption();
            _Output = new PSPipelineWriter(Option);
        }

        /// <inheritdoc/>
        public virtual void UseCommandRuntime(PSCmdlet commandRuntime)
        {
            CmdletContext = commandRuntime;
            _Output.UseCommandRuntime(commandRuntime);
        }

        /// <inheritdoc/>
        public void UseExecutionContext(EngineIntrinsics executionContext)
        {
            ExecutionContext = executionContext;
            _Output.UseExecutionContext(executionContext);
        }

        /// <inheritdoc/>
        public virtual IPipelineBuilder Configure(PSRuleOption option)
        {
            if (option == null)
                return this;

            Option.Output = new OutputOption(option.Output);
            Option.Configuration = new ConfigurationOption(option.Configuration);
            return this;
        }

        /// <inheritdoc/>
        public abstract IPipeline Build();

        protected PipelineContext PrepareContext()
        {
            return new PipelineContext(Option, PrepareWriter());
        }

        protected virtual PipelineWriter PrepareWriter()
        {
            var writer = new PSPipelineWriter(Option);
            writer.UseCommandRuntime(CmdletContext);
            writer.UseExecutionContext(ExecutionContext);
            return writer;
        }

        protected virtual PipelineWriter GetOutput()
        {
            return _Output;
        }
    }

    internal abstract class PipelineBase : IDisposable, IPipeline
    {
        protected readonly PipelineContext Context;

        // Track whether Dispose has been called.
        private bool _Disposed;


        protected PipelineBase(PipelineContext context)
        {
            Context = context;
        }

        #region IPipeline

        /// <inheritdoc/>
        public virtual void Begin()
        {
            // Do nothing
        }

        /// <inheritdoc/>
        public virtual void Process(PSObject sourceObject)
        {
            // Do nothing
        }

        /// <inheritdoc/>
        public virtual void End()
        {
            Context.Writer.End();
        }

        #endregion IPipeline

        #region IDisposable

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_Disposed)
            {
                if (disposing)
                {
                    //Context.Dispose();
                }
                _Disposed = true;
            }
        }

        #endregion IDisposable
    }
}
