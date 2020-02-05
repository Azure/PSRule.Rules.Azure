// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Resources;
using System;
using System.IO;
using System.Management.Automation;
using System.Text;

namespace PSRule.Rules.Azure.Pipeline
{
    internal delegate bool ShouldProcess(string target, string action);

    /// <summary>
    /// A helper class for building a pipeline from PowerShell.
    /// </summary>
    public static class PipelineBuilder
    {
        public static ITemplatePipelineBuilder Template()
        {
            return new TemplatePipelineBuilder();
        }
    }

    public interface IPipelineBuilder
    {
        void UseCommandRuntime(ICommandRuntime2 commandRuntime);

        void UseExecutionContext(EngineIntrinsics executionContext);

        IPipelineBuilder Configure(PSRuleOption option);

        IPipeline Build();
    }

    public interface IPipeline
    {
        void Begin();

        void Process(PSObject sourceObject);

        void End();
    }

    internal abstract class PipelineBuilderBase : IPipelineBuilder
    {
        protected readonly PSRuleOption Option;

        protected WriteOutput Output;
        protected ShouldProcess ShouldProcess;

        protected PipelineBuilderBase()
        {
            Option = new PSRuleOption();
        }

        public virtual void UseCommandRuntime(ICommandRuntime2 commandRuntime)
        {
            //Logger.UseCommandRuntime(commandRuntime);
            Output = commandRuntime.WriteObject;
            ShouldProcess = commandRuntime.ShouldProcess;
        }

        public void UseExecutionContext(EngineIntrinsics executionContext)
        {
            //Logger.UseExecutionContext(executionContext);
        }

        public virtual IPipelineBuilder Configure(PSRuleOption option)
        {
            return this;
        }

        public abstract IPipeline Build();

        protected PipelineContext PrepareContext()
        {
            return new PipelineContext(Option);
        }

        protected virtual PipelineWriter PrepareWriter()
        {
            return new PowerShellWriter(Output);
        }

        /// <summary>
        /// Write output to file.
        /// </summary>
        /// <param name="path">The file path to write.</param>
        /// <param name="defaultFile">The default file name to use when a directory is specified.</param>
        /// <param name="encoding">The file encoding to use.</param>
        /// <param name="o">The text to write.</param>
        protected static void WriteToFile(string path, string defaultFile, ShouldProcess shouldProcess, WriteOutput output, Encoding encoding, object o)
        {
            var rootedPath = PSRuleOption.GetRootedPath(path: path);
            if (!Path.HasExtension(rootedPath) || Directory.Exists(rootedPath))
                rootedPath = Path.Combine(rootedPath, defaultFile);

            var parentPath = Directory.GetParent(rootedPath);
            if (!parentPath.Exists && shouldProcess(target: parentPath.FullName, action: PSRuleResources.ShouldCreatePath))
            {
                Directory.CreateDirectory(path: parentPath.FullName);
            }
            if (shouldProcess(target: rootedPath, action: PSRuleResources.ShouldWriteFile))
            {
                File.WriteAllText(path: rootedPath, contents: o.ToString(), encoding: encoding);
                var info = new FileInfo(rootedPath);
                output(info, false);
            }
        }
    }

    internal abstract class PipelineBase : IDisposable, IPipeline
    {
        protected readonly PipelineContext Context;

        // Track whether Dispose has been called.
        private bool _Disposed = false;
        

        protected PipelineBase(PipelineContext context)
        {
            Context = context;
        }

        #region IPipeline

        public virtual void Begin()
        {
            //Reader.Open();
        }

        public virtual void Process(PSObject sourceObject)
        {
            // Do nothing
        }

        public virtual void End()
        {
            //Writer.End();
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
