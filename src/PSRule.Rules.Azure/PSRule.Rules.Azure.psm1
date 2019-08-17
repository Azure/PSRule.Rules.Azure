#
# PSRule.Rules.Azure module
#

Set-StrictMode -Version latest;

#
# Localization
#

#
# Public functions
#

#region Public functions

# .ExternalHelp PSRule.Rules.Azure-Help.xml
function Export-AzRuleData {
    [CmdletBinding(SupportsShouldProcess = $True, DefaultParameterSetName = 'Default')]
    [OutputType([System.IO.FileInfo])]
    [OutputType([PSObject])]
    param (
        [Parameter(Position = 0, Mandatory = $False)]
        [String]$OutputPath = $PWD,

        # Filter by Subscription name or id
        [Parameter(Mandatory = $False, ParameterSetName = 'Default')]
        [String[]]$Subscription = $Null,

        # Filter by Tenant id
        [Parameter(Mandatory = $False, ParameterSetName = 'Default')]
        [String[]]$Tenant = $Null,

        # Filter by Resource Group name
        [Parameter(Mandatory = $False)]
        [String[]]$ResourceGroupName = $Null,

        # Filter by Tag
        [Parameter(Mandatory = $False)]
        [Hashtable]$Tag,

        [Parameter(Mandatory = $False)]
        [Switch]$PassThru = $False,

        [Parameter(Mandatory = $False, ParameterSetName = 'All')]
        [Switch]$All = $False
    )

    process {
        # Get subscriptions
        $context = FindAzureContext -Subscription $Subscription -Tenant $Tenant -All:$All -Verbose:$VerbosePreference;

        if ($Null -eq $context) {
            return;
        }

        if (!(Test-Path -Path $OutputPath)) {
            if ($PSCmdlet.ShouldProcess('Create output directory', $OutputPath)) {
                $Null = New-Item -Path $OutputPath -ItemType Directory -Force;
            }
        }

        $getParams = @{ };
        $filterParams = @{};

        if ($PSBoundParameters.ContainsKey('Tag')) {
            $getParams['Tag'] = $Tag;
        }

        if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
            $filterParams['ResourceGroupName'] = $ResourceGroupName;
        }

        foreach ($c in $context) {
            $filePath = Join-Path -Path $OutputPath -ChildPath "$($c.Subscription.Id).json";
            GetAzureResource @getParams -Context $c -Verbose:$VerbosePreference `
                | FilterAzureResource @filterParams -Verbose:$VerbosePreference `
                | ExportAzureResource -Path $filePath -PassThru $PassThru -Verbose:$VerbosePreference;
        }
    }
}

#endregion Public functions

#
# Helper functions
#

function FindAzureContext {
    [CmdletBinding()]
    [OutputType([Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer[]])]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$Subscription = $Null,

        [Parameter(Mandatory = $False)]
        [String[]]$Tenant = $Null,

        [Parameter(Mandatory = $False)]
        [System.Boolean]$All = $False
    )

    process {
        $listAvailable = $False;

        if ($Null -ne $Subscription -or $Null -ne $Tenant -or $All) {
            $listAvailable = $True;
        }

        # Get subscription contexts
        $context = GetAzureContext -ListAvailable:$listAvailable;

        if ($Null -eq $context) {
            Write-Error -Message "Could not find an existing context. Use Connect-AzAccount to establish a PowerShell context with Azure.";
            return;
        }

        $filteredContext = $context | Where-Object -FilterScript {
            ($Null -eq $Tenant -or $Tenant.Length -eq 0 -or ($_.Tenant.Id -in $Tenant)) -and
            ($Null -eq $Subscription -or $Subscription.Length -eq 0 -or ($_.Subscription.Id -in $Subscription) -or ($_.Subscription.Name -in $Subscription))
        }

        return $filteredContext;
    }
}

function GetAzureContext {
    [CmdletBinding()]
    [OutputType([Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer[]])]
    param (
        [Parameter(Mandatory = $False)]
        [System.Boolean]$ListAvailable = $False
    )
    process {
        $getParams = @{ };

        if ($ListAvailable) {
            $getParams['ListAvailable'] = $True;
        }

        # Get contexts
        return Get-AzContext @getParams;
    }
}

function GetAzureResource {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context,

        [Parameter(Mandatory = $False)]
        [Hashtable]$Tag
    )

    process {
        $getParams = @{ };

        if ($PSBoundParameters.ContainsKey('Tag')) {
            $getParams['Tag'] = $Tag;
        }

        Get-AzResource @getParams -ExpandProperties -DefaultProfile $Context `
            | ExpandResource -Context $Context -Verbose:$VerbosePreference;
        Get-AzResourceGroup @getParams -DefaultProfile $Context `
            | SetResourceType 'Microsoft.Resources/resourceGroups' | ExpandResource -Context $Context -Verbose:$VerbosePreference;
        Get-AzSubscription -SubscriptionId $Context.DefaultContext.Subscription.Id `
            | SetResourceType 'Microsoft.Subscription' | ExpandResource -Context $Context -Verbose:$VerbosePreference;
    }
}

function FilterAzureResource {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$ResourceGroupName = $Null,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$InputObject
    )

    process {
        if (($Null -eq $ResourceGroupName) -or ($InputObject.ResourceType -eq 'Microsoft.Subscription') -or ($InputObject.ResourceGroupName -in $ResourceGroupName)) {
            return $InputObject;
        }
    }
}

function ExportAzureResource {
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([System.IO.FileInfo])]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$InputObject,

        [Parameter(Mandatory = $False)]
        [System.Boolean]$PassThru = $False
    )

    begin {
        $resources = @();
    }

    process {
        if ($PassThru) {
            $InputObject;
        }
        else {
            # Collect passed through resources
            $resources += $InputObject;
        }
    }

    end {
        if (!$PassThru) {
            # Save to JSON
            $resources | ConvertTo-Json -Depth 100 | Set-Content -Path $Path;
            Get-Item -Path $Path;
        }
    }
}

function VisitSqlServer {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $sqlServer = $resource;
        $resources = @();

        # Get SQL Server firewall rules
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/servers/firewallRules' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2015-05-01-preview' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/servers/securityAlertPolicies' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-03-01-preview' -ExpandProperties;
        # $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/servers/vulnerabilityAssessments' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-06-01-preview' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/servers/auditingSettings' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-03-01-preview' -ExpandProperties;
        $sqlServer | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}


function VisitPostgreSqlServer {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $sqlServer = $resource;
        $resources = @();

        # Get Postgre SQL Server firewall rules
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-12-01' -ExpandProperties;
        $sqlServer | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitMySqlServer {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $sqlServer = $resource;
        $resources = @();

        # Get MySQL Server firewall rules
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.DBforMySQL/servers/firewallRules' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-12-01' -ExpandProperties;
        $sqlServer | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitDataFactoryV2 {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $df = $resource;
        $resources = @();

        # Get linked services
        $resources += Get-AzDataFactoryV2LinkedService -DataFactoryName $resource.Name -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context | ForEach-Object -Process {
            $linkedService = $_;
            $type = $linkedService.Properties.GetType().Name;
            $linkedService.Properties.AdditionalProperties = $Null;
            if ($Null -ne $linkedService.Properties.EncryptedCredential) {
                $linkedService.Properties.EncryptedCredential = $Null;
            }

            $linkedService | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value 'linkedServices';
            $linkedService | Add-Member -MemberType NoteProperty -Name 'Type' -Value $type;
            $linkedService;
        };
        $df | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitStorageAccount {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();

        $resources += Get-AzStorageAccount -Name $Resource.Name -ResourceGroupName $Resource.ResourceGroupName -DefaultProfile $Context | Get-AzStorageServiceProperty -ServiceType Blob | ForEach-Object -Process {
            $serviceProperties = $_;
            $type = $serviceProperties.GetType().Name;

            $serviceProperties | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value 'serviceProperties';
            $serviceProperties | Add-Member -MemberType NoteProperty -Name 'Type' -Value $type;
            $serviceProperties;
        };

        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitStorageSyncService {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();
        $resources += Get-AzStorageSyncServer -ParentResourceId $Resource.ResourceId -DefaultProfile $Context;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitWebApp {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();
        $configResourceType = 'Microsoft.Web/sites/config';

        # Handle slots
        if ($Resource.ResourceType -eq 'Microsoft.Web/sites/slots') {
            $configResourceType = 'Microsoft.Web/sites/slots/config';
        }

        $resources += Get-AzResource -Name $Resource.Name -ResourceType $configResourceType -ResourceGroupName $Resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-11-01' -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitRecoveryServices {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();

        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.RecoveryServices/vaults/replicationRecoveryPlans' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-07-10' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.RecoveryServices/vaults/replicationAlertSettings' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-07-10' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.RecoveryServices/vaults/backupstorageconfig/vaultstorageconfig' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-07-10' -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitVirtualMachine {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();

        $networkInterfaceId = $Resource.Properties.networkProfile.networkInterfaces.id;
        foreach ($id in $networkInterfaceId) {
            $resources += Get-AzResource -ResourceId $id -ExpandProperties -DefaultProfile $Context;
        }
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitSubscription {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();
        $resources += Get-AzRoleAssignment -DefaultProfile $Context | SetResourceType 'Microsoft.Authorization/roleAssignments';
        $resources += Get-AzSecurityAutoProvisioningSetting -DefaultProfile $Context | SetResourceType 'Microsoft.Security/autoProvisioningSettings';
        $resources += Get-AzSecurityContact -DefaultProfile $Context | SetResourceType 'Microsoft.Security/securityContacts';
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitResourceGroup {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        $resources = @();
        $resources += Get-AzRoleAssignment -DefaultProfile $Context -Scope $Resource.ResourceId `
            | Where-Object { $_.Scope.StartsWith($Resource.ResourceId) } `
            | SetResourceType 'Microsoft.Authorization/roleAssignments';
        $resources += Get-AzResourceLock -DefaultProfile $Context -ResourceGroupName $Resource.ResourceGroupName | SetResourceType 'Microsoft.Authorization/locks';
        $Resource `
            | Add-Member -MemberType NoteProperty -Name Name -Value $Resource.ResourceGroupName -PassThru `
            | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

# Add additional information to resources with child resources
function ExpandResource {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        switch ($Resource.ResourceType) {
            'Microsoft.Sql/servers' { VisitSqlServer @PSBoundParameters; }
            'Microsoft.DBforPostgreSQL/servers' { VisitPostgreSqlServer @PSBoundParameters; }
            'Microsoft.DBforMySQL/servers' { VisitMySqlServer @PSBoundParameters; }
            'Microsoft.DataFactory/factories' { VisitDataFactoryV2 @PSBoundParameters; }
            # "Microsoft.Storage/storageAccounts" { VisitStorageAccount @PSBoundParameters; }
            # "Microsoft.StorageSync/storageSyncServices" { VisitStorageSyncService @PSBoundParameters; }
            'Microsoft.Web/sites' { VisitWebApp @PSBoundParameters; }
            'Microsoft.Web/sites/slots' { VisitWebApp @PSBoundParameters; }
            'Microsoft.RecoveryServices/vaults' { VisitRecoveryServices @PSBoundParameters; }
            'Microsoft.Compute/virtualMachines' { VisitVirtualMachine @PSBoundParameters; }
            'Microsoft.Subscription' { VisitSubscription @PSBoundParameters; }
            'Microsoft.Resources/resourceGroups' { VisitResourceGroup @PSBoundParameters; }
            default { $Resource; }
        }
    }
}

function SetResourceType {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True, Position = 0)]
        [String]$ResourceType
    )

    process {
        $Resource | Add-Member -MemberType NoteProperty -Name ResourceType -Value $ResourceType -PassThru -Force;
    }
}

#
# Export module
#

Export-ModuleMember -Function 'Export-AzRuleData';
