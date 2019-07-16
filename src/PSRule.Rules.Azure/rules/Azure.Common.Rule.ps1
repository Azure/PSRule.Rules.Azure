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
        if ($TargetObject.ResourceType -ne 'Microsoft.Network/applicationGateways') {
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
        if ($TargetObject.ResourceType -ne 'Microsoft.Network/applicationGateways') {
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
        if ($TargetObject.ResourceType -ne 'Microsoft.Compute/virtualMachines') {
            return $False;
        }
        return $TargetObject.Properties.hardwareProfile.vmSize -like '*_Promo';
    }
}
