---
reviewed: 2025-10-10
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Cosmos DB for MongoDB account
resourceType: Microsoft.DocumentDb/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.MongoNaming/
---

# Cosmos DB for MongoDB account resources must use standard naming

## SYNOPSIS

Cosmos DB for MongoDB account resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For Cosmos DB for MongoDB account, the Cloud Adoption Framework (CAF) recommends using the `cosmon-` prefix.

Requirements for Cosmos DB for MongoDB account resource names:

- Between 3 and 44 characters long.
- Can include alphanumeric characters, hyphens, underscores, and periods (restrictions vary by resource type).
- Resource names must be unique within their scope.

## RECOMMENDATION

Consider creating Cosmos DB for MongoDB account resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(3)
@maxLength(44)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// Example resource deployment
```

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

## NOTES

This rule does not check if Cosmos DB for MongoDB account resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_COSMOS_MONGO_NAME_FORMAT -->

To configure this rule set the `AZURE_COSMOS_MONGO_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_COSMOS_MONGO_NAME_FORMAT: '^cosmon-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence maturity model](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
