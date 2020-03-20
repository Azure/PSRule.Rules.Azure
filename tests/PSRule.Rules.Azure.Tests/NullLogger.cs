// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure
{
    internal sealed class NullLogger : ILogger
    {
        public void WriteVerbose(string message)
        {
            // Do nothing
        }

        public void WriteVerbose(string format, params object[] args)
        {
            // Do nothing
        }
    }
}
