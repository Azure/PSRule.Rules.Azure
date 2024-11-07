// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

// A custom naming function.
@export()
func customNamingFunction(prefix string, instance int) string =>
  '${prefix}${uniqueString(resourceGroup().id)}${instance}'
