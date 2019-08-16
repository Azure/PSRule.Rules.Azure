---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.PostgreSQL.AllowAzureAccess.md
ms-content-id: 07659a25-0a40-4979-99cd-cae83a5e3145
---

# Azure.PostgreSQL.AllowAzureAccess

## SYNOPSIS

Determine if access from Azure services is required.

## DESCRIPTION

Allow access to Azure services, permits any Azure service including other Azure customers, network based access to databases on the same PostgreSQL server instance.

If network based access is permitted, authentication is still required.

Enabling access from Azure Services is useful in certain cases for on demand PaaS workloads where configuring a stable IP address is not possible. For example Azure Functions, Container Instances and Logic Apps.

## RECOMMENDATION

Where a stable IP addresses are able to be configured, configure IP or virtual network based firewall rules instead of using Allow access to Azure services.

Determine if access from Azure services is required for the services connecting to the hosted databases.
