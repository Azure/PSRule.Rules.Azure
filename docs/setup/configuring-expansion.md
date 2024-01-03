---
author: BernieWhite
---

# Configuring expansion

PSRule for Azure can automatically resolve Azure resource context at runtime from infrastructure code.
This feature can be enabled by using the following configuration options.

## Configuration

!!! Tip
    Each of these configuration options are set within the `ps-rule.yaml` file.
    To learn how to set configuration options see [Configuring options][1].

  [1]: configuring-options.md

### Parameter file expansion

<!-- module:version v1.4.1 -->

This configuration option determines if Azure template parameter files will automatically be expanded.
By default, parameter files will not be automatically expanded.
When enabled, PSRule will discover and expand JSON parameter files for Azure templates or Bicep modules.

Parameter files are expanded when PSRule cmdlets with the `-Format File` parameter are used.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: bool
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_PARAMETER_FILE_EXPANSION configuration option
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: false
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set the AZURE_PARAMETER_FILE_EXPANSION configuration option to enable expansion
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
```

### Bicep source expansion

<!-- module:version v1.11.0 -->

This configuration option determines if Azure Bicep source files will automatically be expanded.
By default, Bicep files will not be automatically expanded.

Bicep files are expanded when PSRule cmdlets with the `-Format File` parameter are used.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_BICEP_FILE_EXPANSION: bool
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_BICEP_FILE_EXPANSION configuration option
configuration:
  AZURE_BICEP_FILE_EXPANSION: false
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set the AZURE_BICEP_FILE_EXPANSION configuration option to enable expansion
configuration:
  AZURE_BICEP_FILE_EXPANSION: true
```

### Bicep parameter expansion

<!-- module:version v1.27.0 -->

This configuration option determines if Azure Bicep parameter files (`.bicepparam`) are expanded.
Currently while this is an experimental feature this is not enabled by default.

Bicep files are expanded when PSRule cmdlets with the `-Format File` parameter are used.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_BICEP_PARAMS_FILE_EXPANSION: bool
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_BICEP_PARAMS_FILE_EXPANSION configuration option
configuration:
  AZURE_BICEP_PARAMS_FILE_EXPANSION: false
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set the AZURE_BICEP_PARAMS_FILE_EXPANSION configuration option to enable expansion
configuration:
  AZURE_BICEP_PARAMS_FILE_EXPANSION: true
```

### Bicep compilation timeout

<!-- module:version v1.13.3 -->

This configuration option determines the maximum time to spend building a single Bicep source file.
The timeout is configured in seconds.

When a timeout occurs, PSRule for Azure stops the build and returns an error.
Any resources contained within Bicep source files that exceeded the timeout are not analyzed.

The default timeout is 5 seconds, however the timeout can be set to an integer between `1` and `120`.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_BICEP_FILE_EXPANSION_TIMEOUT: int
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_BICEP_FILE_EXPANSION_TIMEOUT configuration option
configuration:
  AZURE_BICEP_FILE_EXPANSION_TIMEOUT: 5
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set the AZURE_BICEP_FILE_EXPANSION_TIMEOUT configuration option to enable expansion
configuration:
  AZURE_BICEP_FILE_EXPANSION_TIMEOUT: 15
```

### Require template metadata link

<!-- module:version v1.7.0 -->

This configuration option determines if Azure template parameter files require a metadata link.
When configured to `true`, the `Azure.Template.MetadataLink` rule is enabled.
Any Azure template parameter files that do not include a metadata link will report a fail for this rule.

The rule `Azure.Template.MetadataLink` is not enabled by default.
Additionally, when enabled this rule can still be excluded or suppressed like all other rules.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_PARAMETER_FILE_METADATA_LINK: bool
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_PARAMETER_FILE_METADATA_LINK configuration option
configuration:
  AZURE_PARAMETER_FILE_METADATA_LINK: false
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set the AZURE_PARAMETER_FILE_METADATA_LINK configuration option to enable expansion
configuration:
  AZURE_PARAMETER_FILE_METADATA_LINK: true
```

### Deployment properties

<!-- module:version v1.17.0 -->

This configuration option sets the deployment object use by the `deployment()` function.
Configure this option to change the details of the deployment when exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option applies to the parent deployment.
Nested deployments will use any properties configured within code.
Additionally, this configuration option will be ignore when `-Name` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_DEPLOYMENT:
    name: string
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_DEPLOYMENT configuration option
configuration:
  AZURE_DEPLOYMENT:
    name: 'ps-rule-test-deployment'
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Override the name of the deployment object.
configuration:
  AZURE_DEPLOYMENT:
    name: 'deploy-web-application'
```

### Deployment resource group

<!-- module:version v1.1.0 -->

This configuration option sets the resource group object used by the `resourceGroup()` function.
Configure this option to change the resource group object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-ResourceGroup` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_RESOURCE_GROUP:
    name: string
    location: string
    tags: object
    properties:
      provisioningState: string
```

Default:

```yaml title='ps-rule.yaml'
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

```yaml title='ps-rule.yaml'
# YAML: Override the location of the resource group object.
configuration:
  AZURE_RESOURCE_GROUP:
    location: 'australiasoutheast'
```

### Deployment subscription

<!-- module:version v1.1.0 -->

This configuration option sets the subscription object used by the `subscription()` function.
Configure this option to change the subscription object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-Subscription` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: string
    displayName: string
    state: string
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_SUBSCRIPTION configuration option
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    displayName: 'PSRule Test Subscription'
    state: 'NotDefined'
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Override the display name of the subscription object
configuration:
  AZURE_SUBSCRIPTION:
    displayName: 'My test subscription'
```

### Deployment tenant

<!-- module:version v1.11.0 -->

This configuration option sets the tenant object used by the `tenant()` function.
Configure this option to change the tenant object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_TENANT:
    countryCode: string
    tenantId: string
    displayName: string
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_TENANT configuration option
configuration:
  AZURE_TENANT:
    countryCode: 'US'
    tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    displayName: 'PSRule'
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Override the display name of the tenant object
configuration:
  AZURE_TENANT:
    displayName: 'Contoso'
```

### Deployment management group

<!-- module:version v1.11.0 -->

This configuration option sets the management group object used by the `managementGroup()` function.
Configure this option to change the management group object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_MANAGEMENT_GROUP:
    name: string
    properties:
      displayName: string
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_MANAGEMENT_GROUP configuration option
configuration:
  AZURE_MANAGEMENT_GROUP:
    name: 'psrule-test'
    properties:
      displyName: 'PSRule Test Management Group'
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Override the display name of the management group object
configuration:
  AZURE_MANAGEMENT_GROUP:
    properties:
      displayName: 'My test management group'
```

### Required parameter defaults

<!-- module:version v1.13.0 -->

This configuration option allows a fallback value to be configured for required parameters.
When a parameter value is not provided and a default is not set, the fallback value will be used.

Configure this option when you are providing a set of common parameters dynamically during a pipeline.
In this scenario, it may not make sense to add the parameters to a parameter file or Bicep deployment.

Syntax:

```yaml title='ps-rule.yaml'
configuration:
  AZURE_PARAMETER_DEFAULTS:
    <parameter>: <value>
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default AZURE_PARAMETER_DEFAULTS configuration option
configuration:
  AZURE_PARAMETER_DEFAULTS: { }
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Set fallback values for adminPassword and workspaceId parameters.
configuration:
  AZURE_PARAMETER_DEFAULTS:
    adminPassword: $CREDENTIAL_PLACEHOLDER$
    workspaceId: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}
```

## Excluding files

Template or Bicep source files can be excluded from being processed by PSRule and expansion.
To exclude a file, configure the `input.pathIgnore` option by providing a path spec to ignore.

Syntax:

```yaml title='ps-rule.yaml'
input:
  pathIgnore:
  - string
  - string
```

Default:

```yaml title='ps-rule.yaml'
# YAML: The default input.pathIgnore option
input:
  pathIgnore: []
```

Example:

```yaml title='ps-rule.yaml'
# YAML: Exclude a file from being processed by PSRule and expansion
input:
  pathIgnore:
  - 'out/'
  - 'modules/**/*.bicep'
```
