// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Metadata;

/// <summary>
/// A naming or metadata link between a parameter file to a template or Bicep code.
/// </summary>
public interface ITemplateLink
{
    /// <summary>
    /// The linked template or Bicep code.
    /// </summary>
    string TemplateFile { get; }

    /// <summary>
    /// The linked parameter file.
    /// </summary>
    string ParameterFile { get; }
}
