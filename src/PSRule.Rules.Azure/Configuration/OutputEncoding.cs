// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.Configuration
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum OutputEncoding
    {
        Default = 0,

        UTF8 = 1,

        UTF7 = 2,

        Unicode = 3,

        UTF32 = 4,

        ASCII = 5
    }
}
