# Upgrade notes

This document contains notes to help upgrade from previous versions of PSRule for Azure.

## Upgrading to v2.0.0

PSRule for Azure v2.0.0 is a planned _future_ release.
It's not yet available, but you can take these steps to proactively prepare for the release.

### Realigned configuration option names

Several configuration options will be renamed in upcomming releases of PSRule for Azure.
This is part of a ongoing effort to align the naming of configuration options across PSRule for Azure.
For information on other options that will be renamed see [deprecations][1].

You **only** need to take action if you have explictly set old configuration option names.

The old option names may be set in:

- An option file such as `ps-rule.yaml`.
- A custom baseline.
- An environment variable.

To locate any configurations, search for the old option names within your Infrasturcture as Code repo.

New name                                  | Old name                             | Available from
--------                                  | --------                             | --------------
`AZURE_AKS_CLUSTER_MINIMUM_VERSION`       | `Azure_AKSMinimumVersion`            | :octicons-milestone-24: v1.12.0

To update your configuration, use the new name instead.

  [1]: deprecations.md#realigned-configuration-option-names

!!! Note
    Environment variables are prefixed by `PSRULE_CONFIGURATION_` and are case sensitive.

=== "Options file"

    Set the `AZURE_AKS_CLUSTER_MINIMUM_VERSION` option in `ps-rule.yaml`.

    ```yaml
    # YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
    configuration:
      AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.22.4
    ```

=== "Bash"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```bash
    # Bash: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
    export PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION=1.22.4
    ```

=== "GitHub Actions"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```yaml
    # GitHub Actions: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
    env:
      PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.22.4'
    ```

=== "Azure Pipelines"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```yaml
    # Azure Pipelines: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
    variables:
    - name: PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION
      value: '1.22.4'
    ```
