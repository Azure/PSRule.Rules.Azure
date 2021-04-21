# Troubleshooting guide

This article provides troubleshooting instructions for common errors.

## Could not load file or assembly YamlDotNet

PSRule >= **v1.3.0-B2104030** uses an updated version of the YamlDotNet library.
The current version of PSRule for Azure uses an older version of this library which may conflict.

To avoid this issue PSRule for Azure <= **v1.3.0** use PSRule v1.2.0.

To install version v1.2.0 of PSRule use the following commands:

```powershell
Install-Module -Name PSRule -RequiredVersion 1.2.0 -Scope CurrentUser;
Install-Module -Name PSRule.Rules.Azure -Scope CurrentUser;
```

To ensure that the correct module versions are loaded use:

```powershell
Import-Module -Name PSRule -RequiredVersion 1.2.0;
Import-Module -Name PSRule.Rules.Azure;
```

For the PSRule GitHub Action use v1.3.0.

```yaml
- name: Run PSRule analysis
  uses: Microsoft/ps-rule@v1.3.0
```

> An update to the support this newer version of YamlDotNet can be tracked [here](https://github.com/microsoft/PSRule.Rules.Azure/issues/742).
