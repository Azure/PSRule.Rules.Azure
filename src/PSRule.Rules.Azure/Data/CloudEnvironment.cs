// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    /// <summary>
    /// Properties of an Azure Cloud Environment.
    /// This object is exposed by the ARM <c>environment()</c> function.
    /// See <seealso href="https://learn.microsoft.com/azure/azure-resource-manager/templates/template-functions-deployment#environment">docs</seealso>.
    /// </summary>
    public sealed class CloudEnvironment
    {
        /// <summary>
        /// The name of the cloud environment.
        /// </summary>
        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        /// <summary>
        /// The gallery endpoint.
        /// </summary>
        [JsonProperty(PropertyName = "gallery")]
        public string Gallery { get; set; }

        /// <summary>
        /// The Microsoft Graph endpoint.
        /// </summary>
        [JsonProperty(PropertyName = "graph")]
        public string Graph { get; set; }

        /// <summary>
        /// The Azure Portal endpoint.
        /// </summary>
        [JsonProperty(PropertyName = "portal")]
        public string Portal { get; set; }

        /// <summary>
        /// The audience for Microsoft Graph.
        /// </summary>
        [JsonProperty(PropertyName = "graphAudience")]
        public string GraphAudience { get; set; }

        /// <summary>
        /// The audience for Azure Data Lake.
        /// Defaults to <c>https://datalake.azure.net/</c>.
        /// </summary>
        [JsonProperty(PropertyName = "activeDirectoryDataLake")]
        public string ActiveDirectoryDataLake { get; set; }

        /// <summary>
        /// The audience for Azure Branch.
        /// Defaults to <c>https://batch.core.windows.net/</c>.
        /// </summary>
        [JsonProperty(PropertyName = "batch")]
        public string Batch { get; set; }

        /// <summary>
        /// The audience for Azure Media Services.
        /// Defaults to <c>https://rest.media.azure.net</c>.
        /// </summary>
        [JsonProperty(PropertyName = "media")]
        public string Media { get; set; }

        /// <summary>
        /// The audience for Sql Management.
        /// Defaults to <c>https://management.core.windows.net:8443/</c>.
        /// </summary>
        [JsonProperty(PropertyName = "sqlManagement")]
        public string SqlManagement { get; set; }

        /// <summary>
        /// Documentation reference for VM image aliases.
        /// </summary>
        [JsonProperty(PropertyName = "vmImageAliasDoc")]
        public string VmImageAliasDoc { get; set; }

        /// <summary>
        /// The URL for Azure Resource Manager.
        /// Defaults to <c>https://management.azure.com/</c>.
        /// </summary>
        [JsonProperty(PropertyName = "resourceManager")]
        public string ResourceManager { get; set; }

        /// <summary>
        /// Authentication properties for the cloud environment.
        /// </summary>
        [JsonProperty(PropertyName = "authentication")]
        public CloudEnvironmentAuthentication Authentication { get; set; }

        /// <summary>
        /// A list of common suffixes that may be cloud environment specific.
        /// Use these values instead of hard coding in IaC.
        /// </summary>
        [JsonProperty(PropertyName = "suffixes")]
        public CloudEnvironmentSuffixes Suffixes { get; set; }
    }

    /// <summary>
    /// Authentication properties for the cloud environment.
    /// </summary>
    public sealed class CloudEnvironmentAuthentication
    {
        /// <summary>
        /// Azure AD login endpoint.
        /// Defaults to <c>https://login.microsoftonline.com/</c>.
        /// </summary>
        [JsonProperty(PropertyName = "loginEndpoint")]
        public string loginEndpoint { get; set; }

        /// <summary>
        /// Azure Resource Manager audiences.
        /// </summary>
        [JsonProperty(PropertyName = "audiences")]
        public string[] audiences { get; set; }

        /// <summary>
        /// Azure AD tenant to use.
        /// Default to <c>common</c>.
        /// </summary>
        [JsonProperty(PropertyName = "tenant")]
        public string tenant { get; set; }

        /// <summary>
        /// The identity provider to use.
        /// Defaults to <c>AAD</c>.
        /// </summary>
        [JsonProperty(PropertyName = "identityProvider")]
        public string identityProvider { get; set; }
    }

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
