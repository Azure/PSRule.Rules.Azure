// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Metadata
{
    internal sealed class TemplateLink : ITemplateLink
    {
        internal TemplateLink(string templateFile, string parameterFile)
        {
            TemplateFile = templateFile;
            ParameterFile = parameterFile;
        }

        public string Name { get; internal set; }

        public string Description { get; internal set; }

        public string TemplateFile { get; }

        public string ParameterFile { get; }
    }
}
