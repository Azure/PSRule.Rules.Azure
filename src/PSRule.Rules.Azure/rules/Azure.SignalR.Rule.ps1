# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for SignalR service
#

# Synopsis: Use SignalR naming requirements
Rule 'Azure.SignalR.Name' -Type 'Microsoft.SignalRService/signalR' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftsignalrservice

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Alphanumerics and hyphens
    # Start with letter
    # End with letter or number
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z](-|[A-Za-z0-9])*[A-Za-z0-9]$');
}
