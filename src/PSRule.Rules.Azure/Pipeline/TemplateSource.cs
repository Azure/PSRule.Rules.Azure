// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A source for template expansion.
/// </summary>
public sealed class TemplateSource
{
    internal readonly string TemplateFile;
    internal readonly string[] ParametersFile;
    internal readonly TemplateSourceKind Kind;

    /// <summary>
    /// Create a source.
    /// </summary>
    public TemplateSource(string templateFile, string[] parametersFile)
    {
        TemplateFile = templateFile;
        ParametersFile = parametersFile;
        Kind = TemplateSourceKind.Template;
    }

    /// <summary>
    /// Create a source.
    /// </summary>
    public TemplateSource(string sourceFile)
    {
        if (string.IsNullOrEmpty(sourceFile))
            throw new ArgumentNullException(nameof(sourceFile));

        TemplateFile = sourceFile;
        if (TemplateFile.EndsWith(".bicep", StringComparison.OrdinalIgnoreCase))
            Kind = TemplateSourceKind.Bicep;
        else if (TemplateFile.EndsWith(".bicepparam", StringComparison.OrdinalIgnoreCase))
            Kind = TemplateSourceKind.BicepParam;
    }
}
