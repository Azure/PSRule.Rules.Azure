// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3409

var subscriptionName string = 'sub-topic-eastus-001'
var firstPart string = split(subscriptionName, '-')[0]
var secondPart string = split(subscriptionName, '-')[?1]
var lastPart string = split(subscriptionName, '-')[^1]
var secondLastPart string = split(subscriptionName, '-')[?^2]

output firstPartOutput string = firstPart
output secondPartOutput string = secondPart
output lastPartOutput string = lastPart
output secondLastPartOutput string = secondLastPart
