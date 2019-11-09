using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline
{
    internal sealed class PipelineContext
    {
        internal readonly PSRuleOption Option;

        public PipelineContext(PSRuleOption option)
        {
            Option = option;
        }
    }
}
