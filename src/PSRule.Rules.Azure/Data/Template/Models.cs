// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Data.Template
{
    [JsonConverter(typeof(StringEnumConverter))]
    internal enum ParameterType
    {
        Array,

        Bool,

        Int,

        Object,

        String,

        SecureString,

        SecureObject
    }
}
