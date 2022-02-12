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

        private Action<string> OnWriteWarning;
        private Action<string> OnWriteVerbose;
        private Action<ErrorRecord> OnWriteError;
        private Action<InformationRecord> OnWriteInformation;
        private Action<string> OnWriteDebug;
        internal Action<object, bool> OnWriteObject;

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

            OnWriteVerbose = commandRuntime.WriteVerbose;
            OnWriteWarning = commandRuntime.WriteWarning;
            OnWriteError = commandRuntime.WriteError;
            OnWriteInformation = commandRuntime.WriteInformation;
            OnWriteDebug = commandRuntime.WriteDebug;
            OnWriteObject = commandRuntime.WriteObject;
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
            if (OnWriteError == null || !ShouldWriteError())
                return;

            OnWriteError(errorRecord);
        }

        /// <summary>
        /// Core method to hand off verbose messages to logger.
        /// </summary>
        /// <param name="message">A message to log.</param>
        public override void WriteVerbose(string message)
        {
            if (OnWriteVerbose == null || !ShouldWriteVerbose())
                return;

            OnWriteVerbose(message);
        }

        /// <summary>
        /// Core method to hand off warning messages to logger.
        /// </summary>
        /// <param name="message">A message to log</param>
        public override void WriteWarning(string message)
        {
            if (OnWriteWarning == null || !ShouldWriteWarning())
                return;

            OnWriteWarning(message);
        }

        /// <summary>
        /// Core method to hand off information messages to logger.
        /// </summary>
        public override void WriteInformation(InformationRecord informationRecord)
        {
            if (OnWriteInformation == null || !ShouldWriteInformation())
                return;

            OnWriteInformation(informationRecord);
        }

        /// <summary>
        /// Core method to hand off debug messages to logger.
        /// </summary>
        public override void WriteDebug(DebugRecord debugRecord)
        {
            if (OnWriteDebug == null || !ShouldWriteDebug())
                return;

            OnWriteDebug(debugRecord.Message);
        }

        public override void WriteObject(object sendToPipeline, bool enumerateCollection)
        {
            if (OnWriteObject == null)
                return;

            OnWriteObject(sendToPipeline, enumerateCollection);
        }

        public override void WriteHost(HostInformationMessage info)
        {
            if (OnWriteInformation == null)
                return;

            var record = new InformationRecord(info, Source);
            record.Tags.Add(HostTag);
            OnWriteInformation(record);
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
