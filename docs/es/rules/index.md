---
generated: True
title: Reference
---

# Reference

The following rules and features are included in PSRule for Azure.

!!! Info
    The rule _release_ indicates if the Azure feature is _generally available (GA)_ or available under _preview_.
    Features provided under previews may have additional limits, availability restrictions, or [terms][1].
    By default, PSRule for Azure will not provide recommendations that relate to preview features.
    To include rules for preview features see [working with baselines][2].

  [1]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
  [2]: ../../working-with-baselines.md

## Rules

The following rules are included in PSRule for Azure.

Reference | Name | Synopsis | Release
--------- | ---- | -------- | -------
AZR-000001 | [Azure.ACR.Usage](Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | GA
AZR-000002 | [Azure.ACR.ContainerScan](Azure.ACR.ContainerScan.md) | Container images or their base images may have vulnerabilities discovered after they are built. | GA
AZR-000003 | [Azure.ACR.ImageHealth](Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | GA
AZR-000004 | [Azure.ACR.GeoReplica](Azure.ACR.GeoReplica.md) | Applications or infrastructure relying on a container image may fail if the registry is not available at the time they start. | GA
AZR-000005 | [Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | The local admin account allows depersonalized access to a container registry using a shared secret. | GA
AZR-000006 | [Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | GA
AZR-000007 | [Azure.ACR.Name](Azure.ACR.Name.md) | Container registry names should meet naming requirements. | GA
AZR-000008 | [Azure.ACR.Quarantine](Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Preview
AZR-000009 | [Azure.ACR.ContentTrust](Azure.ACR.ContentTrust.md) | Use container images signed by a trusted image publisher. | GA
AZR-000010 | [Azure.ACR.Retention](Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Preview
AZR-000011 | [Azure.ADX.Usage](Azure.ADX.Usage.md) | Regularly remove unused resources to reduce costs. | GA
AZR-000012 | [Azure.ADX.ManagedIdentity](Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | GA
AZR-000013 | [Azure.ADX.DiskEncryption](Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | GA
AZR-000014 | [Azure.ADX.SLA](Azure.ADX.SLA.md) | Use SKUs that include an SLA when configuring Azure Data Explorer (ADX) clusters. | GA
AZR-000015 | [Azure.AKS.Version](Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | GA
AZR-000016 | [Azure.AKS.PoolVersion](Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | GA
AZR-000017 | [Azure.AKS.PoolScaleSet](Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | GA
AZR-000018 | [Azure.AKS.NodeMinPods](Azure.AKS.NodeMinPods.md) | Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods. | GA
AZR-000019 | [Azure.AKS.AutoScaling](Azure.AKS.AutoScaling.md) | Use autoscaling to scale clusters based on workload requirements. | GA
AZR-000020 | [Azure.AKS.CNISubnetSize](Azure.AKS.CNISubnetSize.md) | AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues. | GA
AZR-000021 | [Azure.AKS.AvailabilityZone](Azure.AKS.AvailabilityZone.md) | AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability. | GA
AZR-000022 | [Azure.AKS.AuditLogs](Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | GA
AZR-000023 | [Azure.AKS.PlatformLogs](Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | GA
AZR-000024 | [Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of system nodes for failover and updates. | GA
AZR-000025 | [Azure.AKS.ManagedIdentity](Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | GA
AZR-000026 | [Azure.AKS.StandardLB](Azure.AKS.StandardLB.md) | Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU. | GA
AZR-000027 | [Azure.AKS.NetworkPolicy](Azure.AKS.NetworkPolicy.md) | AKS clusters without inter-pod network restrictions may be permit unauthorized lateral movement. | GA
AZR-000028 | [Azure.AKS.AzurePolicyAddOn](Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | GA
AZR-000029 | [Azure.AKS.ManagedAAD](Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | GA
AZR-000030 | [Azure.AKS.AuthorizedIPs](Azure.AKS.AuthorizedIPs.md) | Restrict access to API server endpoints to authorized IP addresses. | GA
AZR-000031 | [Azure.AKS.LocalAccounts](Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | GA
AZR-000032 | [Azure.AKS.AzureRBAC](Azure.AKS.AzureRBAC.md) | Use Azure RBAC for Kubernetes Authorization with AKS clusters. | GA
AZR-000033 | [Azure.AKS.SecretStore](Azure.AKS.SecretStore.md) | Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vault. | GA
AZR-000034 | [Azure.AKS.SecretStoreRotation](Azure.AKS.SecretStoreRotation.md) | Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters. | GA
AZR-000035 | [Azure.AKS.HttpAppRouting](Azure.AKS.HttpAppRouting.md) | Disable HTTP application routing add-on in AKS clusters. | GA
AZR-000036 | [Azure.AKS.AutoUpgrade](Azure.AKS.AutoUpgrade.md) | Configure AKS to automatically upgrade to newer supported AKS versions as they are made available. | GA
AZR-000038 | [Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | GA
AZR-000039 | [Azure.AKS.Name](Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | GA
AZR-000040 | [Azure.AKS.DNSPrefix](Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | GA
AZR-000041 | [Azure.AKS.ContainerInsights](Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | GA
AZR-000042 | [Azure.APIM.HTTPEndpoint](Azure.APIM.HTTPEndpoint.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | GA
AZR-000043 | [Azure.APIM.APIDescriptors](Azure.APIM.APIDescriptors.md) | APIs should have a display name and description. | GA
AZR-000044 | [Azure.APIM.HTTPBackend](Azure.APIM.HTTPBackend.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | GA
AZR-000045 | [Azure.APIM.EncryptValues](Azure.APIM.EncryptValues.md) | Encrypt all API Management named values with Key Vault secrets. | GA
AZR-000046 | [Azure.APIM.ProductSubscription](Azure.APIM.ProductSubscription.md) | Configure products to require a subscription. | GA
AZR-000047 | [Azure.APIM.ProductApproval](Azure.APIM.ProductApproval.md) | Configure products to require approval. | GA
AZR-000048 | [Azure.APIM.SampleProducts](Azure.APIM.SampleProducts.md) | Remove starter and unlimited sample products. | GA
AZR-000049 | [Azure.APIM.ProductDescriptors](Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | GA
AZR-000050 | [Azure.APIM.ProductTerms](Azure.APIM.ProductTerms.md) | Set legal terms for each product registered in API Management. | GA
AZR-000051 | [Azure.APIM.CertificateExpiry](Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | GA
AZR-000052 | [Azure.APIM.AvailabilityZone](Azure.APIM.AvailabilityZone.md) |  API Management instances should use availability zones in supported regions for high availability. | GA
AZR-000053 | [Azure.APIM.ManagedIdentity](Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | GA
AZR-000054 | [Azure.APIM.Protocols](Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2 for client and backend communication. | GA
AZR-000055 | [Azure.APIM.Ciphers](Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers for client or backend communication. | GA
AZR-000056 | [Azure.APIM.Name](Azure.APIM.Name.md) | API Management service names should meet naming requirements. | GA
AZR-000057 | [Azure.AppConfig.SKU](Azure.AppConfig.SKU.md) | App Configuration should use a minimum size of Standard. | GA
AZR-000058 | [Azure.AppConfig.Name](Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | GA
AZR-000059 | [Azure.AppGw.UseHTTPS](Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | GA
AZR-000060 | [Azure.AppGw.AvailabilityZone](Azure.AppGw.AvailabilityZone.md) | Application Gateway (App Gateway) should use availability zones in supported regions for improved resiliency. | GA
AZR-000061 | [Azure.AppGw.MinInstance](Azure.AppGw.MinInstance.md) | Application Gateways should use a minimum of two instances. | GA
AZR-000062 | [Azure.AppGw.MinSku](Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | GA
AZR-000063 | [Azure.AppGw.UseWAF](Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use protect endpoints with WAF. | GA
AZR-000064 | [Azure.AppGw.SSLPolicy](Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | GA
AZR-000065 | [Azure.AppGw.Prevention](Azure.AppGw.Prevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | GA
AZR-000066 | [Azure.AppGw.WAFEnabled](Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | GA
AZR-000067 | [Azure.AppGw.OWASP](Azure.AppGw.OWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | GA
AZR-000068 | [Azure.AppGw.WAFRules](Azure.AppGw.WAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | GA
AZR-000069 | [Azure.AppInsights.Workspace](Azure.AppInsights.Workspace.md) | Configure Application Insights resources to store data in a workspace. | GA
AZR-000070 | [Azure.AppInsights.Name](Azure.AppInsights.Name.md) | Azure Application Insights resources names should meet naming requirements. | GA
AZR-000071 | [Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | App Service Plan should use a minimum number of instances for failover. | GA
AZR-000072 | [Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | GA
AZR-000073 | [Azure.AppService.MinTLS](Azure.AppService.MinTLS.md) | App Service should reject TLS versions older than 1.2. | GA
AZR-000074 | [Azure.AppService.RemoteDebug](Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | GA
AZR-000075 | [Azure.AppService.NETVersion](Azure.AppService.NETVersion.md) | Configure applications to use newer .NET versions. | GA
AZR-000076 | [Azure.AppService.PHPVersion](Azure.AppService.PHPVersion.md) | Configure applications to use newer PHP runtime versions. | GA
AZR-000077 | [Azure.AppService.AlwaysOn](Azure.AppService.AlwaysOn.md) | Configure Always On for App Service apps. | GA
AZR-000078 | [Azure.AppService.HTTP2](Azure.AppService.HTTP2.md) | Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency. | GA
AZR-000079 | [Azure.AppService.WebProbe](Azure.AppService.WebProbe.md) | Configure and enable instance health probes. | GA
AZR-000080 | [Azure.AppService.WebProbePath](Azure.AppService.WebProbePath.md) | Configure a dedicated path for health probe requests. | GA
AZR-000081 | [Azure.AppService.WebSecureFtp](Azure.AppService.WebSecureFtp.md) | Web apps should disable insecure FTP and configure SFTP when required. | GA
AZR-000082 | [Azure.AppService.ManagedIdentity](Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | GA
AZR-000083 | [Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | GA
AZR-000084 | [Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | GA
AZR-000085 | [Azure.ASG.Name](Azure.ASG.Name.md) | Application Security Group (ASG) names should meet naming requirements. | GA
AZR-000086 | [Azure.Automation.EncryptVariables](Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | GA
AZR-000087 | [Azure.Automation.WebHookExpiry](Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | GA
AZR-000088 | [Azure.Automation.AuditLogs](Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | GA
AZR-000089 | [Azure.Automation.PlatformLogs](Azure.Automation.PlatformLogs.md) | Ensure automation account platform diagnostic logs are enabled. | GA
AZR-000090 | [Azure.Automation.ManagedIdentity](Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | GA
AZR-000091 | [Azure.CDN.EndpointName](Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | GA
AZR-000092 | [Azure.CDN.MinTLS](Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | GA
AZR-000093 | [Azure.CDN.HTTP](Azure.CDN.HTTP.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | GA
AZR-000094 | [Azure.ContainerApp.Insecure](Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | GA
AZR-000095 | [Azure.Cosmos.DisableMetadataWrite](Azure.Cosmos.DisableMetadataWrite.md) | Use Entra ID identities for management place operations in Azure Cosmos DB. | GA
AZR-000096 | [Azure.Cosmos.AccountName](Azure.Cosmos.AccountName.md) | Cosmos DB account names should meet naming requirements. | GA
AZR-000097 | [Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | GA
AZR-000098 | [Azure.EventGrid.TopicPublicAccess](Azure.EventGrid.TopicPublicAccess.md) | Use Private Endpoints to access Event Grid topics and domains. | GA
AZR-000099 | [Azure.EventGrid.ManagedIdentity](Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | GA
AZR-000100 | [Azure.EventGrid.DisableLocalAuth](Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | GA
AZR-000101 | [Azure.EventHub.Usage](Azure.EventHub.Usage.md) | Regularly remove unused resources to reduce costs. | GA
AZR-000102 | [Azure.EventHub.DisableLocalAuth](Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Entra ID identities. | GA
AZR-000103 | [Azure.Firewall.Name](Azure.Firewall.Name.md) | Firewall names should meet naming requirements. | GA
AZR-000104 | [Azure.Firewall.PolicyName](Azure.Firewall.PolicyName.md) | Firewall policy names should meet naming requirements. | GA
AZR-000105 | [Azure.Firewall.Mode](Azure.Firewall.Mode.md) | Deny high confidence malicious IP addresses and domains on classic managed Azure Firewalls. | GA
AZR-000106 | [Azure.FrontDoor.MinTLS](Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | GA
AZR-000107 | [Azure.FrontDoor.Logs](Azure.FrontDoor.Logs.md) | Audit and monitor access through Azure Front Door profiles. | GA
AZR-000108 | [Azure.FrontDoor.Probe](Azure.FrontDoor.Probe.md) | Use health probes to check the health of each backend. | GA
AZR-000109 | [Azure.FrontDoor.ProbeMethod](Azure.FrontDoor.ProbeMethod.md) | Configure health probes to use HEAD requests to reduce performance overhead. | GA
AZR-000110 | [Azure.FrontDoor.ProbePath](Azure.FrontDoor.ProbePath.md) | Configure a dedicated path for health probe requests. | GA
AZR-000111 | [Azure.FrontDoor.UseWAF](Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | GA
AZR-000112 | [Azure.FrontDoor.State](Azure.FrontDoor.State.md) | Enable Azure Front Door Classic instance. | GA
AZR-000113 | [Azure.FrontDoor.Name](Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | GA
AZR-000114 | [Azure.FrontDoor.WAF.Mode](Azure.FrontDoor.WAF.Mode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | GA
AZR-000115 | [Azure.FrontDoor.WAF.Enabled](Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | GA
AZR-000116 | [Azure.FrontDoor.WAF.Name](Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | GA
AZR-000117 | [Azure.Identity.UserAssignedName](Azure.Identity.UserAssignedName.md) | Managed Identity names should meet naming requirements. | GA
AZR-000118 | [Azure.KeyVault.AccessPolicy](Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | GA
AZR-000119 | [Azure.KeyVault.Logs](Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | GA
AZR-000120 | [Azure.KeyVault.Name](Azure.KeyVault.Name.md) | Key Vault names should meet naming requirements. | GA
AZR-000121 | [Azure.KeyVault.SecretName](Azure.KeyVault.SecretName.md) | Key Vault Secret names should meet naming requirements. | GA
AZR-000122 | [Azure.KeyVault.KeyName](Azure.KeyVault.KeyName.md) | Key Vault Key names should meet naming requirements. | GA
AZR-000123 | [Azure.KeyVault.AutoRotationPolicy](Azure.KeyVault.AutoRotationPolicy.md) | Key Vault keys should have auto-rotation enabled. | GA
AZR-000124 | [Azure.KeyVault.SoftDelete](Azure.KeyVault.SoftDelete.md) | Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion. | GA
AZR-000125 | [Azure.KeyVault.PurgeProtect](Azure.KeyVault.PurgeProtect.md) | Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items. | GA
AZR-000126 | [Azure.LB.Probe](Azure.LB.Probe.md) | Use a specific probe for web protocols. | GA
AZR-000127 | [Azure.LB.AvailabilityZone](Azure.LB.AvailabilityZone.md) | Load balancers deployed with Standard SKU should be zone-redundant for high availability. | GA
AZR-000128 | [Azure.LB.StandardSKU](Azure.LB.StandardSKU.md) | Load balancers should be deployed with Standard SKU for production workloads. | GA
AZR-000129 | [Azure.LB.Name](Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | GA
AZR-000130 | [Azure.LogicApp.LimitHTTPTrigger](Azure.LogicApp.LimitHTTPTrigger.md) | Limit HTTP request trigger access to trusted IP addresses. | GA
AZR-000131 | [Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | GA
AZR-000132 | [Azure.MySQL.MinTLS](Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | GA
AZR-000133 | [Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | GA
AZR-000134 | [Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | GA
AZR-000135 | [Azure.MySQL.FirewallIPRange](Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | GA
AZR-000136 | [Azure.MySQL.ServerName](Azure.MySQL.ServerName.md) | Azure MySQL DB server names should meet naming requirements. | GA
AZR-000137 | [Azure.NSG.AnyInboundSource](Azure.NSG.AnyInboundSource.md) | Network security groups (NSGs) should avoid rules that allow "any" as an inbound source. | GA
AZR-000138 | [Azure.NSG.DenyAllInbound](Azure.NSG.DenyAllInbound.md) | When all inbound traffic is denied, some functions that affect the reliability of your service may not work as expected. | GA
AZR-000139 | [Azure.NSG.LateralTraversal](Azure.NSG.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | GA
AZR-000140 | [Azure.NSG.Associated](Azure.NSG.Associated.md) | Network Security Groups (NSGs) should be associated to a subnet or network interface. | GA
AZR-000141 | [Azure.NSG.Name](Azure.NSG.Name.md) | Network Security Group (NSG) names should meet naming requirements. | GA
AZR-000142 | [Azure.Policy.Descriptors](Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description, and category. | GA
AZR-000143 | [Azure.Policy.AssignmentDescriptors](Azure.Policy.AssignmentDescriptors.md) | Policy assignments should use a display name and description. | GA
AZR-000144 | [Azure.Policy.AssignmentAssignedBy](Azure.Policy.AssignmentAssignedBy.md) | Policy assignments should use assignedBy metadata. | GA
AZR-000145 | [Azure.Policy.ExemptionDescriptors](Azure.Policy.ExemptionDescriptors.md) | Policy exemptions should use a display name and description. | GA
AZR-000146 | [Azure.Policy.WaiverExpiry](Azure.Policy.WaiverExpiry.md) | Configure policy waiver exemptions to expire. | GA
AZR-000147 | [Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | GA
AZR-000148 | [Azure.PostgreSQL.MinTLS](Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | GA
AZR-000149 | [Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | GA
AZR-000150 | [Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | GA
AZR-000151 | [Azure.PostgreSQL.FirewallIPRange](Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | GA
AZR-000152 | [Azure.PostgreSQL.ServerName](Azure.PostgreSQL.ServerName.md) | Azure PostgreSQL DB server names should meet naming requirements. | GA
AZR-000153 | [Azure.PrivateEndpoint.Name](Azure.PrivateEndpoint.Name.md) | Private Endpoint names should meet naming requirements. | GA
AZR-000154 | [Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP addresses should be attached or cleaned up if not in use. | GA
AZR-000155 | [Azure.PublicIP.Name](Azure.PublicIP.Name.md) | Public IP names should meet naming requirements. | GA
AZR-000156 | [Azure.PublicIP.DNSLabel](Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | GA
AZR-000157 | [Azure.PublicIP.AvailabilityZone](Azure.PublicIP.AvailabilityZone.md) | Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability. | GA
AZR-000158 | [Azure.PublicIP.StandardSKU](Azure.PublicIP.StandardSKU.md) | The basic SKU is being retired on 30 September 2025, and does not include several reliability and security features. | GA
AZR-000159 | [Azure.Redis.MinSKU](Azure.Redis.MinSKU.md) | Use Azure Cache for Redis instances of at least Standard C1. | GA
AZR-000160 | [Azure.Redis.MaxMemoryReserved](Azure.Redis.MaxMemoryReserved.md) | Configure maxmemory-reserved to reserve memory for non-cache operations. | GA
AZR-000161 | [Azure.Redis.AvailabilityZone](Azure.Redis.AvailabilityZone.md) | Premium Redis cache should be deployed with availability zones for high availability. | GA
AZR-000162 | [Azure.RedisEnterprise.Zones](Azure.RedisEnterprise.Zones.md) | Enterprise Redis cache should be zone-redundant for high availability. | GA
AZR-000163 | [Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | GA
AZR-000164 | [Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | GA
AZR-000165 | [Azure.Redis.PublicNetworkAccess](Azure.Redis.PublicNetworkAccess.md) | Redis cache should disable public network access. | GA
AZR-000166 | [Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | GA
AZR-000167 | [Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | GA
AZR-000168 | [Azure.ResourceGroup.Name](Azure.ResourceGroup.Name.md) | Resource Group names should meet naming requirements. | GA
AZR-000169 | [Azure.Route.Name](Azure.Route.Name.md) | Route table names should meet naming requirements. | GA
AZR-000170 | [Azure.RSV.StorageType](Azure.RSV.StorageType.md) | Recovery Services Vaults (RSV) not using geo-replicated storage (GRS) may be at risk. | GA
AZR-000171 | [Azure.RSV.ReplicationAlert](Azure.RSV.ReplicationAlert.md) | Recovery Services Vaults (RSV) without replication alerts configured may be at risk. | GA
AZR-000172 | [Azure.Search.SKU](Azure.Search.SKU.md) | Use the basic and standard tiers for entry level workloads. | GA
AZR-000173 | [Azure.Search.QuerySLA](Azure.Search.QuerySLA.md) | Use a minimum of 2 replicas to receive an SLA for index queries. | GA
AZR-000174 | [Azure.Search.IndexSLA](Azure.Search.IndexSLA.md) | Use a minimum of 3 replicas to receive an SLA for query and index updates. | GA
AZR-000175 | [Azure.Search.ManagedIdentity](Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | GA
AZR-000176 | [Azure.Search.Name](Azure.Search.Name.md) | AI Search service names should meet naming requirements. | GA
AZR-000177 | [Azure.ServiceBus.Usage](Azure.ServiceBus.Usage.md) | Regularly remove unused resources to reduce costs. | GA
AZR-000178 | [Azure.ServiceBus.DisableLocalAuth](Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Entra ID identities. | GA
AZR-000179 | [Azure.ServiceFabric.AAD](Azure.ServiceFabric.AAD.md) | Use Entra ID client authentication for Service Fabric clusters. | GA
AZR-000180 | [Azure.SignalR.Name](Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | GA
AZR-000181 | [Azure.SignalR.ManagedIdentity](Azure.SignalR.ManagedIdentity.md) | Configure SignalR Services to use managed identities to access Azure resources securely. | GA
AZR-000182 | [Azure.SignalR.SLA](Azure.SignalR.SLA.md) | Use SKUs that include an SLA when configuring SignalR Services. | GA
AZR-000183 | [Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | GA
AZR-000184 | [Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | GA
AZR-000185 | [Azure.SQL.FirewallIPRange](Azure.SQL.FirewallIPRange.md) | Each IP address in the permitted IP list is allowed network access to any databases hosted on the same logical server. | GA
AZR-000186 | [Azure.SQL.DefenderCloud](Azure.SQL.DefenderCloud.md) | Enable Microsoft Defender for Azure SQL logical server. | GA
AZR-000187 | [Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | GA
AZR-000188 | [Azure.SQL.AAD](Azure.SQL.AAD.md) | Use Entra ID authentication with Azure SQL databases. | GA
AZR-000189 | [Azure.SQL.MinTLS](Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | GA
AZR-000190 | [Azure.SQL.ServerName](Azure.SQL.ServerName.md) | Azure SQL logical server names should meet naming requirements. | GA
AZR-000191 | [Azure.SQL.TDE](Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | GA
AZR-000192 | [Azure.SQL.DBName](Azure.SQL.DBName.md) | Azure SQL Database names should meet naming requirements. | GA
AZR-000193 | [Azure.SQL.FGName](Azure.SQL.FGName.md) | Azure SQL failover group names should meet naming requirements. | GA
AZR-000194 | [Azure.SQLMI.Name](Azure.SQLMI.Name.md) | SQL Managed Instance names should meet naming requirements. | GA
AZR-000195 | [Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage Accounts using the LRS SKU are only replicated within a single zone. | GA
AZR-000196 | [Azure.Storage.SecureTransfer](Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | GA
AZR-000197 | [Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable blob soft delete on Storage Accounts. | GA
AZR-000198 | [Azure.Storage.BlobPublicAccess](Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | GA
AZR-000199 | [Azure.Storage.BlobAccessType](Azure.Storage.BlobAccessType.md) | Use containers configured with a private access type that requires authorization. | GA
AZR-000200 | [Azure.Storage.MinTLS](Azure.Storage.MinTLS.md) | Storage Accounts should reject TLS versions older than 1.2. | GA
AZR-000201 | [Azure.Storage.Name](Azure.Storage.Name.md) | Storage Account names should meet naming requirements. | GA
AZR-000202 | [Azure.Storage.Firewall](Azure.Storage.Firewall.md) | Storage Accounts should only accept explicitly allowed traffic. | GA
AZR-000203 | [Azure.RBAC.UseGroups](Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | GA
AZR-000204 | [Azure.RBAC.LimitOwner](Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | GA
AZR-000205 | [Azure.RBAC.LimitMGDelegation](Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | GA
AZR-000206 | [Azure.RBAC.CoAdministrator](Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | GA
AZR-000207 | [Azure.RBAC.UseRGDelegation](Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | GA
AZR-000208 | [Azure.RBAC.PIM](Azure.RBAC.PIM.md) | Use just-in-time (JiT) activation of roles instead of persistent role assignment. | GA
AZR-000209 | [Azure.Defender.SecurityContact](Azure.Defender.SecurityContact.md) | Important security notifications may be lost or not processed in a timely manner when a clear security contact is not identified. | GA
AZR-000210 | [Azure.DefenderCloud.Provisioning](Azure.DefenderCloud.Provisioning.md) | Enable auto-provisioning on to improve Microsoft Defender for Cloud insights. | GA
AZR-000211 | [Azure.Monitor.ServiceHealth](Azure.Monitor.ServiceHealth.md) | Configure Service Health alerts to notify administrators. | GA
AZR-000212 | [Azure.Template.TemplateFile](Azure.Template.TemplateFile.md) | Use ARM template files that are valid. | GA
AZR-000213 | [Azure.Template.TemplateSchema](Azure.Template.TemplateSchema.md) | Use a more recent version of the Azure template schema. | GA
AZR-000214 | [Azure.Template.TemplateScheme](Azure.Template.TemplateScheme.md) | Use an Azure template file schema with the https scheme. | GA
AZR-000215 | [Azure.Template.ParameterMetadata](Azure.Template.ParameterMetadata.md) | Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter. | GA
AZR-000216 | [Azure.Template.Resources](Azure.Template.Resources.md) | Each Azure Resource Manager (ARM) template file should deploy at least one resource. | GA
AZR-000217 | [Azure.Template.UseParameters](Azure.Template.UseParameters.md) | Each Azure Resource Manager (ARM) template parameter should be used or removed from template files. | deprecated
AZR-000218 | [Azure.Template.DefineParameters](Azure.Template.DefineParameters.md) | Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters. | deprecated
AZR-000219 | [Azure.Template.UseVariables](Azure.Template.UseVariables.md) | Each Azure Resource Manager (ARM) template variable should be used or removed from template files. | deprecated
AZR-000220 | [Azure.Template.LocationDefault](Azure.Template.LocationDefault.md) | Set the default value for the location parameter within an ARM template to resource group location. | GA
AZR-000221 | [Azure.Template.LocationType](Azure.Template.LocationType.md) | Location parameters should use a string value. | GA
AZR-000222 | [Azure.Template.ResourceLocation](Azure.Template.ResourceLocation.md) | Resource locations should be an expression or global. | GA
AZR-000223 | [Azure.Template.UseLocationParameter](Azure.Template.UseLocationParameter.md) | Template should reference a location parameter to specify resource location. | GA
AZR-000224 | [Azure.Template.ParameterMinMaxValue](Azure.Template.ParameterMinMaxValue.md) | Template parameters minValue and maxValue constraints must be valid. | GA
AZR-000225 | [Azure.Template.DebugDeployment](Azure.Template.DebugDeployment.md) | Use default deployment detail level for nested deployments. | GA
AZR-000226 | [Azure.Template.ParameterDataTypes](Azure.Template.ParameterDataTypes.md) | Set the parameter default value to a value of the same type. | GA
AZR-000227 | [Azure.Template.ParameterStrongType](Azure.Template.ParameterStrongType.md) | Set the parameter value to a value that matches the specified strong type. | GA
AZR-000228 | [Azure.Template.ExpressionLength](Azure.Template.ExpressionLength.md) | Template expressions should not exceed the maximum length. | GA
AZR-000229 | [Azure.Template.ParameterFile](Azure.Template.ParameterFile.md) | Use ARM template parameter files that are valid. | GA
AZR-000230 | [Azure.Template.ParameterScheme](Azure.Template.ParameterScheme.md) | Use an Azure template parameter file schema with the https scheme. | GA
AZR-000231 | [Azure.Template.MetadataLink](Azure.Template.MetadataLink.md) | Configure a metadata link for each parameter file. | GA
AZR-000232 | [Azure.Template.ParameterValue](Azure.Template.ParameterValue.md) | Specify a value for each parameter in template parameter files. | GA
AZR-000233 | [Azure.Template.ValidSecretRef](Azure.Template.ValidSecretRef.md) | Use a valid secret reference within parameter files. | deprecated
AZR-000234 | [Azure.Template.UseComments](Azure.Template.UseComments.md) | Use comments for each resource in ARM template to communicate purpose. | GA
AZR-000235 | [Azure.Template.UseDescriptions](Azure.Template.UseDescriptions.md) | Use descriptions for each resource in generated template(bicep, psarm, AzOps) to communicate purpose. | GA
AZR-000236 | [Azure.TrafficManager.Endpoints](Azure.TrafficManager.Endpoints.md) | Traffic Manager should use at lest two enabled endpoints. | GA
AZR-000237 | [Azure.TrafficManager.Protocol](Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | GA
AZR-000238 | [Azure.VM.UseManagedDisks](Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | GA
AZR-000239 | [Azure.VM.Standalone](Azure.VM.Standalone.md) | Use VM features to increase reliability and improve covered SLA for VM configurations. | GA
AZR-000240 | [Azure.VM.PromoSku](Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | GA
AZR-000241 | [Azure.VM.BasicSku](Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | GA
AZR-000242 | [Azure.VM.DiskCaching](Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | GA
AZR-000243 | [Azure.VM.UseHybridUseBenefit](Azure.VM.UseHybridUseBenefit.md) | Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads. | GA
AZR-000244 | [Azure.VM.AcceleratedNetworking](Azure.VM.AcceleratedNetworking.md) | Use accelerated networking for supported operating systems and VM types. | GA
AZR-000245 | [Azure.VM.PublicKey](Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | GA
AZR-000246 | [Azure.VM.Agent](Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | GA
AZR-000247 | [Azure.VM.Updates](Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | GA
AZR-000248 | [Azure.VM.Name](Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | GA
AZR-000249 | [Azure.VM.ComputerName](Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | GA
AZR-000250 | [Azure.VM.DiskAttached](Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines or removed. | GA
AZR-000251 | [Azure.VM.DiskSizeAlignment](Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing increments to improve cost efficiency. | GA
AZR-000252 | [Azure.VM.ADE](Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | GA
AZR-000253 | [Azure.VM.DiskName](Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | GA
AZR-000254 | [Azure.VM.ASAlignment](Azure.VM.ASAlignment.md) | Use availability sets aligned with managed disks fault domains. | GA
AZR-000255 | [Azure.VM.ASMinMembers](Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two virtual machines (VMs). | GA
AZR-000256 | [Azure.VM.ASName](Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | GA
AZR-000257 | [Azure.NIC.Attached](Azure.NIC.Attached.md) | Network interfaces (NICs) that are not used should be removed. | GA
AZR-000258 | [Azure.NIC.UniqueDns](Azure.NIC.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | GA
AZR-000259 | [Azure.NIC.Name](Azure.NIC.Name.md) | Network Interface (NIC) names should meet naming requirements. | GA
AZR-000260 | [Azure.VM.PPGName](Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | GA
AZR-000261 | [Azure.VMSS.Name](Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | GA
AZR-000262 | [Azure.VMSS.ComputerName](Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | GA
AZR-000263 | [Azure.VNET.UseNSGs](Azure.VNET.UseNSGs.md) | Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned. | GA
AZR-000264 | [Azure.VNET.SingleDNS](Azure.VNET.SingleDNS.md) | Virtual networks (VNETs) should have at least two DNS servers assigned. | GA
AZR-000265 | [Azure.VNET.LocalDNS](Azure.VNET.LocalDNS.md) | Virtual networks (VNETs) should use DNS servers deployed within the same Azure region. | GA
AZR-000266 | [Azure.VNET.PeerState](Azure.VNET.PeerState.md) | VNET peering connections must be connected. | GA
AZR-000267 | [Azure.VNET.SubnetName](Azure.VNET.SubnetName.md) | Subnet names should meet naming requirements. | GA
AZR-000268 | [Azure.VNET.Name](Azure.VNET.Name.md) | Virtual Network (VNET) names should meet naming requirements. | GA
AZR-000269 | [Azure.VNG.VPNLegacySKU](Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | GA
AZR-000270 | [Azure.VNG.VPNActiveActive](Azure.VNG.VPNActiveActive.md) | Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime. | GA
AZR-000271 | [Azure.VNG.ERLegacySKU](Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | GA
AZR-000272 | [Azure.VNG.VPNAvailabilityZoneSKU](Azure.VNG.VPNAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with VPN gateway type. | GA
AZR-000273 | [Azure.VNG.ERAvailabilityZoneSKU](Azure.VNG.ERAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type. | GA
AZR-000274 | [Azure.VNG.Name](Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | GA
AZR-000275 | [Azure.VNG.ConnectionName](Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | GA
AZR-000276 | [Azure.vWAN.Name](Azure.vWAN.Name.md) | Virtual WAN (vWAN) names should meet naming requirements. | GA
AZR-000277 | [Azure.WebPubSub.ManagedIdentity](Azure.WebPubSub.ManagedIdentity.md) | Configure Web PubSub Services to use managed identities to access Azure resources securely. | GA
AZR-000278 | [Azure.WebPubSub.SLA](Azure.WebPubSub.SLA.md) | Use SKUs that include an SLA when configuring Web PubSub Services. | GA
AZR-000279 | [Azure.Deployment.OutputSecretValue](Azure.Deployment.OutputSecretValue.md) | Outputting a sensitive value from deployment may leak secrets into deployment history or logs. | GA
AZR-000280 | [Azure.AI.PublicAccess](Azure.AI.PublicAccess.md) | Restrict access of Azure AI services to authorized virtual networks. | GA
AZR-000281 | [Azure.AI.ManagedIdentity](Azure.AI.ManagedIdentity.md) | Configure managed identities to access Azure resources. | GA
AZR-000282 | [Azure.AI.DisableLocalAuth](Azure.AI.DisableLocalAuth.md) | Access keys allow depersonalized access to Azure AI using a shared secret. | GA
AZR-000283 | [Azure.AI.PrivateEndpoints](Azure.AI.PrivateEndpoints.md) | Use Private Endpoints to access Azure AI services accounts. | GA
AZR-000284 | [Azure.Deployment.AdminUsername](Azure.Deployment.AdminUsername.md) | A sensitive property set from deterministic or hardcoded values is not secure. | GA
AZR-000285 | [Azure.AKS.UptimeSLA](Azure.AKS.UptimeSLA.md) | AKS clusters should have Uptime SLA enabled for a financially backed SLA. | GA
AZR-000286 | [Azure.CDN.UseFrontDoor](Azure.CDN.UseFrontDoor.md) | Use Azure Front Door Standard or Premium SKU to improve the performance of web pages with dynamic content and overall capabilities. | GA
AZR-000287 | [Azure.AKS.EphemeralOSDisk](Azure.AKS.EphemeralOSDisk.md) | AKS clusters should use ephemeral OS disks which can provide lower read/write latency, along with faster node scaling and cluster upgrades. | GA
AZR-000288 | [Azure.VMSS.PublicKey](Azure.VMSS.PublicKey.md) | Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities. | GA
AZR-000289 | [Azure.Storage.ContainerSoftDelete](Azure.Storage.ContainerSoftDelete.md) | Enable container soft delete on Storage Accounts. | GA
AZR-000290 | [Azure.Defender.Containers](Azure.Defender.Containers.md) | Enable Microsoft Defender for Containers. | GA
AZR-000291 | [Azure.AppConfig.DisableLocalAuth](Azure.AppConfig.DisableLocalAuth.md) | Access keys allow depersonalized access to App Configuration using a shared secret. | GA
AZR-000292 | [Azure.NSG.AKSRules](Azure.NSG.AKSRules.md) | AKS Network Security Group (NSG) should not have custom rules. | GA
AZR-000293 | [Azure.Defender.Servers](Azure.Defender.Servers.md) | Enable Microsoft Defender for Servers. | GA
AZR-000294 | [Azure.Defender.SQL](Azure.Defender.SQL.md) | Enable Microsoft Defender for SQL servers. | GA
AZR-000295 | [Azure.Defender.AppServices](Azure.Defender.AppServices.md) | Enable Microsoft Defender for App Service. | GA
AZR-000296 | [Azure.Defender.Storage](Azure.Defender.Storage.md) | Enable Microsoft Defender for Storage. | GA
AZR-000297 | [Azure.Defender.SQLOnVM](Azure.Defender.SQLOnVM.md) | Enable Microsoft Defender for SQL servers on machines. | GA
AZR-000298 | [Azure.Storage.FileShareSoftDelete](Azure.Storage.FileShareSoftDelete.md) | Enable soft delete on Storage Accounts file shares. | GA
AZR-000299 | [Azure.Redis.FirewallRuleCount](Azure.Redis.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules for the Redis cache. | GA
AZR-000300 | [Azure.Redis.FirewallIPRange](Azure.Redis.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses for the Redis cache. | GA
AZR-000301 | [Azure.RedisEnterprise.MinTLS](Azure.RedisEnterprise.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | GA
AZR-000302 | [Azure.AppGwWAF.PreventionMode](Azure.AppGwWAF.PreventionMode.md) | Use protection mode in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | GA
AZR-000303 | [Azure.AppGwWAF.Exclusions](Azure.AppGwWAF.Exclusions.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | GA
AZR-000304 | [Azure.AppGwWAF.RuleGroups](Azure.AppGwWAF.RuleGroups.md) | Use recommended rule groups in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | GA
AZR-000305 | [Azure.FrontDoorWAF.Enabled](Azure.FrontDoorWAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | GA
AZR-000306 | [Azure.FrontDoorWAF.PreventionMode](Azure.FrontDoorWAF.PreventionMode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | GA
AZR-000307 | [Azure.FrontDoorWAF.Exclusions](Azure.FrontDoorWAF.Exclusions.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. Avoid configuring rule exclusions. | GA
AZR-000308 | [Azure.FrontDoorWAF.RuleGroups](Azure.FrontDoorWAF.RuleGroups.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. | GA
AZR-000309 | [Azure.AppGwWAF.Enabled](Azure.AppGwWAF.Enabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | GA
AZR-000310 | [Azure.ACR.SoftDelete](Azure.ACR.SoftDelete.md) | Azure Container Registries should have soft delete policy enabled. | Preview
AZR-000311 | [Azure.AppConfig.AuditLogs](Azure.AppConfig.AuditLogs.md) | Ensure app configuration store audit diagnostic logs are enabled. | GA
AZR-000312 | [Azure.AppConfig.GeoReplica](Azure.AppConfig.GeoReplica.md) | Replicate app configuration store across all points of presence for an application. | GA
AZR-000313 | [Azure.AppConfig.PurgeProtect](Azure.AppConfig.PurgeProtect.md) | Consider purge protection for app configuration store to ensure store cannot be purged in the retention period. | GA
AZR-000314 | [Azure.VNET.BastionSubnet](Azure.VNET.BastionSubnet.md) | VNETs with a GatewaySubnet should have an AzureBastionSubnet to allow for out of band remote access to VMs. | GA
AZR-000315 | [Azure.ServiceBus.MinTLS](Azure.ServiceBus.MinTLS.md) | Service Bus namespaces should reject TLS versions older than 1.2. | GA
AZR-000316 | [Azure.Deployment.SecureValue](Azure.Deployment.SecureValue.md) | A secret property set from a non-secure value may leak the secret into deployment history or logs. | GA
AZR-000317 | [Azure.VM.MigrateAMA](Azure.VM.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | GA
AZR-000318 | [Azure.VMSS.MigrateAMA](Azure.VMSS.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | GA
AZR-000319 | [Azure.ASE.MigrateV3](Azure.ASE.MigrateV3.md) | Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2. | GA
AZR-000320 | [Azure.FrontDoor.UseCaching](Azure.FrontDoor.UseCaching.md) | Use caching to reduce retrieving contents from origins. | GA
AZR-000321 | [Azure.APIM.MinAPIVersion](Azure.APIM.MinAPIVersion.md) | API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer. | GA
AZR-000322 | [Azure.VNET.FirewallSubnet](Azure.VNET.FirewallSubnet.md) | Use Azure Firewall to filter network traffic to and from Azure resources. | GA
AZR-000323 | [Azure.MySQL.GeoRedundantBackup](Azure.MySQL.GeoRedundantBackup.md) | Azure Database for MySQL should store backups in a geo-redundant storage. | GA
AZR-000324 | [Azure.VM.SQLServerDisk](Azure.VM.SQLServerDisk.md) | Use Premium SSD disks or greater for data and log files for production SQL Server workloads. | GA
AZR-000325 | [Azure.MySQL.UseFlexible](Azure.MySQL.UseFlexible.md) | Use Azure Database for MySQL Flexible Server deployment model. | GA
AZR-000326 | [Azure.PostgreSQL.GeoRedundantBackup](Azure.PostgreSQL.GeoRedundantBackup.md) | Azure Database for PostgreSQL should store backups in a geo-redundant storage. | GA
AZR-000327 | [Azure.PostgreSQL.DefenderCloud](Azure.PostgreSQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL. | GA
AZR-000328 | [Azure.MySQL.DefenderCloud](Azure.MySQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MySQL. | GA
AZR-000329 | [Azure.MariaDB.GeoRedundantBackup](Azure.MariaDB.GeoRedundantBackup.md) | Azure Database for MariaDB should store backups in a geo-redundant storage. | GA
AZR-000330 | [Azure.MariaDB.DefenderCloud](Azure.MariaDB.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MariaDB. | GA
AZR-000331 | [Azure.Deployment.OuterSecret](Azure.Deployment.OuterSecret.md) | Outer evaluation deployments may leak secrets exposed as secure parameters into logs and nested deployments. | GA
AZR-000332 | [Azure.VM.ScriptExtensions](Azure.VM.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | GA
AZR-000333 | [Azure.VMSS.ScriptExtensions](Azure.VMSS.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | GA
AZR-000334 | [Azure.MariaDB.UseSSL](Azure.MariaDB.UseSSL.md) | Azure Database for MariaDB servers should only accept encrypted connections. | GA
AZR-000335 | [Azure.MariaDB.MinTLS](Azure.MariaDB.MinTLS.md) | Azure Database for MariaDB servers should reject TLS versions older than 1.2. | GA
AZR-000336 | [Azure.MariaDB.ServerName](Azure.MariaDB.ServerName.md) | Azure Database for MariaDB servers should meet naming requirements. | GA
AZR-000337 | [Azure.MariaDB.DatabaseName](Azure.MariaDB.DatabaseName.md) | Azure Database for MariaDB databases should meet naming requirements. | GA
AZR-000338 | [Azure.MariaDB.FirewallRuleName](Azure.MariaDB.FirewallRuleName.md) | Azure Database for MariaDB firewall rules should meet naming requirements. | GA
AZR-000339 | [Azure.MariaDB.VNETRuleName](Azure.MariaDB.VNETRuleName.md) | Azure Database for MariaDB VNET rules should meet naming requirements. | GA
AZR-000340 | [Azure.APIM.MultiRegion](Azure.APIM.MultiRegion.md) | Enhance service availability and resilience by deploying API Management instances across multiple regions. | GA
AZR-000341 | [Azure.APIM.MultiRegionGateway](Azure.APIM.MultiRegionGateway.md) | API Management instances should have multi-region deployment gateways enabled. | GA
AZR-000342 | [Azure.MariaDB.AllowAzureAccess](Azure.MariaDB.AllowAzureAccess.md) | Determine if access from Azure services is required. | GA
AZR-000343 | [Azure.MariaDB.FirewallRuleCount](Azure.MariaDB.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | GA
AZR-000344 | [Azure.MariaDB.FirewallIPRange](Azure.MariaDB.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | GA
AZR-000345 | [Azure.VM.AMA](Azure.VM.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VMs. | GA
AZR-000346 | [Azure.VMSS.AMA](Azure.VMSS.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VM scale sets. | GA
AZR-000347 | [Azure.Redis.Version](Azure.Redis.Version.md) | Azure Cache for Redis should use the latest supported version of Redis. | GA
AZR-000348 | [Azure.AppGw.Name](Azure.AppGw.Name.md) | Application Gateways should meet naming requirements. | GA
AZR-000349 | [Azure.Bastion.Name](Azure.Bastion.Name.md) | Bastion hosts should meet naming requirements. | GA
AZR-000350 | [Azure.RSV.Name](Azure.RSV.Name.md) | Recovery Services vaults should meet naming requirements. | GA
AZR-000351 | [Azure.VM.ShouldNotBeStopped](Azure.VM.ShouldNotBeStopped.md) | Azure VMs should be running or in a deallocated state. | GA
AZR-000352 | [Azure.Defender.KeyVault](Azure.Defender.KeyVault.md) | Enable Microsoft Defender for Key Vault. | GA
AZR-000353 | [Azure.Defender.Dns](Azure.Defender.Dns.md) | Enable Microsoft Defender for DNS. | GA
AZR-000354 | [Azure.Defender.Arm](Azure.Defender.Arm.md) | Enable Microsoft Defender for Azure Resource Manager (ARM). | GA
AZR-000355 | [Azure.KeyVault.Firewall](Azure.KeyVault.Firewall.md) | Key Vault should only accept explicitly allowed traffic. | GA
AZR-000356 | [Azure.EventHub.MinTLS](Azure.EventHub.MinTLS.md) | Event Hub namespaces should reject TLS versions older than 1.2. | GA
AZR-000357 | [Azure.IoTHub.MinTLS](Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | GA
AZR-000358 | [Azure.ServiceBus.AuditLogs](Azure.ServiceBus.AuditLogs.md) | Ensure namespaces audit diagnostic logs are enabled. | GA
AZR-000359 | [Azure.Deployment.Name](Azure.Deployment.Name.md) | Nested deployments should meet naming requirements of deployments. | GA
AZR-000360 | [Azure.ContainerApp.Name](Azure.ContainerApp.Name.md) | Container Apps should meet naming requirements. | GA
AZR-000361 | [Azure.ContainerApp.ManagedIdentity](Azure.ContainerApp.ManagedIdentity.md) | Ensure managed identity is used for authentication. | GA
AZR-000362 | [Azure.ContainerApp.ExternalIngress](Azure.ContainerApp.ExternalIngress.md) | Limit inbound communication for Container Apps is limited to callers within the Container Apps Environment. | GA
AZR-000363 | [Azure.ContainerApp.PublicAccess](Azure.ContainerApp.PublicAccess.md) | Ensure public network access for Container Apps environment is disabled. | GA
AZR-000364 | [Azure.ContainerApp.Storage](Azure.ContainerApp.Storage.md) | Use of Azure Files volume mounts to persistent storage container data. | GA
AZR-000365 | [Azure.APIM.CORSPolicy](Azure.APIM.CORSPolicy.md) | Avoid using wildcard for any configuration option in CORS policies. | GA
AZR-000366 | [Azure.SQLMI.AADOnly](Azure.SQLMI.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance. | GA
AZR-000367 | [Azure.SQLMI.ManagedIdentity](Azure.SQLMI.ManagedIdentity.md) | Ensure managed identity is used to allow support for Azure AD authentication. | GA
AZR-000368 | [Azure.SQLMI.AAD](Azure.SQLMI.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance. | GA
AZR-000369 | [Azure.SQL.AADOnly](Azure.SQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure SQL Database. | GA
AZR-000370 | [Azure.AKS.DefenderProfile](Azure.AKS.DefenderProfile.md) | Enable the Defender profile with Azure Kubernetes Service (AKS) cluster. | GA
AZR-000371 | [Azure.APIM.PolicyBase](Azure.APIM.PolicyBase.md) | Base element for any policy element in a section should be configured. | GA
AZR-000372 | [Azure.Defender.Cspm](Azure.Defender.Cspm.md) | Enable Microsoft Defender Cloud Security Posture Management Standard plan. | GA
AZR-000373 | [Azure.Arc.Kubernetes.Defender](Azure.Arc.Kubernetes.Defender.md) | Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters. | Preview
AZR-000374 | [Azure.Arc.Server.MaintenanceConfig](Azure.Arc.Server.MaintenanceConfig.md) | Use a maintenance configuration for Arc-enabled servers. | Preview
AZR-000375 | [Azure.VM.MaintenanceConfig](Azure.VM.MaintenanceConfig.md) | Use a maintenance configuration for virtual machines. | GA
AZR-000376 | [Azure.AppGw.MigrateV2](Azure.AppGw.MigrateV2.md) | Use a Application Gateway v2 SKU. | GA
AZR-000377 | [Azure.Defender.Api](Azure.Defender.Api.md) | Enable Microsoft Defender for APIs. | GA
AZR-000378 | [Azure.ContainerApp.DisableAffinity](Azure.ContainerApp.DisableAffinity.md) | Disable session affinity to prevent unbalanced distribution. | GA
AZR-000379 | [Azure.Defender.CosmosDb](Azure.Defender.CosmosDb.md) | Enable Microsoft Defender for Azure Cosmos DB. | GA
AZR-000380 | [Azure.ContainerApp.RestrictIngress](Azure.ContainerApp.RestrictIngress.md) | IP ingress restrictions mode should be set to allow action for all rules defined. | GA
AZR-000381 | [Azure.Defender.OssRdb](Azure.Defender.OssRdb.md) | Enable Microsoft Defender for open-source relational databases. | GA
AZR-000382 | [Azure.Cosmos.DefenderCloud](Azure.Cosmos.DefenderCloud.md) | Enable Microsoft Defender for Azure Cosmos DB. | GA
AZR-000383 | [Azure.Defender.Storage.MalwareScan](Azure.Defender.Storage.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | GA
AZR-000384 | [Azure.Storage.Defender.MalwareScan](Azure.Storage.Defender.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | GA
AZR-000385 | [Azure.Defender.Storage.DataScan](Azure.Defender.Storage.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Preview
AZR-000386 | [Azure.Storage.DefenderCloud](Azure.Storage.DefenderCloud.md) | Enable Microsoft Defender for Storage for storage accounts. | GA
AZR-000387 | [Azure.APIM.DefenderCloud](Azure.APIM.DefenderCloud.md) | APIs published in Azure API Management should be onboarded to Microsoft Defender for APIs. | GA
AZR-000388 | [Azure.KeyVault.RBAC](Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | GA
AZR-000389 | [Azure.PostgreSQL.AAD](Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | GA
AZR-000390 | [Azure.PostgreSQL.AADOnly](Azure.PostgreSQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for PostgreSQL databases. | GA
AZR-000391 | [Azure.Storage.Defender.DataScan](Azure.Storage.Defender.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Preview
AZR-000392 | [Azure.MySQL.AAD](Azure.MySQL.AAD.md) | Use Entra ID authentication with Azure Database for MySQL databases. | GA
AZR-000393 | [Azure.Databricks.SecureConnectivity](Azure.Databricks.SecureConnectivity.md) | Use Databricks workspaces configured for secure cluster connectivity. | GA
AZR-000394 | [Azure.MySQL.AADOnly](Azure.MySQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases. | GA
AZR-000395 | [Azure.PublicIP.MigrateStandard](Azure.PublicIP.MigrateStandard.md) | Use the Standard SKU for Public IP addresses as the Basic SKU will be retired. | GA
AZR-000396 | [Azure.FrontDoor.ManagedIdentity](Azure.FrontDoor.ManagedIdentity.md) | Ensure Front Door uses a managed identity to authorize access to Azure resources. | GA
AZR-000397 | [Azure.RSV.Immutable](Azure.RSV.Immutable.md) | Ensure immutability is configured to protect backup data. | GA
AZR-000398 | [Azure.BV.Immutable](Azure.BV.Immutable.md) | Ensure immutability is configured to protect backup data. | GA
AZR-000399 | [Azure.Firewall.PolicyMode](Azure.Firewall.PolicyMode.md) | Deny high confidence malicious IP addresses, domains and URLs. | GA
AZR-000400 | [Azure.ContainerApp.APIVersion](Azure.ContainerApp.APIVersion.md) | Migrate from retired API version to a supported version. | GA
AZR-000401 | [Azure.ACR.AnonymousAccess](Azure.ACR.AnonymousAccess.md) | Anonymous pull access allows unidentified downloading of images and metadata from a container registry. | Preview
AZR-000402 | [Azure.ACR.Firewall](Azure.ACR.Firewall.md) | Container Registry without restrictions can be accessed from any network location including the Internet. | GA
AZR-000403 | [Azure.ML.ComputeIdleShutdown](Azure.ML.ComputeIdleShutdown.md) | Configure an idle shutdown timeout for Machine Learning compute instances. | GA
AZR-000404 | [Azure.ML.DisableLocalAuth](Azure.ML.DisableLocalAuth.md) | Azure Machine Learning compute resources should have local authentication methods disabled. | GA
AZR-000405 | [Azure.ML.ComputeVnet](Azure.ML.ComputeVnet.md) | Azure Machine Learning Computes should be hosted in a virtual network (VNet). | GA
AZR-000406 | [Azure.ML.PublicAccess](Azure.ML.PublicAccess.md) | Disable public network access from a Azure Machine Learning workspace. | GA
AZR-000407 | [Azure.ML.UserManagedIdentity](Azure.ML.UserManagedIdentity.md) | ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity. | GA
AZR-000408 | [Azure.Deployment.SecureParameter](Azure.Deployment.SecureParameter.md) | Sensitive parameters that have been not been marked as secure may leak the secret into deployment history or logs. | GA
AZR-000409 | [Azure.Databricks.SKU](Azure.Databricks.SKU.md) | Ensure Databricks workspaces are non-trial SKUs for production workloads. | GA
AZR-000410 | [Azure.Databricks.PublicAccess](Azure.Databricks.PublicAccess.md) | Azure Databricks workspaces should disable public network access. | GA
AZR-000411 | [Azure.DevBox.ProjectLimit](Azure.DevBox.ProjectLimit.md) | Limit the number of Dev Boxes a single user can create for a project. | GA
AZR-000412 | [Azure.AKS.MinUserPoolNodes](Azure.AKS.MinUserPoolNodes.md) | User node pools in an AKS cluster should have a minimum number of nodes for failover and updates. | GA
AZR-000413 | [Azure.ContainerApp.MinReplicas](Azure.ContainerApp.MinReplicas.md) | Use multiple replicas to remove a single point of failure. | GA
AZR-000414 | [Azure.ContainerApp.AvailabilityZone](Azure.ContainerApp.AvailabilityZone.md) | Use Container Apps environments that are zone redundant to improve reliability. | GA
AZR-000415 | [Azure.Cosmos.MinTLS](Azure.Cosmos.MinTLS.md) | Cosmos DB accounts should reject TLS versions older than 1.2. | GA
AZR-000416 | [Azure.EntraDS.NTLM](Azure.EntraDS.NTLM.md) | Disable NTLM v1 for Microsoft Entra Domain Services. | GA
AZR-000417 | [Azure.EntraDS.TLS](Azure.EntraDS.TLS.md) | Disable TLS v1 for Microsoft Entra Domain Services. | GA
AZR-000418 | [Azure.EntraDS.RC4](Azure.EntraDS.RC4.md) | Disable RC4 encryption for Microsoft Entra Domain Services. | GA
AZR-000419 | [Azure.Cosmos.SLA](Azure.Cosmos.SLA.md) | Use a paid tier to qualify for a Service Level Agreement (SLA). | GA
AZR-000420 | [Azure.Cosmos.DisableLocalAuth](Azure.Cosmos.DisableLocalAuth.md) | Access keys allow depersonalized access to Cosmos DB accounts using a shared secret. | GA
AZR-000421 | [Azure.Cosmos.PublicAccess](Azure.Cosmos.PublicAccess.md) | Azure Cosmos DB should have public network access disabled. | GA
AZR-000422 | [Azure.EventHub.Firewall](Azure.EventHub.Firewall.md) | Access to the namespace endpoints should be restricted to only allowed sources. | GA
AZR-000423 | [Azure.AppGw.MigrateWAFPolicy](Azure.AppGw.MigrateWAFPolicy.md) | Migrate to Application Gateway WAF policy. | GA
AZR-000424 | [Azure.Grafana.Version](Azure.Grafana.Version.md) | Grafana workspaces should be on Grafana version 10. | GA
AZR-000425 | [Azure.LogAnalytics.Replication](Azure.LogAnalytics.Replication.md) | Log Analytics workspaces should have workspace replication enabled to improve service availability. | Preview
AZR-000426 | [Azure.VMSS.AutoInstanceRepairs](Azure.VMSS.AutoInstanceRepairs.md) | Automatic instance repairs are enabled. | Preview
AZR-000427 | [Azure.Redis.EntraID](Azure.Redis.EntraID.md) | Use Entra ID authentication with cache instances. | GA
AZR-000428 | [Azure.AppService.NodeJsVersion](Azure.AppService.NodeJsVersion.md) | Configure applications to use supported Node.js runtime versions. | GA
AZR-000429 | [Azure.Firewall.AvailabilityZone](Azure.Firewall.AvailabilityZone.md) | Deploy firewall instances using availability zones in supported regions to ensure high availability and resilience. | GA
AZR-000430 | [Azure.VNG.MaintenanceConfig](Azure.VNG.MaintenanceConfig.md) | Use a customer-controlled maintenance configuration for virtual network gateways. | Preview
AZR-000431 | [Azure.MySQL.MaintenanceWindow](Azure.MySQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure Database for MySQL servers. | GA
AZR-000432 | [Azure.MySQL.ZoneRedundantHA](Azure.MySQL.ZoneRedundantHA.md) | Deploy Azure Database for MySQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience. | GA
AZR-000433 | [Azure.PostgreSQL.MaintenanceWindow](Azure.PostgreSQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure Database for PostgreSQL servers. | GA
AZR-000434 | [Azure.PostgreSQL.ZoneRedundantHA](Azure.PostgreSQL.ZoneRedundantHA.md) | Deploy Azure Database for PostgreSQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience. | GA
AZR-000435 | [Azure.AKS.NodeAutoUpgrade](Azure.AKS.NodeAutoUpgrade.md) | Deploy AKS Clusters with Node Auto-Upgrade enabled | GA
AZR-000436 | [Azure.VMSS.AvailabilityZone](Azure.VMSS.AvailabilityZone.md) | Deploy virtual machine scale set instances using availability zones in supported regions to ensure high availability and resilience. | GA
AZR-000437 | [Azure.AVD.ScheduleAgentUpdate](Azure.AVD.ScheduleAgentUpdate.md) | Define a windows for agent updates to minimize disruptions to users. | GA
AZR-000438 | [Azure.VMSS.ZoneBalance](Azure.VMSS.ZoneBalance.md) | Deploy virtual machine scale set instances using the best-effort zone balance in supported regions. | GA
AZR-000439 | [Azure.Cosmos.ContinuousBackup](Azure.Cosmos.ContinuousBackup.md) | Enable continuous backup on Cosmos DB accounts. | GA
AZR-000440 | [Azure.SQL.MaintenanceWindow](Azure.SQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure SQL databases. | GA
AZR-000441 | [Azure.SQLMI.MaintenanceWindow](Azure.SQLMI.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure SQL Managed Instances. | GA
AZR-000442 | [Azure.AppService.AvailabilityZone](Azure.AppService.AvailabilityZone.md) | Deploy app service plan instances using availability zones in supported regions to ensure high availability and resilience. | GA
AZR-000443 | [Azure.ASE.AvailabilityZone](Azure.ASE.AvailabilityZone.md) | Deploy app service environments using availability zones in supported regions to ensure high availability and resilience. | GA
AZR-000444 | [Azure.ServiceBus.GeoReplica](Azure.ServiceBus.GeoReplica.md) | Enhance resilience to regional outages by replicating namespaces. | Preview
AZR-000445 | [Azure.AKS.AuditAdmin](Azure.AKS.AuditAdmin.md) | Use kube-audit-admin instead of kube-audit to capture administrative actions in AKS clusters. | GA
AZR-000446 | [Azure.AKS.MaintenanceWindow](Azure.AKS.MaintenanceWindow.md) | Configure customer-controlled maintenance windows for AKS clusters. | GA
AZR-000447 | [Azure.VNET.PrivateSubnet](Azure.VNET.PrivateSubnet.md) | Disable default outbound access for virtual machines. | Preview
AZR-000448 | [Azure.VNET.FirewallSubnetNAT](Azure.VNET.FirewallSubnetNAT.md) | Zonal-deployed Azure Firewalls should consider using an Azure NAT Gateway for outbound access. | GA
AZR-000449 | [Azure.VM.PublicIPAttached](Azure.VM.PublicIPAttached.md) | Avoid attaching public IPs directly to virtual machines. | GA
AZR-000450 | [Azure.VMSS.PublicIPAttached](Azure.VMSS.PublicIPAttached.md) | Avoid attaching public IPs directly to virtual machine scale set instances. | GA
AZR-000451 | [Azure.VM.ASDistributeTraffic](Azure.VM.ASDistributeTraffic.md) | Ensure high availability by distributing traffic among members in an availability set. | GA
AZR-000452 | [Azure.VM.MultiTenantHosting](Azure.VM.MultiTenantHosting.md) | Deploy Windows 10 and 11 virtual machines in Azure using Multi-tenant Hosting Rights to leverage your existing Windows licenses. | GA

*[GA]: Generally Available &mdash; Rules related to a generally available Azure features.
