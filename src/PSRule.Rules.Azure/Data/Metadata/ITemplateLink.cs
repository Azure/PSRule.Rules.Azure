// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Metadata
{
    public interface ITemplateLink
    {
        string TemplateFile { get; }

        string ParameterFile { get; }
    }
}
