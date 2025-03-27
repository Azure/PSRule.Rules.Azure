---
reviewed: 2025-03-27
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: SQL Database
resourceType: Microsoft.Sql/servers/databases,Microsoft.Sql/servers/sqlVulnerabilityAssessments,Microsoft.Sql/servers/vulnerabilityAssessments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.VAScan/
---

# Logical SQL Servers are not scanned for vulnerabilities

## SYNOPSIS

SQL Databases may have configuration vulnerabilities discovered after they are deployed.

## DESCRIPTION

Azure SQL Database supports vulnerability assessment scanning to identify potential security vulnerabilities in your database.
When enabled through Microsoft Defender for Cloud, Defender for Databases periodically performs a scan of your database.
The result of the scan can help you identify potential security vulnerabilities in your database configuration or your application.

Vulnerability assessment settings can be configured using Express or Classic configurations.
The Express configuration is the portal default,
and simplifies the configuration process because it does not require you to specify a storage account.

## RECOMMENDATION

Consider enabling vulnerability assessment scanning for logical SQL Servers.

## EXAMPLES

### Configure with Bicep

To deploy logical SQL Servers that pass this rule:

- Create a `Microsoft.Sql/servers/sqlVulnerabilityAssessments` sub-resource.
- On the sub-resource:
  - Set the `properties.state` property to `Enabled`.

For example:

```bicep
resource vulnerabilityAssessment 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2024-05-01-preview' = {
  parent: server
  name: 'default'
  properties: {
    state: 'Enabled'
  }
}
```

### Configure with Azure template

To deploy resource that pass this rule:

- Create a `Microsoft.Sql/servers/sqlVulnerabilityAssessments` sub-resource.
- On the sub-resource:
  - Set the `properties.state` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.Sql/servers/sqlVulnerabilityAssessments",
  "apiVersion": "2024-05-01-preview",
  "name": "[format('{0}/{1}', parameters('name'), 'default')]",
  "properties": {
    "state": "Enabled"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/servers', parameters('name'))]"
  ]
}
```

## NOTES

If either the Express or Classic configuration is enabled, this rule will pass.
The Classic configuration option is enabled by deploying the `Microsoft.Sql/servers/vulnerabilityAssessments` sub-resource.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [SQL vulnerability assessment helps you identify database vulnerabilities](https://learn.microsoft.com/azure/defender-for-cloud/sql-azure-vulnerability-assessment-overview)
- [What's the difference between the express and classic configuration?](https://learn.microsoft.com/azure/defender-for-cloud/sql-azure-vulnerability-assessment-overview#whats-the-difference-between-the-express-and-classic-configuration)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers)
