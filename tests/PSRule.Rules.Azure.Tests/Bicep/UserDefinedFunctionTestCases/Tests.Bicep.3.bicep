// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3483
// Based on work contributed by @GABRIELNGBTUC

import { getResourceGroupSuffix } from 'Tests.Bicep.3.import.bicep'

#disable-next-line no-unused-params
param suffix string = 'some-template-${getResourceGroupSuffix(resourceGroup().location)}'
