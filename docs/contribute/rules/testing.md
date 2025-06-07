---
reviewed: 2025-06-07
description: Learn how to add unit tests for rules and how to run them in PSRule for Azure.
discussion: false
---

# Testing a rule

Each rule in PSRule for Azure must include unit tests to ensure the rule works as expected.
The unit test ensures the rule logic passes when the rule is expected to pass, and fails when the rule is expected to fail.

Tests are organized by the service that the rule applies to, and the file name include the rule prefix.
In many cases the test file will already exist, and you can add your tests to the existing file.
For example, if the rule is named `Azure.Storage.SecureTransfer` the test file should be named `Azure.Storage.Tests.ps1`.

To support testing rules, PSRule for Azure includes a set of sample resources that can be used to test the rules.
Similar to tests, many samples already exist and you can add your samples to the existing file.

Both tests and samples are located in the `tests/PSRule.Rules.Azure.Tests/` directory.

## Adding or updating a sample

Start by adding or updating a sample resource that can be used to test the rule.
Samples are:

- Written as a JSON array of resources and are placed in the `tests/PSRule.Rules.Azure.Tests/` directory,
- Each sample file is named after the rule service in the format `Resources.<servicename>.json`.
  For example, if the rule is called `Azure.Storage.SecureTransfer`, the sample file should be named `Resources.Storage.json`.

In many cases, the existing resource samples will already fail a new rules.
Add/ update samples as required to test the passing and failing scenarios for the rule.

For example, the rule `Azure.Storage.SecureTransfer` requires that secure transfer is enabled for storage accounts by
the `properties.supportsHttpsTrafficOnly` property.

This sample demonstrates minimum resources that will pass and fail the rule:

```json title="tests/PSRule.Rules.Azure.Tests/Resources.Storage.json"
[
  {
    "Id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/storage-A",
    "Kind": "Storage",
    "Location": "region",
    "Name": "storage-A",
    "Properties": {
      "supportsHttpsTrafficOnly": true
    },
    "ResourceGroupName": "test-rg",
    "Type": "Microsoft.Storage/storageAccounts",
    "ResourceType": "Microsoft.Storage/storageAccounts",
    "Sku": {
      "Name": "Standard_GRS",
      "Tier": "Standard"
    }
  },
  {
    "Id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/storage-B",
    "Kind": "Storage",
    "Location": "region",
    "Name": "storage-B",
    "Properties": {
      "supportsHttpsTrafficOnly": false
    },
    "ResourceGroupName": "test-rg",
    "Type": "Microsoft.Storage/storageAccounts",
    "ResourceType": "Microsoft.Storage/storageAccounts",
    "Sku": {
      "Name": "Standard_GRS",
      "Tier": "Standard"
    }
  },
  {
    "Id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/storage-C",
    "Kind": "Storage",
    "Location": "region",
    "Name": "storage-C",
    "Properties": {},
    "ResourceGroupName": "test-rg",
    "Type": "Microsoft.Storage/storageAccounts",
    "ResourceType": "Microsoft.Storage/storageAccounts",
    "Sku": {
      "Name": "Standard_GRS",
      "Tier": "Standard"
    }
  }
]
```

<div class="result" markdown>
1. The `storage-A` resource is expected to pass the rule because `supportsHttpsTrafficOnly` is set to `true`.
2. The `storage-B` resource is expected to fail the rule because `supportsHttpsTrafficOnly` is set to `false`.
3. The `storage-C` resource is expected to fail the rule because `supportsHttpsTrafficOnly` is not set.

</div>

## Creating a unit test

Unit tests for rules are written in PowerShell using Pester and placed in the `tests/PSRule.Rules.Azure.Tests/` directory.
To create add a test to an existing file, you can use the following boilerplate code:

```powershell title="PowerShell"
It '<rule_name>' {
    $filteredResult = $result | Where-Object { $_.RuleName -eq '<rule_name>' };

    # Fail
    $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
    $ruleResult | Should -Not -BeNullOrEmpty;
    $ruleResult.TargetName | Should -BeIn '<name>', '<name>';
    $ruleResult.Length | Should -Be 2;

    # Pass
    $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
    $ruleResult | Should -Not -BeNullOrEmpty;
    $ruleResult.TargetName | Should -BeIn '<name>';
    $ruleResult.Length | Should -Be 1;
}
```

<div class="result" markdown>
1. Replace `<rule_name>` with the name of the rule you are testing.
2. Replace `<name>` with the name of the resources you expect to pass or fail.

</div>

For example:

```powershell title="tests/PSRule.Rules.Azure.Tests/Azure.Storage.Tests.ps1"
It 'Azure.Storage.SecureTransfer' { # (1)
    $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.SecureTransfer' };

    # Fail
    $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
    $ruleResult | Should -Not -BeNullOrEmpty;
    $ruleResult.TargetName | Should -BeIn 'storage-B', 'storage-C', 'storage-D'; # (2)
    $ruleResult.Length | Should -Be 3;

    # Pass
    $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
    $ruleResult | Should -Not -BeNullOrEmpty;
    $ruleResult.TargetName | Should -BeIn 'storage-A', 'storage-E', 'storage-F', 'storage-G', 'storage-H'; # (3)
    $ruleResult.Length | Should -Be 5;
}
```

<div class="result" markdown>
1. The name of the rule is `Azure.Storage.SecureTransfer`.
2. The rule is expected to fail for resources `storage-B`, `storage-C`, and `storage-D`.
3. The rule is expected to pass for resources `storage-A`, `storage-E`, `storage-F`, `storage-G`, and `storage-H`.

</div>

Here is an example of a unit test for validating rules:
[Azure.ACR.Tests.ps1 Example](https://github.com/Azure/psrule.rules.azure/blob/main/tests/PSRule.Rules.Azure.Tests/Azure.ACR.Tests.ps1#L40-L56)

## Testing a rule locally

Before opening a pull request, it's important to build and test your changes locally.
This is the fastest way to ensure that your changes work as expected and that the rules are functioning correctly.

CI tests must pass before the pull request can be merged,
however they are manually triggered by a maintainer after the pull request is reviewed.

1. **Build and test locally** &mdash; Ensure that you can build your changes locally.
   Follow the instructions in the [Building from Source][3] guide to set up your local environment for testing.
2. **Run all tests** &mdash; Before creating your PR, run the tests to make sure your changes are working as expected.

```powershell title="PowerShell"
Invoke-Build Test -AssertStyle Client
```

  [3]: https://azure.github.io/PSRule.Rules.Azure/install/#building-from-source
