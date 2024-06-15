// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    /// <summary>
    /// Endpoints for Azure cloud environments.
    /// </summary>
    public sealed class CloudEnvironmentSuffixes
    {
        /// <summary>
        /// The suffix for ACR login.
        /// Defaults to <c>.azurecr.io</c>.
        /// </summary>
        [JsonProperty(PropertyName = "acrLoginServer")]
        public string acrLoginServer { get; set; }

        /// <summary>
        /// Defaults to <c>azuredatalakeanalytics.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "azureDatalakeAnalyticsCatalogAndJob")]
        public string azureDatalakeAnalyticsCatalogAndJob { get; set; }

        /// <summary>
        /// Defaults to <c>azuredatalakestore.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "azureDatalakeStoreFileSystem")]
        public string azureDatalakeStoreFileSystem { get; set; }

        /// <summary>
        /// The suffix for Front Door endpoints.
        /// Defaults to <c>azurefd.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "azureFrontDoorEndpointSuffix")]
        public string azureFrontDoorEndpointSuffix { get; set; }

        /// <summary>
        /// The suffix for Key Vaults.
        /// Defaults to <c>.vault.azure.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "keyvaultDns")]
        public string keyvaultDns { get; set; }

        /// <summary>
        /// The suffix for Azure SQL Database logical servers.
        /// Defaults to <c>.database.windows.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "sqlServerHostname")]
        public string sqlServerHostname { get; set; }

        /// <summary>
        /// The base suffix for Azure Storage services.
        /// Defaults to <c>core.windows.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "storage")]
        public string storage { get; set; }
    }
}
