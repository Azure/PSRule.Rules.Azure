---
severity: Awareness
pillar: Cost Optimization
category: CO:13 Personnel time
resource: Network Security Group
resourceType: Microsoft.Network/networkSecurityGroups
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.Associated/
---

# Associate NSGs or clean them up

## SYNOPSIS

Network Security Groups (NSGs) should be associated to a subnet or network interface.

## DESCRIPTION

NSGs are basic stateful firewalls that are deployed as separate resources within your subscriptions.
Each NSG can be associated to one or more network interfaces or subnets.
NSGs that are not associated with a network interface or subnet perform no purpose and add to administration overhead.

## RECOMMENDATION

Consider cleaning up NSGs that are not required to reduce technical debt.
Also consider using Resource Groups to help manage the lifecycle of related resources together.
Apply tags to all resources to help identify resources that are attached to specific workloads.

## EXAMPLES

### Configure with Azure CLI

To find orphaned NSG's run the following Azure CLI command:

```bash
az network nsg list -g $rgName --query "[?(subnets==null) && (networkInterfaces==null)].id" -o tsv
```

## LINKS

- [CO:13 Personnel time](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-personnel-time)
- [Orphaned Resources Workbook](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/azure-orphan-resources/ba-p/3492198)
- [Modify, create and delete NSG's using the CLI](https://learn.microsoft.com/cli/azure/network/nsg?view=azure-cli-latest#az-network-nsg-delete)
- [Network security groups](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups)
