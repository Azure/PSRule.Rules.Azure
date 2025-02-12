// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// The type of function error.
/// </summary>
public enum FunctionErrorType
{
    /// <summary>
    /// A generic error.
    /// </summary>
    Unknown,

    /// <summary>
    /// An error cause by mismatching resource segments.
    /// </summary>
    MismatchingResourceSegments,

    /// <summary>
    /// An error caused by failed deserialization.
    /// </summary>
    DeserializationFailure,
}
