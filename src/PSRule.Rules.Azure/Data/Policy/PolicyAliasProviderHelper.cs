// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data.Policy
{
    internal sealed class PolicyAliasProviderHelper
    {
        private readonly string AssemblyPath = Path.GetDirectoryName(typeof(PolicyAliasProviderHelper).Assembly.Location);
        private const string DATAFILE_ALIASES = "aliases.json";
        private readonly PolicyAliasProvider _AliasProviders;
        private const string SLASH = "/";

        public PolicyAliasProviderHelper()
        {
            _AliasProviders = ReadPolicyAliasProviders(DATAFILE_ALIASES);
        }

        private PolicyAliasProvider ReadPolicyAliasProviders(string fileName)
        {
            var sourcePath = Path.Combine(AssemblyPath, fileName);
            if (!File.Exists(sourcePath))
                return null;

            var json = File.ReadAllText(sourcePath);

            var settings = new JsonSerializerSettings();
            settings.Converters.Add(new PolicyAliasProviderConverter());

            var result = JsonConvert.DeserializeObject<PolicyAliasProvider>(json, settings);

            return result;
        }

        private PolicyAliasResourceType GetPolicyAliasResourceType(string providerNamespace)
        {
            return _AliasProviders.Providers.TryGetValue(providerNamespace, out var aliasResourceType)
                ? aliasResourceType
                : null;
        }

        private PolicyAliasMapping GetPolicyAliasMapping(string providerNamespace, string resourceType)
        {
            var aliasResourceType = GetPolicyAliasResourceType(providerNamespace);

            return aliasResourceType != null
                && aliasResourceType.ResourceTypes.TryGetValue(resourceType, out var aliasMapping)
                ? aliasMapping
                : null;
        }

        private string GetPolicyAliasPath(string providerNamespace, string resourceType, string aliasName)
        {
            var aliasMapping = GetPolicyAliasMapping(providerNamespace, resourceType);

            return aliasMapping != null
                && aliasMapping.AliasMappings.TryGetValue(aliasName, out var aliasPath)
                ? aliasPath
                : null;
        }

        internal bool ResolvePolicyAliasPath(string aliasName, out string aliasPath)
        {
            if (!aliasName.Contains(SLASH))
            {
                aliasPath = string.Empty;
                return false;
            }

            var firstSlashIndex = aliasName.IndexOf(SLASH, StringComparison.OrdinalIgnoreCase);
            var lastSlashIndex = aliasName.LastIndexOf(SLASH, StringComparison.OrdinalIgnoreCase);
            var providerNamespace = aliasName.Substring(0, firstSlashIndex);
            var resourceType = aliasName.Substring(firstSlashIndex + 1, lastSlashIndex - providerNamespace.Length - 1);
            aliasPath = GetPolicyAliasPath(providerNamespace, resourceType, aliasName);
            return true;
        }
    }
}