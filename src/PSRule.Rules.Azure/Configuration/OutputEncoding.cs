// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// The encoding format to convert output to.
/// </summary>
[JsonConverter(typeof(StringEnumConverter))]
public enum OutputEncoding
{
    /// <summary>
    /// UTF-8 with Byte Order Mark (BOM). This is the default.
    /// </summary>
    Default = 0,

    /// <summary>
    /// UTF-8 without Byte Order Mark (BOM).
    /// </summary>
    UTF8 = 1,

    /// <summary>
    /// UTF-7.
    /// </summary>
    UTF7 = 2,

    /// <summary>
    /// Unicode. Same as UTF-16.
    /// </summary>
    Unicode = 3,

    /// <summary>
    /// UTF-32.
    /// </summary>
    UTF32 = 4,

    /// <summary>
    /// ASCII.
    /// </summary>
    ASCII = 5
}
