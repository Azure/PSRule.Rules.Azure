// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;

namespace PSRule.Rules.Azure.Data.Metadata;

internal sealed class TemplateLink : ITemplateLink
{
    internal TemplateLink(string templateFile, string parameterFile)
    {
        TemplateFile = templateFile;
        ParameterFile = parameterFile;
        Metadata = new Hashtable(StringComparer.OrdinalIgnoreCase);
    }

    public string Name { get; internal set; }

    public string Description { get; internal set; }

    public string TemplateFile { get; }

    public string ParameterFile { get; }

    public Hashtable Metadata { get; }
}
