// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class ResourceProviderHelper
    {
        private readonly string AssemblyPath = Path.GetDirectoryName(typeof(ResourceProviderHelper).Assembly.Location);
        private const string DATAFILE_PROVIDERS = "providers.json";
        private readonly Dictionary<string, ResourceProvider> _Providers;

        public ResourceProviderHelper()
        {
            _Providers = ReadProviders();
        }

        internal Dictionary<string, T> ReadDataFile<T>(string fileName)
        {
            var sourcePath = Path.Combine(AssemblyPath, fileName);
            if (!File.Exists(sourcePath))
                return null;

            var json = File.ReadAllText(sourcePath);
            var settings = new JsonSerializerSettings();
            settings.Converters.Add(new ResourceProviderConverter());
            var result = JsonConvert.DeserializeObject<Dictionary<string, T>>(json, settings);
            return result;
        }

        private Dictionary<string, ResourceProvider> ReadProviders()
        {
            return ReadDataFile<ResourceProvider>(DATAFILE_PROVIDERS);
        }

        internal ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
        {
            if (_Providers == null || _Providers.Count == 0 || !_Providers.TryGetValue(providerNamespace, out var provider))
                return Array.Empty<ResourceProviderType>();

            if (resourceType == null)
                return provider.Types.Values.ToArray();

            return !provider.Types.ContainsKey(resourceType)
                ? Array.Empty<ResourceProviderType>()
                : (new ResourceProviderType[] { provider.Types[resourceType] });
        }
    }
}
