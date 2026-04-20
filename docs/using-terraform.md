---
author: @polatengin
---

# Using Terraform

PSRule for Azure supports analyzing Azure resources defined in Terraform configurations by expanding Terraform plan JSON files.

This enables pre-flight validation of Terraform-managed Azure resources against Azure Well-Architected Framework (WAF) rules.

## Overview

Terraform plan expansion parses the output of `terraform show -json` and converts Azure resources from the [AzAPI provider][1] into ARM-format representations.
These are then evaluated by the same PSRule rules used for ARM templates and Bicep files.

  [1]: https://registry.terraform.io/providers/Azure/azapi/latest/docs

## Supported providers

Currently, the following Terraform providers are supported:

| Provider | Support |
|----------|---------|
| **AzAPI** (`azure/azapi`) | `azapi_resource` and `azapi_update_resource` are converted to ARM format. |
| **AzureRM** (`hashicorp/azurerm`) | Not yet supported. Planned for a future release. |

The AzAPI provider is a thin wrapper over the Azure ARM REST API, meaning its `body` property is already in ARM-compatible format.
This makes it the highest-fidelity provider for PSRule analysis.

## Getting started

### Step 1: Generate a Terraform plan

In your CI pipeline, generate a plan and export it as JSON:

```bash
terraform init
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

### Step 2: Enable Terraform plan expansion

Add the following to your `ps-rule.yaml` configuration:

```yaml
configuration:
  AZURE_TERRAFORM_PLAN_EXPANSION: true
```

### Step 3: Run PSRule

Analyze the plan JSON file with PSRule:

```bash
Assert-PSRule -InputPath './tfplan.json' -Module PSRule.Rules.Azure
```

Or using the CLI:

```bash
ps-rule run -InputPath './tfplan.json' --module PSRule.Rules.Azure
```

## How it works

When `AZURE_TERRAFORM_PLAN_EXPANSION` is enabled and a JSON file matching the Terraform plan schema is detected, PSRule:

1. Parses the `planned_values` section of the plan JSON.
2. Walks the module tree (including nested `child_modules`).
3. For each `azapi_resource` or `azapi_update_resource` with `mode: "managed"`, converts it to ARM format.
4. Imports the converted resources into PSRule for rule evaluation.

### Resource conversion

The converter performs the following mappings from AzAPI to ARM format:

| AzAPI property | ARM property | Notes |
|---|---|---|
| `type` (e.g., `Microsoft.Storage/storageAccounts@2023-01-01`) | `type` + `apiVersion` | Split at `@` |
| `name` | `name` | Direct |
| `location` | `location` | Direct; omitted if null |
| `parent_id` + `type` + `name` | `id` | Constructed resource ID |
| `body.*` | Merged to resource root | `properties`, `sku`, etc. |
| `tags` | `tags` | Top-level takes precedence over `body.tags` |
| `identity.type` | `identity.type` | Direct |
| `identity.identity_ids` | `identity.userAssignedIdentities` | Array converted to object |

### Excluded resource types

The following are excluded from conversion:

- **Data sources** (`mode: "data"`) &mdash; Read-only lookups, not deployable resources.
- **`azapi_resource_action`** &mdash; Invokes POST actions, not a resource definition.
- **`azapi_data_plane_resource`** &mdash; Data plane operations don't map to ARM resources.
- **Non-Azure providers** &mdash; Resources from `hashicorp/random`, `hashicorp/null`, etc. are skipped.

## Limitations

The following limitations apply to Terraform plan expansion:

- Only `azapi_resource` and `azapi_update_resource` types are supported. The `azurerm` provider is not yet supported.
- Raw `.tf` files cannot be analyzed directly. You must first generate a plan JSON file.
- **Unknown-at-plan-time values** &mdash; Properties that Terraform cannot resolve until after `apply` (e.g., resource IDs, FQDNs) will be absent from analysis.
- **Ephemeral values** &mdash; Terraform 1.10+ ephemeral values are redacted from plan JSON and will not be available.
- **Sensitive values** &mdash; Values marked as sensitive in Terraform are redacted in the plan JSON.
- **No runtime property projection** &mdash; Unlike Bicep expansion, runtime-only properties (e.g., `principalId`) are not projected.
- **`azapi_update_resource`** only contains the properties being updated, not the full resource definition.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `AZURE_TERRAFORM_PLAN_EXPANSION` | `bool` | `false` | Enable expansion from Terraform plan JSON files. |
