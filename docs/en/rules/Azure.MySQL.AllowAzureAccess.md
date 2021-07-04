---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.AllowAzureAccess/
ms-content-id: 8a159312-1dcd-4c64-91a8-4dd17f97efdb
---

# Disable MySQL Allow Azure access firewall rule

## SYNOPSIS

Determine if access from Azure services is required.

## DESCRIPTION

Allow access to Azure services, permits any Azure service including other Azure customers, network based-access to databases on the same MySQL server instance.
If network based access is permitted, authentication is still required.

Enabling access from Azure Services is useful in certain cases for serverless PaaS workloads where configuring a stable IP address is not possible.
For example Azure Functions, Container Instances and Logic Apps.

## RECOMMENDATION

Where a stable IP addresses are able to be configured, configure IP or virtual network based firewall rules instead of using Allow access to Azure services.

Determine if access from Azure services is required for the services connecting to the hosted databases.

## LINKS

- [Azure Database for MySQL server firewall rules](https://docs.microsoft.com/azure/mysql/concepts-firewall-rules#connecting-from-azure)
