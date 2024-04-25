// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.BuildTool.Models
{
    internal sealed class IndexEntry
    {
        [JsonProperty(PropertyName = "r")]
        public string RelativePath { get; set; }

        [JsonProperty(PropertyName = "i")]
        public int Index { get; set; }
    }
}
