// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy;

/// <summary>
/// A list of supported policy modes.
/// </summary>
internal enum PolicyMode
{
    None = 0,

    All,

    Indexed
}
