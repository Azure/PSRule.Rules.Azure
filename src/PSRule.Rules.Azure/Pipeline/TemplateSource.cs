// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline
{
    public sealed class TemplateSource
    {
        internal readonly string TemplateFile;
        internal readonly string[] ParametersFile;

        public TemplateSource(string templateFile, string[] parametersFile)
        {
            TemplateFile = templateFile;
            ParametersFile = parametersFile;
        }
    }
}
