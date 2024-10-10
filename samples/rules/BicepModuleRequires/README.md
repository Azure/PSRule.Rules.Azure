---
author: BernieWhite
---

# Bicep Module Requires

Discover and test Bicep modules based on a directory structure convention.

## Summary

This sample discovers Bicep modules within a sub-directory such as `modules/` using a convention.
Once discovered, custom rules can be used to validate the module.

For example:

- Does the module have a readme file? Checked using `BicepModuleRequires.RequireReadme`.
- Have tests been created for the module? Checked using `BicepModuleRequires.RequireTests`.

## Usage

- Include the `BicepModuleRequires.Import` convention.
- Create modules in the `modules/` sub-directory.
- Store your modules in major versioned sub-directories.
  i.e. `modules/<moduleName>/<version>/main.bicep`
  e.g. `modules/storage/v1/main.bicep`.

## References

- [Using custom rules](https://azure.github.io/PSRule.Rules.Azure/customization/using-custom-rules/)
- [Conventions](https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Conventions/#including-with-options)
