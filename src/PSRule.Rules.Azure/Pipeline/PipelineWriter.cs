// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using System.Threading;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline
{
    internal abstract class PipelineWriter : ILogger
    {
        protected const string ErrorPreference = "ErrorActionPreference";
        protected const string WarningPreference = "WarningPreference";
        protected const string VerbosePreference = "VerbosePreference";
        protected const string InformationPreference = "InformationPreference";
        protected const string DebugPreference = "DebugPreference";

        private readonly PipelineWriter _Writer;

        protected readonly PSRuleOption Option;

        protected PipelineWriter(PipelineWriter inner, PSRuleOption option)
        {
            _Writer = inner;
            Option = option;
        }

        public virtual void Begin()
        {
            if (_Writer == null)
                return;

            _Writer.Begin();
        }

        public virtual void WriteObject(object sendToPipeline, bool enumerateCollection)
        {
            if (_Writer == null || sendToPipeline == null)
                return;

            _Writer.WriteObject(sendToPipeline, enumerateCollection);
        }

        public virtual void End()
        {
            if (_Writer == null)
                return;

            _Writer.End();
        }

        public void WriteVerbose(string format, params object[] args)
        {
            if (!ShouldWriteVerbose())
                return;

            WriteVerbose(string.Format(Thread.CurrentThread.CurrentCulture, format, args));
        }

        public virtual void WriteVerbose(string message)
        {
            if (_Writer == null || string.IsNullOrEmpty(message))
                return;

            _Writer.WriteVerbose(message);
        }

        public virtual bool ShouldWriteVerbose()
        {
            return _Writer != null && _Writer.ShouldWriteVerbose();
        }

        public void WriteWarning(string format, params object[] args)
        {
            if (!ShouldWriteWarning())
                return;

            WriteWarning(string.Format(Thread.CurrentThread.CurrentCulture, format, args));
        }

        public virtual void WriteWarning(string message)
        {
            if (_Writer == null || string.IsNullOrEmpty(message))
                return;

            _Writer.WriteWarning(message);
        }

        public virtual bool ShouldWriteWarning()
        {
            return _Writer != null && _Writer.ShouldWriteWarning();
        }

        public void WriteError(Exception exception, string errorId, ErrorCategory errorCategory, object targetObject)
        {
            if (!ShouldWriteError())
                return;

            WriteError(new ErrorRecord(exception, errorId, errorCategory, targetObject));
        }

        public virtual void WriteError(ErrorRecord errorRecord)
        {
            if (_Writer == null || errorRecord == null)
                return;

            _Writer.WriteError(errorRecord);
        }

        public virtual bool ShouldWriteError()
        {
            return _Writer != null && _Writer.ShouldWriteError();
        }

        public virtual void WriteInformation(InformationRecord informationRecord)
        {
            if (_Writer == null || informationRecord == null)
                return;

            _Writer.WriteInformation(informationRecord);
        }

        public virtual void WriteHost(HostInformationMessage info)
        {
            if (_Writer == null)
                return;

            _Writer.WriteHost(info);
        }

        public virtual bool ShouldWriteInformation()
        {
            return _Writer != null && _Writer.ShouldWriteInformation();
        }

        public virtual void WriteDebug(DebugRecord debugRecord)
        {
            if (_Writer == null || debugRecord == null)
                return;

            _Writer.WriteDebug(debugRecord);
        }

        public void WriteDebug(string format, params object[] args)
        {
            if (_Writer == null || string.IsNullOrEmpty(format))
                return;

            var message = args == null || args.Length == 0 ? format : string.Format(format, args);
            var debugRecord = new DebugRecord(message);
            _Writer.WriteDebug(debugRecord);
        }

        public virtual bool ShouldWriteDebug()
        {
            return _Writer != null && _Writer.ShouldWriteDebug();
        }

        protected static ActionPreference GetPreferenceVariable(SessionState sessionState, string variableName)
        {
            return (ActionPreference)sessionState.PSVariable.GetValue(variableName);
        }
    }
}
