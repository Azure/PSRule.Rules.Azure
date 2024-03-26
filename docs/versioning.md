---
author: BernieWhite
discussion: false
---

# Changes and versioning

As PSRule evolves over time features and rules are added, updated, and removed.
PSRule for Azure uses [semantic versioning][1] to declare breaking changes.

- Major releases are infrequent in nature, but created on an as-needed basis.
  You can check the [upgrade notes][3] to plan for the changes of the next major release.
- Minor releases are shipped normally each month.
- Patch releases to fix bugs for the most recent minor version are released on an as-needed basis.

The latest module version can be installed from the PowerShell Gallery and NuGet.
For a list of module changes please see the [change log][2].

  [1]: https://semver.org/
  [2]: https://aka.ms/ps-rule-azure/changelog
  [3]: upgrade-notes.md

## Module releases

### Stable releases

Stable modules versions are identified by a version number (`major.minor.patch`) such as `1.34.2`.
A stable release is considered production ready and is recommended for general use.
These versions are can be installed from the PowerShell Gallery or NuGet.

When using PSRule extensions in GitHub and Azure Pipelines,
the latest stable version is automatically installed by default when an existing version is not already installed.

The version of PSRule and PSRule for Azure modules can be viewed by default in the output of each run.

### Pre-releases

Pre-release module versions are created on major commits and can be installed from the PowerShell Gallery.
Module versions and change log details for pre-releases will be removed as stable releases are made available.

You can identify a pre-release version by the pre-release suffix on the end of the version (`major.minor.patch-prerelease`).
For example, `1.35.0-B0055`.

To use a pre-release version you will need to install it specifically.
To do this, insert a PowerShell step in your pipeline to install the module with the `-AllowPrerelease` switch.

For example:

```powershell
Install-Module -Name 'PSRule.Rules.Azure' -RequiredVersion '1.35.0-B0055' -AllowPrerelease -Force;
```

!!! Important
    Pre-release versions should be considered work in progress.
    These releases should not be used in production.
    We may introduce breaking changes between a pre-release as we work towards a stable version release.

### Experimental features

From time to time we may ship experiential features.
Experiential features are shipped so that customers can try them out and provide feedback.
These features are generally marked experimental in the change log as these features ship.
Experimental features may ship in stable releases, however to use them you may need to:

- Enable or explicitly reference them.

!!! Important
    Experimental features should be considered work in progress.
    These features may be incomplete and should not be used in production.
    We may introduce breaking changes for experimental features as we work towards a general release for the feature.

## Rule lifecycle

Common rules are added and updated on a regular basis.
Occasionally rules are removed or deprecated.

The following information outlines how changes to rules are managed within PSRule for Azure.

- **New** - rules are introduced to PSRule for Azure on a regular basis as Azure evolves and recommended practices are identified.
  Recommended practices are aligned to the [Azure Well-Architected Framework][4].
  Each rule is added to a rule set which identifies the quarter and year the rule was added/ updated (e.g. `2024_03`).
- **Bug fix** - is a change that corrects a rule that is not working as intended.
  These updates are shipped regularly in the next release.
  Typically no action is required to receive these updates in addition to using the latest release.
- **Revision** - is an improvement to the rule that changes the behavior of the rule.
  Most commonly these changes are made to better align with the intent of the rule and Azure features as they evolve.
  The changes log, GitHub issue, rule documentation, and rule set are updated to reflect the change.
  [Quarterly baselines][5] are provided to help manage these changes by providing a stable checkpoint for a given quarter.
  These updates normally ship in the next minor release.
- **Rename** - is a change to the rule name to better reflect the intent of the rule or to align with naming conventions.
  These changes can occur when Microsoft products or features are renamed, similar rules are renamed to reduce customer confusion.
  When a rule is renamed, the old name is added as an alias, this allows existing suppression to continue to work.
  A warning will be generated if you are referencing the rule alias so you can update your configuration.
  These updates normally ship in the next minor release.
- **Deprecation/ removal** - occurs when checking for the conditions of the rule is no longer necessary or it no longer aligns.
  In these cases, the rule may be removed or if there is still some customer value it may be retained but not run by default.
  For example, the rule may not align to the Well-Architected Framework but is still useful for some customers.
  This is done by the means of a feature flag, by requiring a configuration value to be set.
  Check the rule documentation for details on any configuration requirements.

  [4]: https://learn.microsoft.com/azure/well-architected/
  [5]: working-with-baselines.md

## Reporting bugs

If you experience an issue with a feature or release please let us know by logging an issue as a [bug][6].

  [6]: https://github.com/Azure/PSRule.Rules.Azure/issues
