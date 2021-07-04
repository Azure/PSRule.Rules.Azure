---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.AllowAzureAccess/
ms-content-id: 07659a25-0a40-4979-99cd-cae83a5e3145
---

# Disable PostgreSQL Allow Azure access firewall rule

## SYNOPSIS

Determine if access from Azure services is required.

## DESCRIPTION

Allow access to Azure services, permits any Azure service including other Azure customers, network based-access to databases on the same PostgreSQL server instance.
If network based access is permitted, authentication is still required.

Enabling access from Azure Services is useful in certain cases for serverless PaaS workloads where configuring a stable IP address is not possible.
For example Azure Functions, Container Instances and Logic Apps.

## RECOMMENDATION

Where a stable IP addresses are able to be configured, configure IP or virtual network based firewall rules instead of using Allow access to Azure services.

Determine if access from Azure services is required for the services connecting to the hosted databases.

## LINKS

- [Firewall rules in Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/concepts-firewall-rules#connecting-from-azure)
