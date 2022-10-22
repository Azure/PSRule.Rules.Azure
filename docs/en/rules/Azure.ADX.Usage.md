---
reviewed: 2022/01/22
severity: Important
pillar: Cost Optimization
category: Reports
resource: Data Explorer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ADX.Usage/
---

# Remove unused Data Explorer clusters

## SYNOPSIS

Regularly remove unused resources to reduce costs.

## DESCRIPTION

Billing starts for an Azure Data Explorer (ADX) cluster after it is provisioned.
To store data in an ADX cluster, you must first create a database.
Clusters without any databases are considered unused.

Additionally, ADX clusters can stopped.
Stopping an ADX cluster deallocates and removes compute resources.
While in the stopped state, compute charges are not incurred.
Any data stored in the cluster is persisted while the cluster is stopped.

## RECOMMENDATION

Consider removing Data Explorer clusters that are not used.

## NOTES

This rule applies when analyzing ADX clusters deployed (in-flight) and running within Azure.
If the cluster is stopped, this rule is ignored.

## LINKS

- [Generate cost reports](https://learn.microsoft.com/azure/architecture/framework/cost/monitor-reports)
- [Pricing](https://azure.microsoft.com/pricing/details/data-explorer/)
- [Stop and restart the cluster](https://docs.microsoft.com/azure/data-explorer/create-cluster-database-portal#stop-and-restart-the-cluster)
- [Automatic stop of inactive Azure Data Explorer clusters](https://docs.microsoft.com/azure/data-explorer/auto-stop-clusters)
