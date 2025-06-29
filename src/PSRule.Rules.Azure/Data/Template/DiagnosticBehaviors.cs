// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// Flags for the template context that are used for unit testing and debugging.
/// </summary>
[Flags]
internal enum DiagnosticBehaviors
{
    None = 0,

    KeepSecretProperties = 1
}
