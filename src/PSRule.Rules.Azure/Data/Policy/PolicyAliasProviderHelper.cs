// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy
{
    internal sealed class PolicyAliasProviderHelper
    {
        private const char SLASH = '/';
        private readonly ProviderData _Providers;
        private TypeIndexEntry _DefaultRuleType;

        public PolicyAliasProviderHelper()
        {
            _Providers = new ProviderData();
        }

        internal void SetPolicyRuleType(string providerNamespace, string resourceType)
        {
            _DefaultRuleType = _Providers.FindResourceType(providerNamespace, resourceType);
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
                return _DefaultRuleType != null
                    && _Providers.TryResourceType(_DefaultRuleType, out var type2)
                    && type2.Aliases != null
                    && type2.Aliases.TryGetValue(aliasName, out aliasPath);
            }

            // Any aliases with two slashes or more will be resolved here
            var firstSlashIndex = aliasName.IndexOf(SLASH);
            var lastSlashIndex = aliasName.LastIndexOf(SLASH);
            providerNamespace = aliasName.Substring(0, firstSlashIndex);
            resourceType = aliasName.Substring(firstSlashIndex + 1, lastSlashIndex - providerNamespace.Length - 1);

            return _Providers.TryResourceType(providerNamespace, resourceType, out var type) &&
                type.Aliases != null &&
                type.Aliases.TryGetValue(aliasName, out aliasPath);
        }
    }
}
