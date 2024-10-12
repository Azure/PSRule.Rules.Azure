// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

internal enum TemplateSourceKind
{
    None = 0,
    Template = 1,
    Bicep = 2,
    BicepParam = 3,
}
