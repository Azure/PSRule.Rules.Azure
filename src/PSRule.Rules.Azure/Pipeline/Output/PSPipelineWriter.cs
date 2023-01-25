// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline.Output
{
    /// <summary>
    /// An output writer that returns output to the host PowerShell runspace.
    /// </summary>
    internal sealed class PSPipelineWriter : PipelineWriter
    {
        private const string Source = "PSRule";
        private const string HostTag = "PSHOST";

        private Action<string> _OnWriteWarning;
        private Action<string> _OnWriteVerbose;
        private Action<ErrorRecord> _OnWriteError;
        private Action<InformationRecord> _OnWriteInformation;
        private Action<string> _OnWriteDebug;
        internal Action<object, bool> _OnWriteObject;

        private bool _LogError;
        private bool _LogWarning;
        private bool _LogVerbose;
        private bool _LogInformation;
        private bool _LogDebug;

        internal PSPipelineWriter(PSRuleOption option)
            : base(null, option) { }

        internal PSPipelineWriter(PSRuleOption option, PSCmdlet commandRuntime)
            : base(null, option)
        {
            UseCommandRuntime(commandRuntime);
        }

        internal void UseCommandRuntime(PSCmdlet commandRuntime)
        {
            if (commandRuntime == null)
                return;

            _OnWriteVerbose = commandRuntime.WriteVerbose;
            _OnWriteWarning = commandRuntime.WriteWarning;
            _OnWriteError = commandRuntime.WriteError;
            _OnWriteInformation = commandRuntime.WriteInformation;
            _OnWriteDebug = commandRuntime.WriteDebug;
            _OnWriteObject = commandRuntime.WriteObject;
        }

        internal void UseExecutionContext(EngineIntrinsics executionContext)
        {
            if (executionContext == null)
                return;

            _LogError = GetPreferenceVariable(executionContext, ErrorPreference);
            _LogWarning = GetPreferenceVariable(executionContext, WarningPreference);
            _LogVerbose = GetPreferenceVariable(executionContext, VerbosePreference);
            _LogInformation = GetPreferenceVariable(executionContext, InformationPreference);
            _LogDebug = GetPreferenceVariable(executionContext, DebugPreference);
        }

        private static bool GetPreferenceVariable(EngineIntrinsics executionContext, string variableName)
        {
            var preference = GetPreferenceVariable(executionContext.SessionState, variableName);
            return preference != ActionPreference.Ignore &&
                !(preference == ActionPreference.SilentlyContinue && (
                    variableName == VerbosePreference ||
                    variableName == DebugPreference)
                );
        }

        #region Internal logging methods

        /// <summary>
        /// Core methods to hand off to logger.
        /// </summary>
        /// <param name="errorRecord">A valid PowerShell error record.</param>
        public override void WriteError(ErrorRecord errorRecord)
        {
            if (_OnWriteError == null || !ShouldWriteError())
                return;

            _OnWriteError(errorRecord);
        }

        /// <summary>
        /// Core method to hand off verbose messages to logger.
        /// </summary>
        /// <param name="message">A message to log.</param>
        public override void WriteVerbose(string message)
        {
            if (_OnWriteVerbose == null || !ShouldWriteVerbose())
                return;

            _OnWriteVerbose(message);
        }

        /// <summary>
        /// Core method to hand off warning messages to logger.
        /// </summary>
        /// <param name="message">A message to log</param>
        public override void WriteWarning(string message)
        {
            if (_OnWriteWarning == null || !ShouldWriteWarning())
                return;

            _OnWriteWarning(message);
        }

        /// <summary>
        /// Core method to hand off information messages to logger.
        /// </summary>
        public override void WriteInformation(InformationRecord informationRecord)
        {
            if (_OnWriteInformation == null || !ShouldWriteInformation())
                return;

            _OnWriteInformation(informationRecord);
        }

        /// <summary>
        /// Core method to hand off debug messages to logger.
        /// </summary>
        public override void WriteDebug(DebugRecord debugRecord)
        {
            if (_OnWriteDebug == null || !ShouldWriteDebug())
                return;

            _OnWriteDebug(debugRecord.Message);
        }

        public override void WriteObject(object sendToPipeline, bool enumerateCollection)
        {
            if (_OnWriteObject == null)
                return;

            _OnWriteObject(sendToPipeline, enumerateCollection);
        }

        public override void WriteHost(HostInformationMessage info)
        {
            if (_OnWriteInformation == null)
                return;

            var record = new InformationRecord(info, Source);
            record.Tags.Add(HostTag);
            _OnWriteInformation(record);
        }

        public override bool ShouldWriteVerbose()
        {
            return _LogVerbose;
        }

        public override bool ShouldWriteInformation()
        {
            return _LogInformation;
        }

        public override bool ShouldWriteDebug()
        {
            return _LogDebug;
        }

        public override bool ShouldWriteError()
        {
            return _LogError;
        }

        public override bool ShouldWriteWarning()
        {
            return _LogWarning;
        }

        #endregion Internal logging methods
    }
}
