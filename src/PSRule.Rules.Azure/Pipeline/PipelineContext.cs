// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline
{
    internal sealed class PipelineContext
    {
        internal PipelineContext(PSRuleOption option, PipelineWriter writer)
        {
            Option = option;
            Writer = writer;
        }

        public PSRuleOption Option { get; }

        public PipelineWriter Writer { get; }
    }
}
