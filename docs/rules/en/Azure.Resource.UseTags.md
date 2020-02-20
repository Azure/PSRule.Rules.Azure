---
severity: Awareness
category: Operations management
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.Resource.UseTags.md
ms-content-id: d8480c0d-e41c-441a-9b03-0dc9c340c149
---

# Use resource tags

## SYNOPSIS

Azure resources should be tagged using a standard convention.

## DESCRIPTION

Azure Resource Manager (ARM) supports a flexible tagging model that allows each resource to be tagged.
Tags are additional metadata that improves identification of resources and aids lifecycle management.

Azure stores tags as name/ value pairs such as `environment = production` or `costCode = 349921`.

A well defined tagging approach improves the management, billing and automation operations of resources.
When planning tags, identify information that is meaningful to business and technical staff.

## RECOMMENDATION

Consider tagging resources using a standard convention.
Identify mandatory and optional tags then tag all resources using this standard.

## LINKS

- [Tag support for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support)
- [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#metadata-tags)
