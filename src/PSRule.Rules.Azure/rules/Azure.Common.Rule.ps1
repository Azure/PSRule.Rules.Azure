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
        $results = @();
        $resources = @($TargetObject.resources);
        for ($i = 0; $i -lt $resources.Length; $i++) {
            $path = "resources[$i]";
            if (($resources[$i].ResourceType -in $ResourceType -or $resources[$i].Type -in $ResourceType -or $resources[$i].ExtensionResourceType -in $ResourceType) -and
                ($Null -eq $Name -or $Name.Length -eq 0 -or [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($resources[$i].Name) -in $Name -or [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($resources[$i].ResourceName) -in $Name)) {
                $resource = $resources[$i];
                if (!([bool]$resource.PSObject.Members['_PSRule'])) {
                    $Null = Add-Member -InputObject $resource -MemberType NoteProperty -Name '_PSRule' -Value @{
                        path = $path;
                    }
                }
                elseif (!([bool]$resource._PSRule.PSObject.Members['path'])) {
                    $Null = Add-Member -InputObject $resource._PSRule -MemberType NoteProperty -Force -Name 'path' -Value $path;
                }
                $results += $resource;
            }
        }
        return $results;
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
        $peers = $TargetObject.properties.virtualNetworkPeerings;
        if ($Null -eq $peers) {
            return $False;
        }
        $item = @($peers);
        return $item.Length -gt 0;
    }
}

function global:SupportsAcceleratedNetworking {
    [CmdletBinding()]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines' -or !(IsExport)) {
            return $False;
        }
        if ($Null -eq ($TargetObject.Resources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkInterfaces' })) {
            return $False;
        }

        $vmSize = $TargetObject.Properties.hardwareProfile.vmSize;
        if ($vmSize -notLike 'Standard_*_*') {
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
            if ($size -notMatch '^(A|NC|DS1$|D1$|F[1-2]s)') {
                return $True;
            }
        }
        # Generation v3
        elseif ($generation -eq 'v3') {
            if ($size -notMatch '^(E2s?|E[2-8]-2|D2s?|NC)') {
                return $True;
            }
        }
        return $False;
    }
}

function global:IsWindowsOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -notIn 'Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachineScaleSets') {
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
        if ($PSRule.TargetType -notIn 'Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachineScaleSets') {
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

function global:IsLinuxOffering {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ($imageReference)
    process {
        $configLinuxOffers = $Configuration.GetStringValues('AZURE_LINUX_OS_OFFERS');
        foreach ($configLinuxOffer in $configLinuxOffers) {
            if ($configLinuxOffer -ieq $imageReference.offer) {
                return $True
            }
        }

        $someWindowsOSNames = @('windows')
        if ($Assert.Contains($imageReference.offer, '.', $someWindowsOSNames).Result) {
            return $False
        }

        $someLinuxOSNames = @('ubuntu', 'linux', 'rhel', 'centos', 'redhat', 'debian', 'suse')
        if ($Assert.Contains($imageReference.offer, '.', $someLinuxOSNames).Result) {
            return $True
        }

        foreach ($publicLinuxOffering in $PublicLinuxOfferings) {
            if ($publicLinuxOffering[0] -ieq $imageReference.publisher -and $publicLinuxOffering[1] -ieq $imageReference.offer) {
                return $True
            }
        }

        return $False
    }
}

function global:VMHasLinuxOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachines' -or $TargetObject.Properties.storageProfile.osDisk.osType -eq 'Windows') {
            return $False;
        }

        return $TargetObject.Properties.storageProfile.osDisk.osType -eq 'Linux' -or
        $Assert.HasFieldValue($TargetObject, 'properties.osProfile.linuxConfiguration').Result -or
            (IsLinuxOffering($TargetObject.Properties.storageProfile.imageReference))
    }
}

function global:VMSSHasLinuxOS {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Compute/virtualMachineScaleSets' -or $TargetObject.Properties.virtualMachineProfile.storageProfile.osDisk.osType -eq 'Windows') {
            return $False;
        }

        return $TargetObject.Properties.virtualMachineProfile.storageProfile.osDisk.osType -eq 'Linux' -or
        $Assert.HasFieldValue($TargetObject, 'properties.virtualMachineProfile.osProfile.linuxConfiguration').Result -or
            (IsLinuxOffering($TargetObject.Properties.virtualMachineProfile.storageProfile.imageReference))
    }
}

$Global:FlagSupportsTagWarning = $True;

# Determines if the object supports tags
function global:SupportsTags {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [String]$TargetType = $PSRule.TargetType
    )
    begin {
        if ($Global:FlagSupportsTagWarning) {
            Write-Warning -Message "The 'SupportsTags' PowerShell function has been replaced with the selector 'Azure.Resource.SupportsTags'. The 'SupportsTags' function is deprecated and will no longer work in the next major version. Please update your PowerShell rules to the selector instead. See https://aka.ms/ps-rule-azure/upgrade.";
            $Global:FlagSupportsTagWarning = $False;
        }
    }
    process {
        if (
            ($TargetType -eq 'Microsoft.Subscription') -or
            ($TargetType -eq 'Microsoft.Resources/deployments') -or
            ($TargetType -eq 'Microsoft.AzureActiveDirectory/b2ctenants') -or
            ($TargetType -eq 'Microsoft.OperationsManagement/solutions') -or
            ($TargetType -eq 'Microsoft.Kubernetes/registeredSubscriptions') -or
            ($TargetType -eq 'Microsoft.Network/privateDnsZonesInternal') -or
            ($TargetType -notLike 'Microsoft.*/*') -or
            ($TargetType -like 'Microsoft.Addons/*') -or
            ($TargetType -like 'Microsoft.Advisor/*') -or
            ($TargetType -like 'Microsoft.Billing/*') -or
            ($TargetType -like 'Microsoft.Blueprint/*') -or
            ($TargetType -like 'Microsoft.Capacity/*') -or
            ($TargetType -like 'Microsoft.Classic*') -or
            ($TargetType -like 'Microsoft.Consumption/*') -or
            ($TargetType -like 'Microsoft.Gallery/*') -or
            ($TargetType -like 'Microsoft.Security/*') -or
            ($TargetType -like 'microsoft.support/*') -or
            ($TargetType -like 'Microsoft.WorkloadMonitor/*') -or
            ($TargetType -like 'Microsoft.ManagedServices/*') -or
            ($TargetType -like 'Microsoft.Management/*') -or
            ($TargetType -like 'Microsoft.PolicyInsights/*') -or
            ($TargetType -like '*/providers/roleAssignments') -or
            ($TargetType -like '*/providers/diagnosticSettings') -or

            # Exclude sub-resources by default
            ($TargetType -like 'Microsoft.*/*/*' -and !(
                $TargetType -eq 'Microsoft.Automation/automationAccounts/runbooks' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/configurations' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/compilationjobs' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/modules' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/nodeConfigurations' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/python2Packages' -or
                $TargetType -eq 'Microsoft.Automation/automationAccounts/watchers' -or
                $TargetType -eq 'Microsoft.Resources/templateSpecs/versions'
            )) -or

            # Some exception to resources (https://learn.microsoft.com/azure/azure-resource-manager/management/tag-support#microsoftresources)
            ($TargetType -like 'Microsoft.Resources/*' -and !(
                $TargetType -eq 'Microsoft.Resources/deploymentScripts' -or
                $TargetType -eq 'Microsoft.Resources/resourceGroups' -or
                $TargetType -eq 'Microsoft.Resources/templateSpecs' -or
                $TargetType -eq 'Microsoft.Resources/templateSpecs/versions'
            )) -or

            # Some exception to resources (https://learn.microsoft.com/azure/azure-resource-manager/management/tag-support#microsoftinsights)
            ($TargetType -like 'Microsoft.Insights/*' -and !(
                $TargetType -eq 'Microsoft.Insights/actionGroups' -or
                $TargetType -eq 'Microsoft.Insights/activityLogAlerts' -or
                $TargetType -eq 'Microsoft.Insights/alertRules' -or
                $TargetType -eq 'Microsoft.Insights/autoscaleSettings' -or
                $TargetType -eq 'Microsoft.Insights/components' -or
                $TargetType -eq 'Microsoft.Insights/dataCollectionEndpoints' -or
                $TargetType -eq 'Microsoft.Insights/dataCollectionRules' -or
                $TargetType -eq 'Microsoft.Insights/guestDiagnosticSettings' -or
                $TargetType -eq 'Microsoft.Insights/metricAlerts' -or
                $TargetType -eq 'Microsoft.Insights/notificationGroups' -or
                $TargetType -eq 'Microsoft.Insights/privateLinkScopes' -or
                $TargetType -eq 'Microsoft.Insights/scheduledQueryRules' -or
                $TargetType -eq 'Microsoft.Insights/webTests' -or
                $TargetType -eq 'Microsoft.Insights/workbooks' -or
                $TargetType -eq 'Microsoft.Insights/workbookTemplates'
            )) -or

            # Some exceptions to resources (https://learn.microsoft.com/azure/azure-resource-manager/management/tag-support#microsoftcostmanagement)
            ($TargetType -like 'Microsoft.CostManagement/*' -and !(
                $TargetType -eq 'Microsoft.CostManagement/Connectors'
            )) -or

            ($TargetType -like 'Microsoft.KubernetesConfiguration/*' -and !(
                $TargetType -eq 'Microsoft.KubernetesConfiguration/privateLinkScopes'
            )) -or

            ($TargetType -like 'Microsoft.ManagedIdentity/*' -and !(
                $TargetType -eq 'Microsoft.ManagedIdentity/userAssignedIdentities'
            )) -or

            ($TargetType -like 'Microsoft.Authorization/*' -and !(
                $TargetType -eq 'Microsoft.Authorization/resourceManagementPrivateLinks'
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
        $firewallRules = @($TargetObject);
        if ($TargetObject.type -notlike '*/firewallRules') {
            $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
                $_.type -like '*/firewallRules'
            } | ForEach-Object -Process {
                if (!($_.name -eq 'AllowAllWindowsAzureIps' -or
                ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0') -or
                ($_.properties.startIP -eq '0.0.0.0' -and $_.properties.endIP -eq '0.0.0.0'))) {
                    $_;
                }
            })
        }

        $private = 0;
        $public = 0;

        foreach ($fwRule in $firewallRules) {
            if ($fwRule.Properties.startIpAddress -like '10.*' -or $fwRule.properties.startIpAddress -like '172.*' -or $fwRule.properties.startIpAddress -like '192.168.*') {
                $private += GetIPAddressCount -Start $fwRule.properties.startIpAddress -End $fwRule.properties.endIpAddress;
            }
            elseif ($fwRule.properties.startIP -like '10.*' -or $fwRule.properties.startIP -like '172.*' -or $fwRule.properties.startIP -like '192.168.*') {
                $private += GetIPAddressCount -Start $fwRule.properties.startIP -End $fwRule.properties.endIP;
            }
            elseif (![String]::IsNullOrEmpty($fwRule.properties.startIP) -and ![String]::IsNullOrEmpty($fwRule.properties.endIP)) {
                $public += GetIPAddressCount -Start $fwRule.properties.startIP -End $fwRule.properties.endIP;
            }
            else {
                $public += GetIPAddressCount -Start $fwRule.properties.startIpAddress -End $fwRule.properties.endIpAddress;
            }
        }
        return [PSCustomObject]@{
            Private = $private
            Public  = $public
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
            $mask = [System.UInt64](4294967295 -shl (32 - ([System.Byte]::Parse($cidrParts[1])))) -band 4294967295;
        }
        return [PSCustomObject]@{
            Mask = $mask
            IP   = $ip;
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

# Normalizes the location for comparison.
function global:GetNormalLocation {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True)]
        [AllowEmptyString()]
        [String]$Location
    )
    process {
        return $Location.Replace(' ', '').ToLower();
    }
}

function global:GetAvailabilityZone {
    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Parameter(Mandatory = $True)]
        [AllowEmptyString()]
        [string]$Location,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject[]]$Zone
    )
    process {
        $normalizedLocation = GetNormalLocation -Location $Location;
        $availabilityZones = $Zone | Where-Object { (GetNormalLocation -Location $_.Location) -eq $normalizedLocation } | Select-Object -ExpandProperty Zones -First 1;
        return $availabilityZones | Sort-Object { [int]$_ };
    }
}

function global:PrependConfigurationZoneWithProviderZone {
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param (
        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject[]]$ConfigurationZone,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject[]]$ProviderZone
    )

    process {
        if ($ConfigurationZone.Length -gt 0) {

            # Prepend configuration options and provider mappings together
            # We put configuration options at the beginning so they are processed first
            return @($ConfigurationZone) + @($ProviderZone);
        }
        
        return $ProviderZone;
    }
}

function global:HasOMSOrAMAExtension {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.Compute/virtualMachines') {
            $extensions = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachines/extensions' |
                Where-Object { ($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -or ($_.Properties.publisher -eq 'Microsoft.Azure.Monitor') })
            
            $Assert.Greater($extensions, '.', 0).Result
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.Compute/virtualMachineScaleSets') {
            $property = $TargetObject.Properties.virtualMachineProfile.extensionProfile.extensions.properties |
                Where-Object { ($_.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -or ($_.publisher -eq 'Microsoft.Azure.Monitor') }
            $subresource = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachineScaleSets/extensions' |
                Where-Object { ($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -or ($_.Properties.publisher -eq 'Microsoft.Azure.Monitor') })

            $extensions = @($property; $subresource)
            $Assert.Greater($extensions, '.', 0).Result
        }
    }
}

function global:GetAzureSQLADOnlyAuthentication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ResourceType
    )
    process {
        if ($PSRule.TargetType -eq $ResourceType[0]) {
            $TargetObject.properties.administrators.azureADOnlyAuthentication
            GetSubResources -ResourceType $ResourceType[1] |
            ForEach-Object { $_.properties.azureADOnlyAuthentication }
        }
        else {
            $TargetObject.properties.azureADOnlyAuthentication
        }
    }
}
