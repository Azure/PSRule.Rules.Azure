# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Helper functions for rules
#

# Add a custom function to filter by resource type
function global:ResourceType {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$ResourceType
    )
    process {
        return $PSRule.TargetType -eq $ResourceType;
    }
}

function global:ExtensionResourceType {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$ResourceType
    )
    process {
        return $TargetObject.ExtensionResourceType -eq $ResourceType;
    }
}

# Get sub resources of a specific resource type
function global:GetSubResources {
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param (
        [Parameter(Mandatory = $True)]
        [String[]]$ResourceType,

        [Parameter(Mandatory = $False)]
        [String[]]$Name
    )
    process {
        return @($TargetObject.resources | Where-Object -FilterScript {
            ($_.ResourceType -in $ResourceType -or $_.Type -in $ResourceType -or $_.ExtensionResourceType -in $ResourceType) -and
            ($Null -eq $Name -or $Name.Length -eq 0 -or $_.Name -in $Name -or $_.ResourceName -in $Name)
        })
    }
}

function global:IsAllowedRegion {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $region = @($Configuration.Azure_AllowedRegions);
        foreach ($r in $Configuration.Azure_AllowedRegions) {
            $region += ($r -replace ' ', '')
        }
        return $TargetObject.Location -in $region;
    }
}

# Certain rules only apply if resource data has been exported
function global:IsExport {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Null -ne $TargetObject.SubscriptionId;
    }
}

function global:HasPeerNetwork {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Network/virtualNetworks') {
            return $False;
        }
        $peers = $TargetObject.Properties.virtualNetworkPeerings;
        if ($Null -eq $peers) {
            return $False;
        }
        $item = @($peers);
        return $item.Length -gt 0;
    }
}

# Get a sorted list of NSG rules
function global:GetOrderedNSGRules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateSet('Inbound', 'Outbound')]
        [String]$Direction
    )
    process {
        $TargetObject.properties.securityRules |
            Where-Object { $_.properties.direction -eq $Direction } |
            Sort-Object @{ Expression = { $_.Properties.priority }; Descending = $False }
    }
}

function global:SupportsAcceleratedNetworking {
    [CmdletBinding()]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines' -or !(IsExport)) {
            return $False;
        }
        if ($Null -eq ($TargetObject.Resources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkInterfaces'})) {
            return $False;
        }

        $vmSize = $TargetObject.Properties.hardwareProfile.vmSize;
        if ($vmSize -notlike 'Standard_*_*') {
            if ($vmSize -match '^Standard_(F|B[1-2][0-9]ms)') {
                return $True;
            }
            else {
                return $False;
            }
        }

        $vmSizeParts = $vmSize.Split('_');
        if ($Null -eq $vmSizeParts) {
            return $False;
        }

        $generation = $vmSizeParts[2];
        $size = $vmSizeParts[1];

        # Generation v2
        if ($generation -eq 'v2') {
            if ($size -notmatch '^(A|NC|DS1$|D1$|F[1-2]s)') {
                return $True;
            }
        }
        # Generation v3
        elseif ($generation -eq 'v3') {
            if ($size -notmatch '^(E2s?|E[2-8]-2|D2s?|NC)') {
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
        if ($PSRule.TargetType -ne 'Microsoft.Network/applicationGateways') {
            return $False;
        }

        $result = $False;
        foreach ($ip in $TargetObject.Properties.frontendIPConfigurations) {
            if (Exists 'properties.publicIPAddress.id' -InputObject $ip) {
                $result = $True;
            }
        }
        return $result;
    }
}

# Determine if the resource is an Application Gateway with WAF enabled
function global:IsAppGwWAF {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Network/applicationGateways') {
            return $False;
        }
        if ($TargetObject.Properties.sku.tier -notin ('WAF', 'WAF_v2')) {
            return $False;
        }
        if ($TargetObject.Properties.webApplicationFirewallConfiguration.enabled -ne $True) {
            return $False;
        }
        return $True;
    }
}

function global:IsWindowsOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -notin 'Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachineScaleSets') {
            return $False;
        }
        return ($TargetObject.Properties.storageProfile.osDisk.osType -eq 'Windows') -or
            ($TargetObject.Properties.storageProfile.imageReference.publisher -in 'MicrosoftSQLServer', 'MicrosoftWindowsServer', 'MicrosoftVisualStudio', 'MicrosoftWindowsDesktop') -or
            ($TargetObject.Properties.virtualMachineProfile.storageProfile.osDisk.osType -eq 'Windows') -or
            ($TargetObject.Properties.virtualMachineProfile.storageProfile.imageReference.publisher -in 'MicrosoftSQLServer', 'MicrosoftWindowsServer', 'MicrosoftVisualStudio', 'MicrosoftWindowsDesktop')
    }
}

function global:IsWindowsClientOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -notin 'Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachineScaleSets') {
            return $False;
        }
        return $TargetObject.Properties.storageProfile.imageReference.publisher -eq 'MicrosoftWindowsDesktop';
    }
}

function global:SupportsHybridUse {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines') {
            return $False;
        }
        return (
            ($TargetObject.Properties.storageProfile.osDisk.osType -eq 'Windows') -or
            ($TargetObject.Properties.storageProfile.imageReference.publisher -in 'MicrosoftSQLServer', 'MicrosoftWindowsServer')
        ) -and !(IsWindowsClientOS);
    }
}

function global:IsLinuxOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines') {
            return $False;
        }
        return $TargetObject.Properties.storageProfile.osDisk.osType -eq 'Linux';
    }
}

# Determines if the object supports tags
function global:SupportsTags {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (
            ($PSRule.TargetType -eq 'Microsoft.Subscription') -or
            ($PSRule.TargetType -notlike 'Microsoft.*/*') -or
            ($PSRule.TargetType -like 'Microsoft.Addons/*') -or
            ($PSRule.TargetType -like 'Microsoft.Advisor/*') -or
            ($PSRule.TargetType -like 'Microsoft.Authorization/*') -or
            ($PSRule.TargetType -like 'Microsoft.Billing/*') -or
            ($PSRule.TargetType -like 'Microsoft.Blueprint/*') -or
            ($PSRule.TargetType -like 'Microsoft.Capacity/*') -or
            ($PSRule.TargetType -like 'Microsoft.Classic*') -or
            ($PSRule.TargetType -like 'Microsoft.Consumption/*') -or
            ($PSRule.TargetType -like 'Microsoft.Gallery/*') -or
            ($PSRule.TargetType -like 'Microsoft.Security/*') -or
            ($PSRule.TargetType -like 'microsoft.support/*') -or
            ($PSRule.TargetType -like 'microsoft.insights/diagnosticSettings') -or
            ($PSRule.TargetType -like 'Microsoft.WorkloadMonitor/*') -or
            ($PSRule.TargetType -like '*/providers/roleAssignments') -or
            ($PSRule.TargetType -like '*/providers/diagnosticSettings') -or

            # Exclude sub-resources by default
            ($PSRule.TargetType -like 'Microsoft.*/*/*' -and !(
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/runbooks' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/configurations' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/compilationjobs' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/modules' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/nodeConfigurations' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/python2Packages' -or
                $PSRule.TargetType -eq 'Microsoft.Automation/automationAccounts/watchers'
            )) -or

            # Some exception to resources (https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support#microsoftresources)
            ($PSRule.TargetType -like 'Microsoft.Resources/*' -and !(
                $PSRule.TargetType -eq 'Microsoft.Resources/deployments' -or
                $PSRule.TargetType -eq 'Microsoft.Resources/deploymentScripts' -or
                $PSRule.TargetType -eq 'Microsoft.Resources/resourceGroups'
            )) -or

            # Some exceptions to resources (https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support#microsoftcostmanagement)
            ($PSRule.TargetType -like 'Microsoft.CostManagement/*' -and !(
                $PSRule.TargetType -eq 'Microsoft.CostManagement/Connectors'
            ))
        ) {
            return $False;
        }
        return $True;
    }
}

# Determines if the object supports regions
function global:SupportsRegions {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (
            ($PSRule.TargetType -eq 'Microsoft.Subscription') -or
            ($PSRule.TargetType -eq 'Microsoft.AzureActiveDirectory/b2cDirectories') -or
            ($PSRule.TargetType -eq 'Microsoft.Network/trafficManagerProfiles') -or
            ($PSRule.TargetType -like 'Microsoft.Authorization/*') -or
            ($PSRule.TargetType -like 'Microsoft.Consumption/*') -or
            ($PSRule.TargetType -like '*/providers/roleAssignments') -or
            ($TargetObject.Location -eq 'global')
        ) {
            return $False;
        }
        return $True;
    }
}

function global:ConvertToUInt64 {
    param (
        [Parameter(Mandatory = $True)]
        [System.Net.IPAddress]$IP
    )

    process {
        $bytes = $IP.GetAddressBytes();
        $size = $bytes.Length;

        [System.UInt64]$result = 0;

        for ($i = 0; $i -lt $size; $i++) {
            $result = ($result -shl 8) + $bytes[$i];
        }
        return $result;
    }
}

function global:GetIPAddressCount {
    [CmdletBinding()]
    [OutputType([System.UInt64])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Start,

        [Parameter(Mandatory = $True)]
        [String]$End
    )
    process {
        $startIP = [System.Net.IPAddress]::Parse($Start);
        $endIP = [System.Net.IPAddress]::Parse($End);

        $startAddress = ConvertToUInt64 -IP $startIP;
        $endAddress = ConvertToUInt64 -IP $endIP;

        if ($endAddress -ge $startAddress) {
            return $endAddress - $startAddress + 1;
        }
        else {
            return $startAddress - $endAddress + 1;
        }
    }
}

function global:GetIPAddressSummary {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
            $_.Type -like "*/firewallRules"
        } | ForEach-Object -Process {
            if (!($_.ResourceName -eq 'AllowAllWindowsAzureIps' -or ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0'))) {
                $_;
            }
        })

        $private = 0;
        $public = 0;

        foreach ($fwRule in $firewallRules) {
            if ($fwRule.Properties.startIpAddress -like "10.*" -or $fwRule.Properties.startIpAddress -like "172.*" -or $fwRule.Properties.startIpAddress -like "192.168.*") {
                $private += GetIPAddressCount -Start $fwRule.Properties.startIpAddress -End $fwRule.Properties.endIpAddress;
            }
            else {
                $public += GetIPAddressCount -Start $fwRule.Properties.startIpAddress -End $fwRule.Properties.endIpAddress;
            }
        }
        return [PSCustomObject]@{
            Private = $private
            Public = $public
        }
    }
}

function global:GetCIDRMask {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$CIDR
    )
    process {
        $cidrParts = $CIDR.Split('/');
        $ip = ConvertToUInt64 -IP ([System.Net.IPAddress]::Parse($cidrParts[0]));
        [System.UInt64]$mask = 4294967295;
        if ($cidrParts.Length -eq 2) {
            $mask = [System.UInt64](4294967295 -shl (32-([System.Byte]::Parse($cidrParts[1])))) -band 4294967295;
        }
        return [PSCustomObject]@{
            Mask = $mask
            IP = $ip;
        }
    }
}

function global:WithinCIDR {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$IP,

        [Parameter(Mandatory = $True)]
        [String[]]$CIDR
    )
    process {
        [System.UInt64]$address = ConvertToUInt64 -IP ([System.Net.IPAddress]::Parse($IP));
        $result = $False;

        for ($i = 0; (($i -lt $CIDR.Length) -and (!$result)); $i++) {
            $mask = GetCIDRMask -CIDR $CIDR[$i];
            $result = ($mask.Mask -band $address) -eq $mask.IP;
        }
        return $result;
    }
}

# Determine if the VM is using a promo SKU.
function global:IsVMPromoSku {
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines') {
            return $False;
        }
        return $TargetObject.Properties.hardwareProfile.vmSize -like '*_Promo';
    }
}

# Normalizes the location for comparison.
function global:GetNormalLocation {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Location
    )
    process {
        return $Location.Replace(' ', '').ToLower();
    }
}
