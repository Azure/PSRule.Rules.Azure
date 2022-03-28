// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data.Policy
{
    internal sealed class PolicyAliasProviderHelper
    {
        private readonly string AssemblyPath = Path.GetDirectoryName(typeof(PolicyAliasProviderHelper).Assembly.Location);
        private const string DATAFILE_ALIASES = "aliases.json";
        private readonly PolicyAliasProvider _AliasProviders;
        private const char SLASH = '/';
        private const string PROVIDER_NAMESPACE = "providerNamespace";
        private const string RESOURCE_TYPE = "resourceType";
        private readonly IDictionary<string, string> _PolicyRuleType;

        public PolicyAliasProviderHelper()
        {
            _AliasProviders = ReadPolicyAliasProviders(DATAFILE_ALIASES);
            _PolicyRuleType = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        }

        internal void SetPolicyRuleType(string providerNamespace, string resourceType)
        {
            _PolicyRuleType[PROVIDER_NAMESPACE] = providerNamespace;
            _PolicyRuleType[RESOURCE_TYPE] = resourceType;
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
            aliasPath = null;

            var slashOccurrences = aliasName.CountCharacterOccurrences(SLASH);

            // Aliases must have a slash
            if (slashOccurrences == 0)
                return false;

            string providerNamespace;
            string resourceType;

            // Handle aliases like Microsoft.Compute/imageId with only one slash
            if (slashOccurrences == 1)
            {
                if (_PolicyRuleType.TryGetValue(PROVIDER_NAMESPACE, out providerNamespace)
                    && _PolicyRuleType.TryGetValue(RESOURCE_TYPE, out resourceType))
                {
                    aliasPath = GetPolicyAliasPath(providerNamespace, resourceType, aliasName);
                    return true;
                }
                return false;
            }

            // Any aliases with two slashes or more will be resolved here
            var firstSlashIndex = aliasName.IndexOf(SLASH);
            var lastSlashIndex = aliasName.LastIndexOf(SLASH);
            providerNamespace = aliasName.Substring(0, firstSlashIndex);
            resourceType = aliasName.Substring(firstSlashIndex + 1, lastSlashIndex - providerNamespace.Length - 1);
            aliasPath = GetPolicyAliasPath(providerNamespace, resourceType, aliasName);
            return true;
        }
    }
}