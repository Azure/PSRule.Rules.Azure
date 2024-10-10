---
author: BernieWhite
---

# API Management Policy

Discover and test API Management `.xml` policy files.

## Summary

This sample discovers raw API Management policy `.xml` files with a convention.
Once discovered, custom rules can be written to validate the policy by inspecting the XML.
The custom rule `APIManagementPolicy.ValidateJwt` then checks that `validate-jwt` element exists in the policy.

## Usage

- Include the `APIManagementPolicy.Import` convention.
- Store policy XML files in the `policies/` subdirectory.

## References

- [Using custom rules](https://azure.github.io/PSRule.Rules.Azure/customization/using-custom-rules/)
- [Conventions](https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Conventions/#including-with-options)
