#
# Helper functions for rules
#

# Add a custom function to filter by resource type
function global:ResourceType {
    param (
        [String]$ResourceType
    )

    process {
        return $TargetObject.ResourceType -eq $ResourceType;
    }
}

function global:IsAllowedRegion {
    process {
        $region = $Configuration.azureAllowedRegions;
        
        foreach ($r in $Configuration.azureAllowedRegions) {
            $region += ($r -replace ' ', '')
        }

        return $TargetObject.Location -in $region;
    }
}

# Certain rules only apply if resource data has been exported
function global:IsExport {
    process {
        return $Null -ne $TargetObject.PSObject.Properties.Match('SubscriptionId');
    }
}

function global:SupportsAcceleratedNetworking {
    process {
        if ($TargetObject.ResourceType -ne 'Microsoft.Compute/virtualMachines' -or !(IsExport)) {
            return $False;
        }

        if ($Null -eq ($TargetObject.Resources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkInterfaces'})) {
            return $False;
        }

        $vmSize = $TargetObject.Properties.hardwareProfile.vmSize;

        if ($vmSize -notlike 'Standard_*_*') {
            return $False;
        }

        $vmSizeParts = $vmSize.Split('_');
        
        if ($Null -eq $vmSizeParts) {
            return $False;
        }

        $generation = $vmSizeParts[2];
        $size = $vmSizeParts[1];

        # Generation v2
        if ($generation -eq 'v2') {
            if ($size -notmatch 'Standard_(A|NC|DS1_|D1_)') {
                return $True;
            }
        }
        # Generation v3
        elseif ($generation -eq 'v3') {
            if ($size -notmatch 'Standard_(E2s?_|E[2-8]-2|D2s?|NC)') {
                return $True;
            }
        }

        return $False;
    }
}

function global:IsAppGwPublic {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $result = $False;
        foreach ($ip in $TargetObject.Properties.frontendIPConfigurations) {
            if (Exists 'properties.publicIPAddress.id' -InputObject $ip) {
                $result = $True;
            }
        }
        return $result;
    }
}

function global:IsWindowsOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($TargetObject.ResourceType -ne 'Microsoft.Compute/virtualMachines') {
            return $False;
        }
        return $TargetObject.Properties.storageProfile.osDisk.osType -eq "Windows";
    }
}

function global:SupportsTags {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (
            ($TargetObject.ResourceType -eq 'Microsoft.Subscription') -or
            ($TargetObject.ResourceType -like 'Microsoft.Authorization/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Billing/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Classic*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Consumption/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Gallery/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Resources/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.Security/*') -or
            ($TargetObject.ResourceType -like 'microsoft.support/*') -or
            ($TargetObject.ResourceType -like 'Microsoft.WorkloadMonitor/*')
        ) {
            return $False;
        }

        return $True;
    }
}
