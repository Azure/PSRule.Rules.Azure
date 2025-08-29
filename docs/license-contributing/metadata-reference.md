# Metadata reference

PSRule for Azure uses several metadata tags, labels, and annotations that are specific to the framework and Azure resources. This document provides a comprehensive reference for all metadata used across rules, baselines, and documentation.

!!! Abstract
    This topic covers metadata used throughout PSRule for Azure for rules, baselines, and documentation.

## Rule definition metadata

Rules in PSRule for Azure use metadata to categorize, classify, and provide additional context. This metadata is used by baselines to include or exclude rules, and by the documentation system to generate reference materials.

### Tags

Tags are used to categorize rules and are specified using the `-Tag` parameter in rule definitions. Tags are primarily used by baselines to filter which rules to include.

#### release

Indicates the release status of the Azure feature that the rule validates.

**Values:**

- `GA` &mdash; Generally Available features that are fully supported and recommended for production use.
- `preview` &mdash; Preview features that may have limitations or different terms of service.
- `deprecated` &mdash; Rules for features that are no longer recommended or are being phased out.

**Example:**

```powershell
-Tag @{ release = 'GA'; }
```

#### ruleSet

Indicates the quarterly release when the rule was introduced or last significantly updated. Used by quarterly baselines to provide stable checkpoints.

**Format:** `yyyy_mm` where `yyyy` is the year and `mm` is the month (06, 09, 12, 03).

**Values:**

Current rule sets include: `2020_06`, `2020_09`, `2020_12`, `2021_03`, `2021_06`, `2021_09`, `2021_12`, `2022_03`, `2022_06`, `2022_09`, `2022_12`, `2023_03`, `2023_06`, `2023_09`, `2023_12`, `2024_03`, `2024_06`, `2024_09`, `2024_12`, `2025_03`, `2025_06`, `2025_09`.

**Example:**

```powershell
-Tag @{ release = 'GA'; ruleSet = '2025_06'; }
```

#### Azure.WAF/pillar

Aligns the rule with the Microsoft Azure Well-Architected Framework (WAF) pillars.

**Values:**

- `Security` &mdash; Rules that enhance the security posture of Azure resources.
- `Reliability` &mdash; Rules that improve system reliability and resilience.
- `Performance Efficiency` &mdash; Rules that optimize performance and efficiency.
- `Cost Optimization` &mdash; Rules that help optimize costs.
- `Operational Excellence` &mdash; Rules that improve operational practices.

**Example:**

```powershell
-Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; }
```

#### method

Specifies the evaluation method or timing for the rule.

**Values:**

- `in-flight` &mdash; Rules that evaluate resources during deployment or configuration.

**Example:**

```powershell
-Tag @{ release = 'GA'; ruleSet = '2020_12'; method = 'in-flight'; 'Azure.WAF/pillar' = 'Security'; }
```

#### Azure.MCSB.v1/control (in Tags)

When specified in Tags, this associates the rule with Microsoft Cloud Security Benchmark (MCSB) controls. However, this is more commonly specified in Labels.

### Labels

Labels provide additional classification and mapping to external frameworks. They are specified using the `-Labels` parameter in rule definitions.

#### Azure.MCSB.v1/control

Maps the rule to Microsoft Cloud Security Benchmark (MCSB) version 1 controls.

**Common values include:**

- `DP-2` &mdash; Data Protection - Protect data in transit
- `DP-3` &mdash; Data Protection - Monitor unauthorized data transfer
- `DP-4` &mdash; Data Protection - Encrypt sensitive data at rest
- `DP-5` &mdash; Data Protection - Use customer-managed key option
- `ES-3` &mdash; Environmental Security - Secure management ports
- `IM-1` &mdash; Identity Management - Centralize identity and authentication system
- `IM-3` &mdash; Identity Management - Use Azure AD single sign-on
- `LT-1` &mdash; Logging and Threat Detection - Enable threat detection
- `LT-3` &mdash; Logging and Threat Detection - Enable logging for Azure Network Activities
- `LT-4` &mdash; Logging and Threat Detection - Enable logging for Azure Resources
- `NS-1` &mdash; Network Security - Implement segmentation
- `NS-2` &mdash; Network Security - Connect private networks together
- `NS-6` &mdash; Network Security - Simplify network security rules
- `PA-7` &mdash; Privileged Access - Follow just enough administration principles
- `PV-2` &mdash; Platform Vulnerability - Scan for vulnerabilities
- `PV-7` &mdash; Platform Vulnerability - Rapidly and automatically remediate vulnerabilities

**Example:**

```powershell
-Labels @{ 'Azure.MCSB.v1/control' = 'DP-4' }
-Labels @{ 'Azure.MCSB.v1/control' = @('DP-2', 'LT-1') } # Multiple controls
```

#### Azure.Policy/id

References the corresponding Azure Policy definition ID for rules that align with built-in Azure policies.

**Format:** Full Azure Policy definition resource ID.

**Example:**

```powershell
-Labels @{ 'Azure.Policy/id' = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d' }
```

#### Azure.CAF

Maps the rule to Cloud Adoption Framework (CAF) categories.

**Values:**

- `naming` &mdash; Rules related to resource naming conventions.
- `tagging` &mdash; Rules related to resource tagging standards.

**Example:**

```powershell
-Labels @{ 'Azure.CAF' = 'naming' }
```

#### Azure.WAF/maturity

Indicates the maturity level for Well-Architected Framework implementation.

**Values:**

- `L1` &mdash; Level 1 maturity requirements.

**Example:**

```powershell
-Labels @{ 'Azure.MCSB.v1/control' = 'LT-4'; 'Azure.WAF/maturity' = 'L1'; }
```

#### Azure.WAF/progressive

Indicates progressive implementation approach for Well-Architected Framework.

**Values:**

- `C` &mdash; Core or critical implementation.

**Example:**

```powershell
-Labels @{ 'Azure.MCSB.v1/control' = 'DP-3'; 'Azure.WAF/progressive' = 'C'; 'Azure.WAF/maturity' = 'L1'; }
```

## Documentation metadata

Rule documentation uses front matter metadata to provide structured information about each rule. This metadata is used to generate documentation and provide context to users.

### severity

Indicates the subjective impact rating of the rule on the solution or platform.

**Values:**

- `Critical` &mdash; A 'must have' if the solution is to be considered 'fit for purpose', secure, well governed and managed inline with the Microsoft Azure Well-Architected Framework.
- `Important` &mdash; A 'to be considered' within the context of the solution and domain. In some cases, can introduce cost or complexity that should be considered as a trade-off and explicitly documented as a Key Design Decision.
- `Awareness` &mdash; A 'good to have' and should be considered alongside other recommendations. These rules help highlight opportunities for operational maturity.

**Example:**

```yaml
---
severity: Important
---
```

### pillar

Aligns with the Azure Well-Architected Framework pillar. Same values as `Azure.WAF/pillar` in rule tags.

**Values:** `Security`, `Reliability`, `Performance Efficiency`, `Cost Optimization`, `Operational Excellence`

### category

Provides the specific Well-Architected Framework category that the rule addresses.

**Examples:**

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

**Examples:**

- `Microsoft.Compute/virtualMachines`
- `Microsoft.Storage/storageAccounts,Microsoft.Security/defenderForStorageSettings`

### reviewed

The date when the rule documentation was last reviewed, in YYYY-MM-DD format.

**Example:**

```yaml
reviewed: 2024-01-05
```

### online version

The URL to the online version of the rule documentation.

**Example:**

```yaml
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.UseManagedDisks/
```

## Baseline metadata

Baselines use YAML metadata to define their scope, purpose, and characteristics.

### metadata.name

The unique identifier for the baseline.

**Common patterns:**

- `Azure.Default` &mdash; Default baseline with GA rules
- `Azure.Preview` &mdash; Includes GA and preview rules
- `Azure.All` &mdash; Includes all rules
- `Azure.GA_yyyy_mm` &mdash; Quarterly GA baselines
- `Azure.Preview_yyyy_mm` &mdash; Quarterly preview baselines
- `Azure.Pillar.<PillarName>` &mdash; WAF pillar-specific baselines

### metadata.annotations

#### taxonomy

Categorizes the baseline within a classification system.

**Values:**

- `Azure.WAF` &mdash; Well-Architected Framework baselines

#### pillar

For WAF baselines, specifies the pillar focus.

**Values:** Same as `Azure.WAF/pillar` in rule tags.

#### maturity

For WAF baselines with maturity levels.

**Values:**

- `L1` &mdash; Level 1 maturity

#### export

Indicates whether the baseline should be exported in module manifests.

**Values:** `true`, `false`

#### moduleVersion

The module version when the baseline was introduced or last updated.

**Format:** `v<major>.<minor>.<patch>` (e.g., `v1.35.0`)

#### experimental

Marks baselines that are in experimental status.

**Values:** `true`, `false`

#### obsolete

Marks baselines that are obsolete and should not be used.

**Values:** `true`, `false`

## Pattern metadata

Patterns use metadata to describe their purpose and characteristics.

### description

Provides a human-readable description of what the pattern does or validates.

**Example:**

```csharp
[YamlMember(Alias = "description")]
public string Description { get; set; } = string.Empty;
```

## Best practices

When working with metadata in PSRule for Azure:

1. **Consistency** &mdash; Use consistent values across similar rules and follow established patterns.

2. **Current rule sets** &mdash; For new rules, use the current or next quarter's ruleSet based on the release schedule.

3. **Multiple controls** &mdash; When a rule maps to multiple MCSB controls, use an array format.

4. **Documentation alignment** &mdash; Ensure rule metadata aligns with the documentation front matter.

5. **Baseline inclusion** &mdash; Consider how metadata will affect baseline rule inclusion when designing new rules.

## See also

- [Writing rule help](writing-documentation.md)
- [Working with baselines](../working-with-baselines.md)
- [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Microsoft cloud security benchmark](https://learn.microsoft.com/security/benchmark/azure/)