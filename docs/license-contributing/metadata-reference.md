# Metadata reference

PSRule for Azure uses several metadata tags, labels, and annotations that are specific to the framework and Azure resources.
This document provides a comprehensive reference for all metadata used across rules, baselines, and documentation.

## Rule metadata

Rules in PSRule for Azure use metadata to categorize, classify, and provide additional context.
This metadata is used by baselines to include rules and by the documentation system to generate reference materials.

### Tags

Tags are used to categorize rules and are specified in the PowerShell or YAML rule definition.

#### `release`

Indicates the release status of the Azure feature that the rule validates, with one of the following values:

- `GA` &mdash; Generally Available features that are fully supported and recommended for production use.
- `preview` &mdash; Preview features that may have limitations or different terms of service.
- `deprecated` &mdash; Rules for features that are no longer recommended or are being phased out.

For example:

```powershell
-Tag @{ release = 'GA'; }
```

```yaml
tag:
  release: GA
```

#### `ruleSet`

Indicates the quarterly release when the rule was introduced or last significantly updated.
Used by quarterly baselines to provide stable checkpoints.

A valid rule set used the format `yyyy_mm` where `yyyy` is the year and `mm` is the month (`03`, `06`, `09`, `12`).

For example:

```powershell
-Tag @{ ruleSet = '2025_06'; }
```

```yaml
tag:
  ruleSet: 2025_06
```

#### `Azure.WAF/pillar`

Aligns the rule with the Microsoft Azure Well-Architected Framework (WAF) pillars.
The following are valid pillars accepted by this tag:

- `Security` &mdash; Rules that enhance the security posture of Azure resources.
- `Reliability` &mdash; Rules that improve system reliability and resilience.
- `Performance Efficiency` &mdash; Rules that optimize performance and efficiency.
- `Cost Optimization` &mdash; Rules that help optimize costs.
- `Operational Excellence` &mdash; Rules that improve operational practices.

**Example:**

```powershell
-Tag @{ 'Azure.WAF/pillar' = 'Security'; }
```

```yaml
tag:
  Azure.WAF/pillar: Security
```

### Labels

Labels provide additional classification and mapping to frameworks.

#### `Azure.MCSB.v1/control`

Maps the rule to Microsoft Cloud Security Benchmark (MCSB) version 1 controls.

For example, for a single control:

```powershell
-Labels @{ 'Azure.MCSB.v1/control' = 'DP-4' }
```

```yaml
labels:
  Azure.MCSB.v1/control: DP-4
```

For example, multiple controls:

```powershell
-Labels @{ 'Azure.MCSB.v1/control' = @('DP-2', 'LT-1') }
```

```yaml
labels:
  Azure.MCSB.v1/control:
    - DP-2
    - LT-1
```

#### `Azure.CAF`

Maps the rule to Cloud Adoption Framework (CAF) categories.
Valid values include:

- `naming` &mdash; Rules related to resource naming conventions.
- `tagging` &mdash; Rules related to resource tagging standards.

For example:

```powershell
-Labels @{ 'Azure.CAF' = 'naming' }
```

```yaml
labels:
  Azure.CAF: naming
```

#### `Azure.WAF/maturity`

Indicates the maturity level for Well-Architected Framework implementation.
Valid values include:

- `L1` &mdash; Level 1 maturity requirements.
- `L2` &mdash; Level 2 maturity requirements.
- `L3` &mdash; Level 3 maturity requirements.
- `L4` &mdash; Level 4 maturity requirements.
- `L5` &mdash; Level 5 maturity requirements.

For example:

```powershell
-Labels @{ 'Azure.WAF/maturity' = 'L1'; }
```

```yaml
labels:
  Azure.WAF/maturity: L1
```

For more information about the WAF security maturity model, see [Security maturity model](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level1).

## Documentation metadata

Rule documentation uses front matter metadata to provide structured information about each rule.
This metadata is used to generate documentation and provide context to users.

### `severity`

Indicates the subjective impact rating of the rule on the solution or platform.

Valid values include:

- `Critical` &mdash; A 'must have' if the solution is to be considered 'fit for purpose', secure, well governed and managed inline with the Microsoft Azure Well-Architected Framework.
- `Important` &mdash; A 'to be considered' within the context of the solution and domain.
  In some cases, can introduce cost or complexity that should be considered as a trade-off and explicitly documented as a Key Design Decision.
- `Awareness` &mdash; A 'good to have' and should be considered alongside other recommendations.
  These rules help highlight opportunities for operational maturity.

**Example:**

```yaml
severity: Important
```

### pillar

Aligns with the Azure Well-Architected Framework pillar.
Same values as `Azure.WAF/pillar` in rule tags.

**Values:** `Security`, `Reliability`, `Performance Efficiency`, `Cost Optimization`, `Operational Excellence`

### category

Provides the specific Well-Architected Framework category that the rule addresses.

For example:

- `RE:01 Simplicity and efficiency`
- `SE:10 Monitoring and threat detection`
- `PE:05 Scaling and partitioning`
- `CO:07 Component costs`
- `OE:02 Deployment and testing`

### resource

Human-readable description of the Azure resource type.

**Examples:** `Virtual Machine`, `Storage Account`, `Key Vault`, `Application Gateway`

### resourceType

The Azure resource type(s) that the rule applies to. Can be a single type or comma-separated list.

For example:

- `Microsoft.Compute/virtualMachines`
- `Microsoft.Storage/storageAccounts,Microsoft.Security/defenderForStorageSettings`

### reviewed

The date when the rule documentation was last reviewed, in YYYY-MM-DD format.

For example:

```yaml
reviewed: 2024-01-05
```

### online version

The URL to the online version of the rule documentation.

For example:

```yaml
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.UseManagedDisks/
```

## Baseline metadata

Baselines use YAML metadata to define their scope, purpose, and characteristics.

### metadata.annotations

#### taxonomy

Categorizes the baseline within a classification system.
Valid values include:

- `Azure.WAF` &mdash; Well-Architected Framework baselines

#### pillar

For WAF baselines, specifies the pillar focus.
Same as `Azure.WAF/pillar` in rule tags.

#### export

Indicates whether the baseline should be exported in module manifests.
Valid values are `true`, `false`.

#### moduleVersion

The module version when the baseline was introduced or last updated.

**Format:** `v<major>.<minor>.<patch>` (e.g., `v1.35.0`)

#### experimental

Marks baselines that are in experimental status.
Valid values are `true`, `false`.

#### obsolete

Marks baselines that are obsolete and should not be used.
Valid values are `true`, `false`.

## See also

- [Writing rule help](writing-documentation.md)
- [Working with baselines](../working-with-baselines.md)
- [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Microsoft cloud security benchmark](https://learn.microsoft.com/security/benchmark/azure/)
