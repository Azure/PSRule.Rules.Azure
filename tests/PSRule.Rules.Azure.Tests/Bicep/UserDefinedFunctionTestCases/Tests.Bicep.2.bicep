// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3169
// Based on work contributed by @modbase

targetScope = 'resourceGroup'

module storage 'Tests.Bicep.2.child.bicep' = {
  name: 'storage'
  params: {}
}
