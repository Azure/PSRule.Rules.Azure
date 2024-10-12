// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Data.Policy;

[JsonConverter(typeof(StringEnumConverter))]
internal enum ParameterType
{
    String,

    Array,

    Object,

    Boolean,

    Integer,

    Float,

    DateTime
}
