# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Virtual Machine Scale Sets
#

#region Virtual machine scale set

# Synopsis: Use VM naming requirements
Rule 'Azure.VMSS.Name' -Type 'Microsoft.Compute/virtualMachineScaleSets' -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 64)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End with alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Use VM naming requirements
Rule 'Azure.VMSS.ComputerName' -Type 'Microsoft.Compute/virtualMachineScaleSets' -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    $maxLength = 64
    $matchExpression = '^[A-Za-z0-9]([A-Za-z0-9-.]){0,63}$'
    if (IsWindowsOS) {
        $maxLength = 15

        # Alphanumeric or hyphens
        # Can not include only numbers
        $matchExpression = '^[A-Za-z0-9-]{0,14}[A-Za-z-][A-Za-z0-9-]{0,14}$'
    }

    # Between 1 and 15/ 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.virtualMachineProfile.osProfile.computerNamePrefix', 1)
    $Assert.LessOrEqual($TargetObject, 'Properties.virtualMachineProfile.osProfile.computerNamePrefix', $maxLength)

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    Match 'Properties.virtualMachineProfile.osProfile.computerNamePrefix' $matchExpression
}

#endregion Virtual machine scale set
