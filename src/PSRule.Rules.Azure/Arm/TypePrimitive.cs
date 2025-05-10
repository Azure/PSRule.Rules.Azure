// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Arm;

[JsonConverter(typeof(StringEnumConverter))]
internal enum TypePrimitive
{
    None,

    Array,

    Bool,

    Int,

    Object,

    String,

    SecureString,

    SecureObject
}
