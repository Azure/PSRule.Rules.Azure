// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    /// <summary>
    /// An index location.
    /// </summary>
    internal sealed class TypeIndexEntry
    {
        public TypeIndexEntry(string relativePath, int index)
        {
            RelativePath = relativePath;
            Index = index;
        }

        [JsonProperty(PropertyName = "r")]
        public string RelativePath { get; set; }

        [JsonProperty(PropertyName = "i")]
        public int Index { get; set; }
    }
}
