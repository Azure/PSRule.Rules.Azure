---
author: BernieWhite
---

# Troubleshooting

This article provides troubleshooting instructions for common errors.

## Bicep compilation timeout

When expanding Bicep source files you may get an error similar to the following:

!!! Error

    Bicep (0.4.1124) compilation of 'C:\temp\deploy.bicep' failed with: Bicep compilation hasn't completed within the timeout window. This can be caused by errors or warnings. Check the Bicep output by running bicep build and addressing any issues.

This error is raised when Bicep takes longer then the timeout to build a source file.
The default timeout is 5 seconds.

You can take steps to reduce your code complexity and reduce the time a build takes by:

- Removing unnecessary nested `module` calls.
- Cache bicep modules restored from a registry in continious integration (CI) pipelines.

To increase the timeout value, set the `AZURE_BICEP_FILE_EXPANSION_TIMEOUT` configuration option.
See [Bicep compilation timeout][1] for details on how to configure this option.

  [1]: setup/configuring-expansion.md#bicepcompilationtimeout

## Could not load file or assembly YamlDotNet

PSRule **>=1.3.0** uses an updated version of the YamlDotNet library.
The PSRule for Azure **<1.3.1** uses an older version of this library which may conflict.

To avoid this issue:

- Update to the latest version and use PSRule for Azure **>=1.3.1** with PSRule **>=1.3.0**.
- Alternatively, when using PSRule for Azure **<1.3.1** use PSRule **=1.2.0**.

To install the latest module version of PSRule use the following commands:

```powershell
Install-Module -Name PSRule.Rules.Azure -MinimumVersion 1.3.1 -Scope CurrentUser -Force;
```

For the PSRule GitHub Action, use **>=1.4.0**.

```yaml
- name: Run PSRule analysis
  uses: Microsoft/ps-rule@v1.4.0
```
