# Configuring expansion

PSRule for Azure can automatically resolve template and parameter file context at runtime.
This feature can be enabled by using the following configuration options.

## Configuration

!!! Tip
    Each of these configuration options are set within the `ps-rule.yaml` file.
    To learn how to set configuration options see [Configuring options][1].

  [1]: configuring-options.md

### Parameter file expansion

:octicons-milestone-24: v1.4.1

This configuration option determines if Azure template parameter files will automatically be expanded.
By default, parameter files will not be automatically expanded.

Parameter files are expanded when PSRule cmdlets with the `-Format File` parameter are used.

Syntax:

```yaml
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: bool
```

Default:

```yaml
# YAML: The default AZURE_PARAMETER_FILE_EXPANSION configuration option
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: false
```

Example:

```yaml
# YAML: Set the AZURE_PARAMETER_FILE_EXPANSION configuration option to enable expansion
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
```

### Deployment resource group

:octicons-milestone-24: v1.1.0

This configuration option sets the resource group object used by the `resourceGroup()` function.
Configure this option to change the resource group object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-ResourceGroup` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    name: string
    location: string
    tags: object
    properties:
      provisioningState: string
```

Default:

```yaml
# YAML: The default AZURE_RESOURCE_GROUP configuration option
configuration:
  AZURE_RESOURCE_GROUP:
    name: 'ps-rule-test-rg'
    location: 'eastus'
    tags: { }
    properties:
      provisioningState: 'Succeeded'
```

Example:

```yaml
# YAML: Override the location of the resource group object.
configuration:
  AZURE_RESOURCE_GROUP:
    location: 'australiasoutheast'
```

### Deployment subscription

:octicons-milestone-24: v1.1.0

This configuration option sets the subscription object used by the `subscription()` function.
Configure this option to change the subscription object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-Subscription` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: string
    tenantId: string
    displayName: string
    state: string
```

Default:

```yaml
# YAML: The default AZURE_SUBSCRIPTION configuration option
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    displayName: 'PSRule Test Subscription'
    state: 'NotDefined'
```

Example:

```yaml
# YAML: Override the display name of the subscription object
  AZURE_SUBSCRIPTION:
    displayName: 'My test subscription'
```

