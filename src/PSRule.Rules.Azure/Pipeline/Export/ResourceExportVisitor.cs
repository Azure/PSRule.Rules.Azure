// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data;

namespace PSRule.Rules.Azure.Pipeline.Export
{
    /// <summary>
    /// Defines a class that gets and sets additional properties and sub-resources of a resource from an Azure subscription.
    /// </summary>
    internal sealed class ResourceExportVisitor
    {
        private const string PROPERTY_ID = "id";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_ZONES = "zones";
        private const string PROPERTY_RESOURCES = "resources";
        private const string PROPERTY_SUBSCRIPTIONID = "subscriptionId";
        private const string PROPERTY_KIND = "kind";
        private const string PROPERTY_SHAREDKEY = "sharedKey";
        private const string PROPERTY_NETWORKPROFILE = "networkProfile";
        private const string PROPERTY_NETWORKINTERFACES = "networkInterfaces";
        private const string PROPERTY_NETOWORKPLUGIN = "networkPlugin";
        private const string PROPERTY_AGENTPOOLPROFILES = "agentPoolProfiles";
        private const string PROPERTY_TENANTID = "tenantId";

        private const string TYPE_CONTAINERSERVICE_MANAGEDCLUSTERS = "Microsoft.ContainerService/managedClusters";
        private const string TYPE_CONTAINERREGISTRY_REGISTRIES = "Microsoft.ContainerRegistry/registries";
        private const string TYPE_CDN_PROFILES_ENDPOINTS = "Microsoft.Cdn/profiles/endpoints";
        private const string TYPE_AUTOMATION_ACCOUNTS = "Microsoft.Automation/automationAccounts";
        private const string TYPE_APIMANAGEMENT_SERVICE = "Microsoft.ApiManagement/service";
        private const string TYPE_SQL_SERVERS = "Microsoft.Sql/servers";
        private const string TYPE_SQL_DATABASES = "Microsoft.Sql/servers/databases";
        private const string TYPE_POSTGRESQL_SERVERS = "Microsoft.DBforPostgreSQL/servers";
        private const string TYPE_MYSQL_SERVERS = "Microsoft.DBforMySQL/servers";
        private const string TYPE_STORAGE_ACCOUNTS = "Microsoft.Storage/storageAccounts";
        private const string TYPE_WEB_APP = "Microsoft.Web/sites";
        private const string TYPE_WEB_APPSLOT = "Microsoft.Web/sites/slots";
        private const string TYPE_RECOVERYSERVICES_VAULT = "Microsoft.RecoveryServices/vaults";
        private const string TYPE_COMPUTER_VIRTUALMACHINE = "Microsoft.Compute/virtualMachines";
        private const string TYPE_KEYVAULT_VAULT = "Microsoft.KeyVault/vaults";
        private const string TYPE_NETWORK_FRONTDOOR = "Microsoft.Network/frontDoors";
        private const string TYPE_NETWORK_CONNECTION = "Microsoft.Network/connections";
        private const string TYPE_SUBSCRIPTION = "Microsoft.Subscription";
        private const string TYPE_RESOURCES_RESOURCEGROUP = "Microsoft.Resources/resourceGroups";
        private const string TYPE_KUSTO_CLUSTER = "Microsoft.Kusto/Clusters";
        private const string TYPE_EVENTHUB_NAMESPACE = "Microsoft.EventHub/namespaces";
        private const string TYPE_SERVICEBUS_NAMESPACE = "Microsoft.ServiceBus/namespaces";

        private const string PROVIDERTYPE_DIAGNOSTICSETTINGS = "/providers/microsoft.insights/diagnosticSettings";
        private const string PROVIDERTYPE_ROLEASSIGNMENTS = "/providers/Microsoft.Authorization/roleAssignments";
        private const string PROVIDERTYPE_RESOURCELOCKS = "/providers/Microsoft.Authorization/locks";
        private const string PROVIDERTYPE_AUTOPROVISIONING = "/providers/Microsoft.Security/autoProvisioningSettings";
        private const string PROVIDERTYPE_SECURITYCONTACTS = "/providers/Microsoft.Security/securityContacts";
        private const string PROVIDERTYPE_SECURITYPRICINGS = "/providers/Microsoft.Security/pricings";
        private const string PROVIDERTYPE_POLICYASSIGNMENTS = "/providers/Microsoft.Authorization/policyAssignments";
        private const string PROVIDERTYPE_CLASSICADMINISTRATORS = "/providers/Microsoft.Authorization/classicAdministrators";

        private const string MASKED_VALUE = "*** MASKED ***";

        private const string APIVERSION_2021_11_01 = "2021-11-01";
        private const string APIVERSION_2014_04_01 = "2014-04-01";
        private const string APIVERSION_2017_12_01 = "2017-12-01";
        private const string APIVERSION_2021_08_01 = "2021-08-01";
        private const string APIVERSION_2022_07_01 = "2022-07-01";

        private readonly ProviderData _ProviderData;

        public ResourceExportVisitor()
        {
            _ProviderData = new ProviderData();
        }

        private sealed class ResourceContext
        {
            private readonly IResourceExportContext _Context;

            public ResourceContext(IResourceExportContext context, string tenantId)
            {
                _Context = context;
                TenantId = tenantId;
            }

            public string TenantId { get; }

            internal async Task<JObject> GetAsync(string resourceId, string apiVersion)
            {
                return await _Context.GetAsync(TenantId, resourceId, apiVersion);
            }

            internal async Task<JObject[]> ListAsync(string resourceId, string apiVersion)
            {
                return await _Context.ListAsync(TenantId, resourceId, apiVersion);
            }
        }

        public async Task VisitAsync(IResourceExportContext context, JObject resource)
        {
            await ExpandResource(context, resource);
        }

        private async Task<bool> ExpandResource(IResourceExportContext context, JObject resource)
        {
            if (resource == null ||
                !resource.TryStringProperty(PROPERTY_TYPE, out var resourceType) ||
                string.IsNullOrWhiteSpace(resourceType) ||
                !resource.TryGetProperty(PROPERTY_ID, out var resourceId) ||
                !resource.TryGetProperty(PROPERTY_TENANTID, out var tenantId))
                return false;

            var resourceContext = new ResourceContext(context, tenantId);

            // Set the subscription Id.
            SetSubscriptionId(resource, resourceId);

            // Expand properties for the resource.
            await GetProperties(resourceContext, resource, resourceType, resourceId);

            // Expand sub-resources for the resource.
            return await VisitResourceGroup(resourceContext, resource, resourceType, resourceId) ||
                await VisitAPIManagement(resourceContext, resource, resourceType, resourceId) ||
                await VisitAutomationAccount(resourceContext, resource, resourceType, resourceId) ||
                await VisitCDNEndpoint(resourceContext, resource, resourceType, resourceId) ||
                await VisitContainerRegistry(resourceContext, resource, resourceType, resourceId) ||
                await VisitAKSCluster(resourceContext, resource, resourceType, resourceId) ||
                await VisitSqlServers(resourceContext, resource, resourceType, resourceId) ||
                await VisitSqlDatabase(resourceContext, resource, resourceType, resourceId) ||
                await VisitPostgreSqlServer(resourceContext, resource, resourceType, resourceId) ||
                await VisitMySqlServer(resourceContext, resource, resourceType, resourceId) ||
                await VisitStorageAccount(resourceContext, resource, resourceType, resourceId) ||
                await VisitWebApp(resourceContext, resource, resourceType, resourceId) ||
                await VisitRecoveryServicesVault(resourceContext, resource, resourceType, resourceId) ||
                await VisitVirtualMachine(resourceContext, resource, resourceType, resourceId) ||
                await VisitKeyVault(resourceContext, resource, resourceType, resourceId) ||
                await VisitFrontDoorClassic(resourceContext, resource, resourceType, resourceId) ||
                await VisitSubscription(resourceContext, resource, resourceType, resourceId) ||
                await VisitDataExplorerCluster(resourceContext, resource, resourceType, resourceId) ||
                await VisitEventHubNamespace(resourceContext, resource, resourceType, resourceId) ||
                await VisitServiceBusNamespace(resourceContext, resource, resourceType, resourceId) ||
                VisitNetworkConnection(resource, resourceType);
        }

        /// <summary>
        /// Get the <c>properties</c> property for a resource if it hasn't been already expanded.
        /// </summary>
        private async Task GetProperties(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (string.Equals(resourceType, TYPE_SUBSCRIPTION, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(resourceType, TYPE_RESOURCES_RESOURCEGROUP, StringComparison.OrdinalIgnoreCase) ||
                resource.ContainsKeyInsensitive(PROPERTY_PROPERTIES) ||
                !TryGetLatestAPIVersion(resourceType, out var apiVersion))
                return;

            var full = await GetResource(context, resourceId, apiVersion);
            if (full == null)
                return;

            if (full.TryGetProperty(PROPERTY_PROPERTIES, out JObject properties))
                resource.Add(PROPERTY_PROPERTIES, properties);
        }

        private static void SetSubscriptionId(JObject resource, string resourceId)
        {
            if (ResourceHelper.TrySubscriptionId(resourceId, out var subscriptionId))
                resource.Add(PROPERTY_SUBSCRIPTIONID, subscriptionId);
        }

        private bool TryGetLatestAPIVersion(string resourceType, out string apiVersion)
        {
            apiVersion = null;
            if (!_ProviderData.TryResourceType(resourceType, out var data) ||
                data.ApiVersions == null ||
                data.ApiVersions.Length == 0)
                return false;

            apiVersion = data.ApiVersions[0];
            return true;
        }

        private static async Task<bool> VisitServiceBusNamespace(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_SERVICEBUS_NAMESPACE, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "queues", "2021-06-01-preview"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "topics", "2021-06-01-preview"));
            return true;
        }

        private static async Task<bool> VisitEventHubNamespace(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_EVENTHUB_NAMESPACE, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "eventhubs", "2021-11-01"));
            return true;
        }

        private static async Task<bool> VisitDataExplorerCluster(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_KUSTO_CLUSTER, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "databases", "2021-08-27"));
            return true;
        }

        private static async Task<bool> VisitResourceGroup(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_RESOURCES_RESOURCEGROUP, StringComparison.OrdinalIgnoreCase))
                return false;

            await GetRoleAssignments(context, resource, resourceId);
            await GetResourceLocks(context, resource, resourceId);
            return true;
        }

        private static async Task<bool> VisitSubscription(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_SUBSCRIPTION, StringComparison.OrdinalIgnoreCase))
                return false;

            await GetRoleAssignments(context, resource, resourceId);
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_CLASSICADMINISTRATORS), "2015-07-01"));
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_AUTOPROVISIONING), "2017-08-01-preview"));
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_SECURITYCONTACTS), "2017-08-01-preview"));
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_SECURITYPRICINGS), "2018-06-01"));
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_POLICYASSIGNMENTS), "2019-06-01"));
            return true;
        }

        private static bool VisitNetworkConnection(JObject resource, string resourceType)
        {
            if (!string.Equals(resourceType, TYPE_NETWORK_CONNECTION, StringComparison.OrdinalIgnoreCase))
                return false;

            if (resource.TryGetProperty(PROPERTY_PROPERTIES, out JObject properties))
                properties.ReplaceProperty(PROPERTY_SHAREDKEY, JValue.CreateString(MASKED_VALUE));

            return true;
        }

        private static async Task<bool> VisitFrontDoorClassic(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_NETWORK_FRONTDOOR, StringComparison.OrdinalIgnoreCase))
                return false;

            await GetDiagnosticSettings(context, resource, resourceId);
            return true;
        }

        private static async Task<bool> VisitKeyVault(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_KEYVAULT_VAULT, StringComparison.OrdinalIgnoreCase))
                return false;

            await GetDiagnosticSettings(context, resource, resourceId);
            if (resource.TryGetProperty(PROPERTY_PROPERTIES, out JObject properties) &&
                properties.TryGetProperty(PROPERTY_TENANTID, out var tenantId) &&
                string.Equals(tenantId, context.TenantId))
                AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "keys", APIVERSION_2022_07_01));

            return true;
        }

        private static async Task<bool> VisitVirtualMachine(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_COMPUTER_VIRTUALMACHINE, StringComparison.OrdinalIgnoreCase))
                return false;

            if (resource.TryGetProperty(PROPERTY_PROPERTIES, out JObject properties) &&
                properties.TryGetProperty(PROPERTY_NETWORKPROFILE, out JObject networkProfile) &&
                networkProfile.TryGetProperty(PROPERTY_NETWORKINTERFACES, out JArray networkInterfaces))
            {
                foreach (var netif in networkInterfaces.Values<JObject>())
                {
                    if (netif.TryGetProperty(PROPERTY_ID, out var id))
                        AddSubResource(resource, await GetResource(context, id, APIVERSION_2022_07_01));
                }
            }
            return true;
        }

        private static async Task<bool> VisitRecoveryServicesVault(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_RECOVERYSERVICES_VAULT, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "replicationRecoveryPlans", "2022-09-10"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "replicationAlertSettings", "2022-09-10"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "backupstorageconfig/vaultstorageconfig", "2022-09-01-preview"));
            return true;
        }

        private static async Task<bool> VisitWebApp(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_WEB_APP, StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(resourceType, TYPE_WEB_APPSLOT, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "config", "2022-03-01"));
            return true;
        }

        private static async Task<bool> VisitStorageAccount(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_STORAGE_ACCOUNTS, StringComparison.OrdinalIgnoreCase))
                return false;

            if (resource.TryGetProperty(PROPERTY_KIND, out var kind) &&
                !string.Equals(kind, "FileStorage", StringComparison.OrdinalIgnoreCase))
            {
                var blobServices = await GetSubResourcesByType(context, resourceId, "blobServices", "2022-05-01");
                AddSubResource(resource, blobServices);
                foreach (var blobService in blobServices)
                {
                    AddSubResource(resource, await GetSubResourcesByType(context, blobService[PROPERTY_ID].Value<string>(), "containers", "2022-05-01"));
                }
            }
            return true;
        }

        private static async Task<bool> VisitMySqlServer(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_MYSQL_SERVERS, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "firewallRules", APIVERSION_2017_12_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "securityAlertPolicies", APIVERSION_2017_12_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "configurations", APIVERSION_2017_12_01));
            return true;
        }

        private static async Task<bool> VisitPostgreSqlServer(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_POSTGRESQL_SERVERS, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "firewallRules", APIVERSION_2017_12_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "securityAlertPolicies", APIVERSION_2017_12_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "configurations", APIVERSION_2017_12_01));
            return true;
        }

        private static async Task<bool> VisitSqlDatabase(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_SQL_DATABASES, StringComparison.OrdinalIgnoreCase))
                return false;

            var lowerId = resourceId.ToLower();
            AddSubResource(resource, await GetSubResourcesByType(context, lowerId, "dataMaskingPolicies", APIVERSION_2014_04_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "transparentDataEncryption", APIVERSION_2021_11_01));
            AddSubResource(resource, await GetSubResourcesByType(context, lowerId, "connectionPolicies", APIVERSION_2014_04_01));
            AddSubResource(resource, await GetSubResourcesByType(context, lowerId, "geoBackupPolicies", APIVERSION_2014_04_01));
            return true;
        }

        private static async Task<bool> VisitSqlServers(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_SQL_SERVERS, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "firewallRules", APIVERSION_2021_11_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "administrators", APIVERSION_2021_11_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "securityAlertPolicies", APIVERSION_2021_11_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "vulnerabilityAssessments", APIVERSION_2021_11_01));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "auditingSettings", APIVERSION_2021_11_01));
            return true;
        }

        private static async Task<bool> VisitAKSCluster(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_CONTAINERSERVICE_MANAGEDCLUSTERS, StringComparison.OrdinalIgnoreCase))
                return false;

            // Get related VNET
            if (resource.TryGetProperty(PROPERTY_PROPERTIES, out JObject properties) &&
                properties.TryGetProperty(PROPERTY_NETWORKPROFILE, out JObject networkProfile) &&
                networkProfile.TryGetProperty(PROPERTY_NETOWORKPLUGIN, out var networkPlugin) &&
                string.Equals(networkPlugin, "azure", StringComparison.OrdinalIgnoreCase) &&
                properties.TryArrayProperty(PROPERTY_AGENTPOOLPROFILES, out var agentPoolProfiles) &&
                agentPoolProfiles.Count > 0)
            {
                for (var i = 0; i < agentPoolProfiles.Count; i++)
                {
                    if (agentPoolProfiles[i] is JObject profile && profile.TryGetProperty("vnetSubnetID", out var vnetSubnetID))
                    {
                        // Get VNET.
                        AddSubResource(resource, await GetResource(context, vnetSubnetID, APIVERSION_2022_07_01));
                    }
                }
            }

            // Get diagnostic settings
            await GetDiagnosticSettings(context, resource, resourceId);
            return true;
        }

        private static async Task<bool> VisitContainerRegistry(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_CONTAINERREGISTRY_REGISTRIES, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "replications", "2022-02-01-preview"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "webhooks", "2022-02-01-preview"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "tasks", "2019-06-01-preview"));
            return true;
        }

        private static async Task<bool> VisitCDNEndpoint(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_CDN_PROFILES_ENDPOINTS, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "customDomains", "2021-06-01"));
            return true;
        }

        private static async Task<bool> VisitAutomationAccount(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_AUTOMATION_ACCOUNTS, StringComparison.OrdinalIgnoreCase))
                return false;

            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "variables", "2022-08-08"));
            AddSubResource(resource, await GetSubResourcesByType(context, resourceId, "webhooks", "2015-10-31"));
            return true;
        }

        private static async Task<bool> VisitAPIManagement(ResourceContext context, JObject resource, string resourceType, string resourceId)
        {
            if (!string.Equals(resourceType, TYPE_APIMANAGEMENT_SERVICE, StringComparison.OrdinalIgnoreCase))
                return false;

            // APIs
            var apis = await GetSubResourcesByType(context, resourceId, "apis", APIVERSION_2021_08_01);
            AddSubResource(resource, apis);

            var backends = await GetSubResourcesByType(context, resourceId, "backends", APIVERSION_2021_08_01);
            AddSubResource(resource, backends);

            var products = await GetSubResourcesByType(context, resourceId, "products", APIVERSION_2021_08_01);
            AddSubResource(resource, products);

            var policies = await GetSubResourcesByType(context, resourceId, "policies", APIVERSION_2021_08_01);
            AddSubResource(resource, policies);

            var identityProviders = await GetSubResourcesByType(context, resourceId, "identityProviders", APIVERSION_2021_08_01);
            AddSubResource(resource, identityProviders);

            var diagnostics = await GetSubResourcesByType(context, resourceId, "diagnostics", APIVERSION_2021_08_01);
            AddSubResource(resource, diagnostics);

            var loggers = await GetSubResourcesByType(context, resourceId, "loggers", APIVERSION_2021_08_01);
            AddSubResource(resource, loggers);

            var certificates = await GetSubResourcesByType(context, resourceId, "certificates", APIVERSION_2021_08_01);
            AddSubResource(resource, certificates);

            var namedValues = await GetSubResourcesByType(context, resourceId, "namedValues", APIVERSION_2021_08_01);
            AddSubResource(resource, namedValues);

            var portalSettings = await GetSubResourcesByType(context, resourceId, "portalsettings", APIVERSION_2021_08_01);
            AddSubResource(resource, portalSettings);

            return true;
        }

        /// <summary>
        /// Get diagnostics for the specified resource type.
        /// </summary>
        private static async Task GetDiagnosticSettings(ResourceContext context, JObject resource, string resourceId)
        {
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_DIAGNOSTICSETTINGS), "2021-05-01-preview"));
        }

        private static async Task GetRoleAssignments(ResourceContext context, JObject resource, string resourceId)
        {
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_ROLEASSIGNMENTS), "2022-04-01"));
        }

        private static async Task GetResourceLocks(ResourceContext context, JObject resource, string resourceId)
        {
            AddSubResource(resource, await GetResource(context, string.Concat(resourceId, PROVIDERTYPE_RESOURCELOCKS), "2016-09-01"));
        }

        private static void AddSubResource(JObject parent, JObject child)
        {
            if (child == null)
                return;

            parent.UseProperty<JArray>(PROPERTY_RESOURCES, out var resources);
            resources.Add(child);
        }

        private static void AddSubResource(JObject parent, JObject[] children)
        {
            if (children == null || children.Length == 0)
                return;

            parent.UseProperty<JArray>(PROPERTY_RESOURCES, out var resources);
            for (var i = 0; i < children.Length; i++)
                resources.Add(children[i]);
        }

        private static async Task<JObject> GetResource(ResourceContext context, string resourceId, string apiVersion)
        {
            return await context.GetAsync(resourceId, apiVersion);
        }

        private static async Task<JObject[]> GetSubResourcesByType(ResourceContext context, string resourceId, string type, string apiVersion)
        {
            return await context.ListAsync(string.Concat(resourceId, '/', type), apiVersion);
        }
    }
}
