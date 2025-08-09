// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3483
// Based on work contributed by @GABRIELNGBTUC

var regionShorthandMapping = {
  eastus: 'eus'
}

@export()
func getResourceGroupSuffix(location string) string =>
  !contains(regionShorthandMapping, location) ? 'we' : regionShorthandMapping[location]
