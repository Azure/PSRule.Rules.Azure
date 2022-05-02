// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class ResourceProviderHelper
    {
        private readonly ProviderData _Providers;

        public ResourceProviderHelper()
        {
            _Providers = new ProviderData();
        }

        internal ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
        {
            if (_Providers == null)
                return Array.Empty<ResourceProviderType>();

            if (resourceType == null)
                return _Providers.GetProviderTypes(providerNamespace);

            if (_Providers.TryResourceType(providerNamespace, resourceType, out var type))
                return new ResourceProviderType[] { type };

            return Array.Empty<ResourceProviderType>();
        }
    }
}
