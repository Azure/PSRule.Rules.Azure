// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Policy
{
    internal static class LoggerExtensions
    {
        /// <summary>
        /// Policy definition has been ignored based on configuration: {0}
        /// </summary>
        /// <param name="logger">A logger instance.</param>
        /// <param name="definitionId">The policy definition ID.</param>
        public static void VerbosePolicyIgnoreConfigured(this ILogger logger, string definitionId)
        {
            if (logger == null)
                return;

            logger.WriteVerbose(PSRuleResources.PolicyIgnoreConfigured, definitionId);
        }

        /// <summary>
        /// Policy definition has been ignored because it is not applicable to Infrastructure as Code: {0}
        /// </summary>
        /// <param name="logger">A logger instance.</param>
        /// <param name="definitionId">The policy definition ID.</param>
        public static void VerbosePolicyIgnoreNotApplicable(this ILogger logger, string definitionId)
        {
            if (logger == null)
                return;

            logger.WriteVerbose(PSRuleResources.PolicyIgnoreNotApplicable, definitionId);
        }

        /// <summary>
        /// Policy definition has been ignored because a similar built-in rule already exists ({1}): {0}
        /// </summary>
        /// <param name="logger">A logger instance.</param>
        /// <param name="definitionId">The policy definition ID.</param>
        /// <param name="ruleName">The name of the built-in rule.</param>
        public static void VerbosePolicyIgnoreDuplicate(this ILogger logger, string definitionId, string ruleName)
        {
            if (logger == null)
                return;

            logger.WriteVerbose(PSRuleResources.PolicyIgnoreDuplicate, definitionId, ruleName);
        }

        /// <summary>
        /// Policy definition has been ignored because it is disabled: {0}
        /// </summary>
        /// <param name="logger">A logger instance.</param>
        /// <param name="definitionId">The policy definition ID.</param>
        public static void VerbosePolicyIgnoreDisabled(this ILogger logger, string definitionId)
        {
            if (logger == null)
                return;

            logger.WriteVerbose(PSRuleResources.PolicyIgnoreDisabled, definitionId);
        }
    }
}
