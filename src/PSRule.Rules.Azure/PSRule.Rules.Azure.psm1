#
# PSRule.Rules.Azure module
#

Set-StrictMode -Version latest;

# Set up some helper variables to make it easier to work with the module
# $PSModule = $ExecutionContext.SessionState.Module;
# $PSModuleRoot = $PSModule.ModuleBase;

#
# Localization
#

#
# Public functions
#

#region Public functions

# .ExternalHelp PSRule.Rules.Azure-Help.xml
function Export-AzRuleData {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Position = 0, Mandatory = $False)]
        [String]$OutputPath = $PWD,

        [Parameter(Mandatory = $False)]
        [String[]]$Subscription,

        [Parameter(Mandatory = $False)]
        [String[]]$Tenant
    )

    process {

        # Get subscriptions
        $context = FindAzureContext -Subscription $Subscription -Tenant $Tenant -Verbose:$VerbosePreference;

        if ($Null -eq $context) {
            return;
        }

        if (!(Test-Path -Path $OutputPath)) {
            $Null = New-Item -Path $OutputPath -ItemType Directory -Force;
        }

        foreach ($c in $context) {
            $filePath = Join-Path -Path $OutputPath -ChildPath "$($c.Subscription.Id).json";
            GetAzureResource -Context $c -Verbose:$VerbosePreference | ExportAzureResource -Path $filePath -Verbose:$VerbosePreference
        }
    }
}

#endregion Public functions

#
# Helper functions
#

function FindAzureContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$Subscription = $Null,

        [Parameter(Mandatory = $False)]
        [String[]]$Tenant = $Null
    )

    process {
        # Get subscription contexts
        $context = GetAzureContext;

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
    param ( )
    process {
        # Get contexts
        return Get-AzContext -ListAvailable;
    }
}

function GetAzureResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )

    process {
        Get-AzResource -ExpandProperties -DefaultProfile $Context | ExpandResource -Context $Context -Verbose:$VerbosePreference;
        Get-AzSubscription -SubscriptionId $Context.DefaultContext.Subscription.Id | SetResourceType 'Microsoft.Subscription' | ExpandResource -Context $Context -Verbose:$VerbosePreference;
    }
}

function ExportAzureResource {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
        [PSObject]$InputObject
    )

    process {
        $InputObject | ConvertTo-Json -Depth 100 | Set-Content -Path $Path;
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
        $resources += Get-AzSqlServerFirewallRule -ServerName $resource.Name -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context | Add-Member -MemberType NoteProperty -Name 'type' -Value 'firewallRules' -PassThru;
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

        $resources += Get-AzWebApp -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.Name -DefaultProfile $Context;
        $resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
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

        $vault = Get-AzRecoveryServicesVault -Name $Resource.Name -ResourceGroupName $Resource.ResourceGroupName -DefaultProfile $Context;
        $Null = Set-AzRecoveryServicesVaultContext -Vault $vault -DefaultProfile $Context;
        $Null = Set-AzRecoveryServicesAsrVaultContext -Vault $vault -DefaultProfile $Context;
        $resources += Get-AzRecoveryServicesAsrAlertSetting | SetResourceType -ResourceType 'Microsoft.RecoveryServices/vaults/replicationAlertSettings';
        $resources += Get-AzRecoveryServicesBackupProperty -Vault $vault -DefaultProfile $Context | SetResourceType -ResourceType 'Microsoft.RecoveryServices/vaults/backupProperty';

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
            "Microsoft.Sql/servers" { VisitSqlServer @PSBoundParameters; }
            "Microsoft.DataFactory/factories" { VisitDataFactoryV2 @PSBoundParameters; }
            # "Microsoft.Storage/storageAccounts" { VisitStorageAccount @PSBoundParameters; }
            "Microsoft.StorageSync/storageSyncServices" { VisitStorageSyncService @PSBoundParameters; }
            # "Microsoft.Web/sites" { VisitWebApp @PSBoundParameters; }
            "Microsoft.RecoveryServices/vaults" { VisitRecoveryServices @PSBoundParameters; }
            "Microsoft.Compute/virtualMachines" { VisitVirtualMachine @PSBoundParameters; }
            "Microsoft.Subscription" { VisitSubscription @PSBoundParameters; }
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
