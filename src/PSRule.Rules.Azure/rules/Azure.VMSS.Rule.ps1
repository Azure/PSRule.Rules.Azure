# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Virtual Machine Scale Sets
#

#region Virtual machine scale set

# Synopsis: Use VM naming requirements
Rule 'Azure.VMSS.Name' -Ref 'AZR-000261' -Type 'Microsoft.Compute/virtualMachineScaleSets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 64)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End with alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Use VM naming requirements
Rule 'Azure.VMSS.ComputerName' -Ref 'AZR-000262' -Type 'Microsoft.Compute/virtualMachineScaleSets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

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

# Synopsis: Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities.
Rule 'Azure.VMSS.PublicKey' -Ref 'AZR-000288' -Type 'Microsoft.Compute/virtualMachineScaleSets' -If { VMSSHasLinuxOS } -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-4' } {
    $Assert.In($TargetObject, 'properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication', $True).
    Reason($LocalizedData.VMSSPublicKey, $PSRule.TargetName)
}

# Synopsis: Protect Custom Script Extensions commands
Rule 'Azure.VMSS.ScriptExtensions' -Ref 'AZR-000333' -Type 'Microsoft.Compute/virtualMachineScaleSets', 'Microsoft.Computer/virtualMachineScaleSets/CustomScriptExtension', 'Microsoft.Compute/virtualMachineScaleSets/extensions' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $vmssConfig = @($TargetObject);

    ## Extension Prof
    if ($vmssConfig.properties.virtualMachineProfile.extensionProfile.extensions) {
        foreach($extensions in $vmssConfig.properties.virtualMachineProfile.extensionProfile.extensions ) {
            $cleanValue = [PSRule.Rules.Azure.Runtime.Helper]::CompressExpression($extensions.properties.settings.commandToExecute);
            $Assert.NotMatch($cleanValue, '.', "SecretReference")
        } 

    } else {
        return $Assert.Pass();
    }
}

# Synopsis: Use Azure Monitor Agent as replacement for Log Analytics Agent.
Rule 'Azure.VMSS.MigrateAMA' -Ref 'AZR-000318' -Type 'Microsoft.Compute/virtualMachineScaleSets' -If { HasOMSOrAMAExtension } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $property = $TargetObject.Properties.virtualMachineProfile.extensionProfile.extensions.properties |
        Where-Object { (($_.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.type -eq 'MicrosoftMonitoringAgent')) -or
            (($_.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.type -eq 'OmsAgentForLinux')) }
                $subresource = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachineScaleSets/extensions' |
                    Where-Object { (($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.Properties.type -eq 'MicrosoftMonitoringAgent')) -or
                        (($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.Properties.type -eq 'OmsAgentForLinux')) })
    
    $extensions = @($property; $subresource)
    $Assert.Less($extensions, '.', 1).Reason($LocalizedData.LogAnalyticsAgentDeprecated)
}

# Synopsis: Use Azure Monitor Agent for collecting monitoring data.
Rule 'Azure.VMSS.AMA' -Ref 'AZR-000346' -Type 'Microsoft.Compute/virtualMachineScaleSets' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $amaTypes = @('AzureMonitorWindowsAgent', 'AzureMonitorLinuxAgent')
        $property = $TargetObject.Properties.virtualMachineProfile.extensionProfile.extensions.properties |
            Where-Object { $_.publisher -eq 'Microsoft.Azure.Monitor' -or $_.type -in $amaTypes }
                $subresource = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachineScaleSets/extensions' |
                    Where-Object { $_.properties.publisher -eq 'Microsoft.Azure.Monitor' -or $_.properties.type -in $amaTypes })
    
    $amaExtensions = @($property; $subresource)       
    $Assert.GreaterOrEqual($amaExtensions, '.', 1).
    Reason($LocalizedData.VMSSAzureMonitorAgent)
}

#endregion Virtual machine scale set

#region Helper functions

function global:IsLinuxVMSS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.HasField($TargetObject, 'properties.virtualMachineProfile.OsProfile.linuxConfiguration').Result
    }
}

#endregion Helper functions
