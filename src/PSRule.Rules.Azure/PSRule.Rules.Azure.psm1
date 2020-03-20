# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# PSRule.Rules.Azure module
#

Set-StrictMode -Version latest;

[PSRule.Rules.Azure.Configuration.PSRuleOption]::UseExecutionContext($ExecutionContext);

#
# Localization
#

#
# Public functions
#

#region Public functions

# .ExternalHelp PSRule.Rules.Azure-help.xml
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
    begin {
        Write-Verbose -Message "[Export-AzRuleData] BEGIN::";
    }
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
        $filterParams = @{ };

        if ($PSBoundParameters.ContainsKey('Tag')) {
            $getParams['Tag'] = $Tag;
        }
        if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
            $getParams['ResourceGroupName'] = $ResourceGroupName;
            $filterParams['ResourceGroupName'] = $ResourceGroupName;
        }

        foreach ($c in $context) {
            Write-Verbose -Message "[Export] -- Using subscription: $($c.Subscription.Name)";
            $filePath = Join-Path -Path $OutputPath -ChildPath "$($c.Subscription.Id).json";
            GetAzureResource @getParams -Context $c -Verbose:$VerbosePreference `
            | FilterAzureResource @filterParams -Verbose:$VerbosePreference `
            | ExportAzureResource -Path $filePath -PassThru $PassThru -Verbose:$VerbosePreference;
        }
    }
    end {
        Write-Verbose -Message "[Export-AzRuleData] END::";
    }
}

# .ExternalHelp PSRule.Rules.Azure-help.xml
function Export-AzTemplateRuleData {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    [OutputType([PSObject])]
    param (
        [Parameter(Position = 0, Mandatory = $False)]
        [String]$Name,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$TemplateFile,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [Alias('TemplateParameterFile')]
        [String[]]$ParameterFile,

        [Parameter(Mandatory = $False)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory = $False)]
        [String]$Subscription,

        [Parameter(Mandatory = $False)]
        [String]$OutputPath = $PWD,

        [Parameter(Mandatory = $False)]
        [Switch]$PassThru = $False
    )
    begin {
        Write-Verbose -Message '[Export-AzTemplateRuleData] BEGIN::';

        $Option = [PSRule.Rules.Azure.Configuration.PSRuleOption]::new();
        $Option.Output.Path = $OutputPath;

        # Build the pipeline
        $builder = [PSRule.Rules.Azure.Pipeline.PipelineBuilder]::Template($Option);
        $builder.Deployment($Name);
        $builder.PassThru($PassThru);

        # Bind to subscription context
        if ($PSBoundParameters.ContainsKey('Subscription')) {
            $subscriptionObject = GetSubscription -Subscription $Subscription -ErrorAction SilentlyContinue;
            if ($Null -ne $subscriptionObject) {
                $builder.Subscription($subscriptionObject);
            }
        }
        # Bind to resource group
        if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
            $resourceGroupObject = GetResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue;
            if ($Null -ne $resourceGroupObject) {
                $builder.ResourceGroup($resourceGroupObject);
            }
        }

        $builder.UseCommandRuntime($PSCmdlet);
        $builder.UseExecutionContext($ExecutionContext);
        try {
            $pipeline = $builder.Build();
            $pipeline.Begin();
        }
        catch {
            $pipeline.Dispose();
        }
    }
    process {
        if ($Null -ne (Get-Variable -Name pipeline -ErrorAction SilentlyContinue)) {
            try {
                $source = [PSRule.Rules.Azure.Pipeline.TemplateSource]::new($TemplateFile, $ParameterFile);
                $pipeline.Process($source);
            }
            catch {
                $pipeline.Dispose();
                throw;
            }
        }
    }
    end {
        if ($Null -ne (Get-Variable -Name pipeline -ErrorAction SilentlyContinue)) {
            try {
                $pipeline.End();
            }
            finally {
                $pipeline.Dispose();
            }
        }
        Write-Verbose -Message '[Export-AzTemplateRuleData] END::';
    }
}

# .ExternalHelp PSRule.Rules.Azure-help.xml
function Get-AzRuleTemplateLink {
    [CmdletBinding()]
    [OutputType([PSRule.Rules.Azure.Data.Metadata.ITemplateLink])]
    param (
        [Parameter(Position = 1, Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [Alias('f', 'TemplateParameterFile', 'FullName')]
        [SupportsWildcards()]
        [String[]]$InputPath = '*.parameters.json',

        [Parameter(Mandatory = $False)]
        [Switch]$SkipUnlinked,

        [Parameter(Position = 0, Mandatory = $False)]
        [Alias('p')]
        [String]$Path = $PWD
    )
    begin {
        Write-Verbose -Message '[Get-AzRuleTemplateLink] BEGIN::';

        # Build the pipeline
        $builder = [PSRule.Rules.Azure.Pipeline.PipelineBuilder]::TemplateLink($Path);
        $builder.SkipUnlinked($SkipUnlinked);
        $builder.UseCommandRuntime($PSCmdlet);
        $builder.UseExecutionContext($ExecutionContext);
        $pipeline = $builder.Build();
        if ($Null -ne (Get-Variable -Name pipeline -ErrorAction SilentlyContinue)) {
            try {
                $pipeline.Begin();
            }
            catch {
                $pipeline.Dispose();
                throw;
            }
        }
    }
    process {
        if ($Null -ne (Get-Variable -Name pipeline -ErrorAction SilentlyContinue)) {
            try {
                foreach ($p in $InputPath) {
                    $pipeline.Process($p);
                }
            }
            catch {
                $pipeline.Dispose();
                throw;
            }
        }
    }
    end {
        if ($Null -ne (Get-Variable -Name pipeline -ErrorAction SilentlyContinue)) {
            try {
                $pipeline.End();
            }
            finally {
                $pipeline.Dispose();
            }
        }
        Write-Verbose -Message '[Get-AzRuleTemplateLink] END::';
    }
}

#endregion Public functions

#
# Helper functions
#

function GetResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Name
    )
    process {
        return Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue;
    }
}

function GetSubscription {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Subscription
    )
    process {
        return (Set-AzContext -Subscription $Subscription -ErrorAction SilentlyContinue).Subscription;
    }
}

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
        [Hashtable]$Tag,

        [Parameter(Mandatory = $False)]
        [String[]]$ResourceGroupName = $Null
    )
    begin {
        $watch = New-Object -TypeName System.Diagnostics.Stopwatch;
    }

    process {
        $resourceParams = @{ };
        $rgParams = @{ };

        if ($PSBoundParameters.ContainsKey('Tag')) {
            $resourceParams['Tag'] = $Tag;
            $rgParams['Tag'] = $Tag;
        }

        try {
            Write-Verbose -Message "[Export] -- Getting Azure resources";
            $watch.Restart();

            if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
                foreach ($rg in $ResourceGroupName) {
                    Write-Verbose -Message "[Export] -- Getting Azure resources for Resource Group: $rg";
                    Get-AzResource @resourceParams -ResourceGroupName $rg -ExpandProperties -ODataQuery "SubscriptionId EQ '$($Context.DefaultContext.Subscription.Id)'" -DefaultProfile $Context `
                        | ExpandResource -Context $Context -Verbose:$VerbosePreference;
                    Get-AzResourceGroup @rgParams -Name $rg -DefaultProfile $Context |
                        SetResourceType 'Microsoft.Resources/resourceGroups' |
                        ExpandResource -Context $Context -Verbose:$VerbosePreference;
                }
            }
            else {
                Get-AzResource @resourceParams -ExpandProperties -DefaultProfile $Context |
                    ExpandResource -Context $Context -Verbose:$VerbosePreference;
                Get-AzResourceGroup @rgParams -DefaultProfile $Context |
                    SetResourceType 'Microsoft.Resources/resourceGroups' |
                    ExpandResource -Context $Context -Verbose:$VerbosePreference;
            }

            Write-Verbose -Message "[Export] -- Azure resources exported in [$($watch.ElapsedMilliseconds) ms]";
            $watch.Restart();

            Write-Verbose -Message "[Export] -- Getting Azure subscription: $($Context.DefaultContext.Subscription.Id)";
            Get-AzSubscription -SubscriptionId $Context.DefaultContext.Subscription.Id |
                SetResourceType 'Microsoft.Subscription' |
                ExpandResource -Context $Context -Verbose:$VerbosePreference;

            Write-Verbose -Message "[Export] -- Azure subscription exported in [$($watch.ElapsedMilliseconds) ms]";
        }
        finally {
            $watch.Stop();
        }
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
        $watch = New-Object -TypeName System.Diagnostics.Stopwatch;
        Write-Verbose -Message "[Export] -- Exporting to JSON";
        $watch.Restart();

        if (!$PassThru) {
            # Save to JSON
            $resources | ConvertTo-Json -Depth 100 | Set-Content -Path $Path;
            Get-Item -Path $Path;
        }
        $watch.Stop();
        Write-Verbose -Message "[Export] -- Exported to JSON in [$($watch.ElapsedMilliseconds) ms]";
    }
}

function GetSubResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context,

        [Parameter(Mandatory = $True)]
        [String]$ResourceType,

        [Parameter(Mandatory = $True)]
        [String]$ApiVersion
    )
    process {
        $getParams = @{
            Name = $Resource.Name
            ResourceType = $ResourceType
            ResourceGroupName = $Resource.ResourceGroupName
            DefaultProfile = $Context
            ApiVersion = $ApiVersion
        }
        try {
            Get-AzResource @getParams -ExpandProperties;
        }
        catch {
            Write-Verbose -Message "Failed to read: $ResourceType";
        }
    }
}

function VisitAPIManagement {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $resources = @();
        $resources += GetSubResource @PSBoundParameters -ResourceType 'Microsoft.ApiManagement/service/apis' -ApiVersion '2019-01-01';
        $resources += GetSubResource @PSBoundParameters -ResourceType 'Microsoft.ApiManagement/service/backends' -ApiVersion '2019-01-01';
        $resources += GetSubResource @PSBoundParameters -ResourceType 'Microsoft.ApiManagement/service/properties' -ApiVersion '2019-01-01' | ForEach-Object {
            $_.properties.value = '*** MASKED ***';
            $_;
        }
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitSqlServer {
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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

function VisitSqlManagedInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $sqlMI = $resource;
        $resources = @();

        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/managedInstances/securityAlertPolicies' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-03-01-preview' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/managedInstances/vulnerabilityAssessments' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2018-06-01-preview' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Sql/managedInstances/administrators' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-03-01-preview' -ExpandProperties;
        $sqlMI | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitAutomationAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $aa = $Resource
        $resources = @();

        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Automation/AutomationAccounts/variables' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2015-10-31' -ExpandProperties;
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Automation/AutomationAccounts/webhooks' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2015-10-31' -ExpandProperties;
        $aa | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

# function VisitDataFactoryV2 {
#     param (
#         [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
#         [PSObject]$Resource,

#         [Parameter(Mandatory = $True)]
#         [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
#     )
#     process {
#         $df = $resource;
#         $resources = @();

#         # Get linked services
#         $resources += Get-AzDataFactoryV2LinkedService -DataFactoryName $resource.Name -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context | ForEach-Object -Process {
#             $linkedService = $_;
#             $type = $linkedService.Properties.GetType().Name;
#             $linkedService.Properties.AdditionalProperties = $Null;
#             if ($Null -ne $linkedService.Properties.EncryptedCredential) {
#                 $linkedService.Properties.EncryptedCredential = $Null;
#             }

#             $linkedService | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value 'linkedServices';
#             $linkedService | Add-Member -MemberType NoteProperty -Name 'Type' -Value $type;
#             $linkedService;
#         };
#         $df | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
#     }
# }

function VisitStorageAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $resources = @();
        $resources += Get-AzResource -Name $Resource.Name -ResourceType 'Microsoft.Storage/storageAccounts/blobServices' -ResourceGroupName $Resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2019-04-01' -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitStorageSyncService {
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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

function VisitKeyVault {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $resources = @();
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.KeyVault/vaults/providers/microsoft.insights/diagnosticSettings' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-05-01-preview' -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        # Patch Front Door properties not fully returned from the default API version
        $Resource = Get-AzResource -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ResourceType 'Microsoft.Network/frontdoors' -ExpandProperties -ApiVersion '2018-08-01';

        $resources = @();
        $resources += Get-AzResource -Name $resource.Name -ResourceType 'Microsoft.Network/frontdoors/providers/microsoft.insights/diagnosticSettings' -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ApiVersion '2017-05-01-preview' -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitFrontDoorWAFPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        # Patch Front Door WAF policy properties not fully returned from the default API version
        $Resource = Get-AzResource -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName -DefaultProfile $Context -ResourceType 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies' -ExpandProperties -ApiVersion '2019-10-01';
        $Resource;
    }
}

function VisitSubscription {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $resources = @();
        $resources += Get-AzRoleAssignment -DefaultProfile $Context -IncludeClassicAdministrators | SetResourceType 'Microsoft.Authorization/roleAssignments';
        $resources += Get-AzResource -DefaultProfile $Context -ResourceId "/subscriptions/$($Resource.Id)/providers/Microsoft.Security/autoProvisioningSettings";
        $resources += Get-AzResource -DefaultProfile $Context -ResourceId "/subscriptions/$($Resource.Id)/providers/Microsoft.Security/securityContacts";
        $resources += Get-AzResource -DefaultProfile $Context -ApiVersion '2018-06-01' -ResourceId "/subscriptions/$($Resource.Id)/providers/Microsoft.Security/pricings";
        $resources += Get-AzResource -ResourceType 'microsoft.insights/activityLogAlerts' -DefaultProfile $Context -ExpandProperties;
        $Resource | Add-Member -MemberType NoteProperty -Name resources -Value $resources -PassThru;
    }
}

function VisitResourceGroup {
    [CmdletBinding()]
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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$Context
    )
    process {
        $resourceId = '';
        if ($Resource.ResourceType -eq 'Microsoft.Subscription') {
            $resourceId = $Resource.Id;
        }
        else {
            $resourceId = $Resource.ResourceId;
        }
        Write-Verbose -Message "[Export] -- Expanding: $($Resource.Id)";
        switch ($Resource.ResourceType) {
            'Microsoft.ApiManagement/service' { VisitAPIManagement @PSBoundParameters; }
            'Microsoft.Automation/automationAccounts' { VisitAutomationAccount @PSBoundParameters; }
            'Microsoft.Sql/servers' { VisitSqlServer @PSBoundParameters; }
            'Microsoft.DBforPostgreSQL/servers' { VisitPostgreSqlServer @PSBoundParameters; }
            'Microsoft.DBforMySQL/servers' { VisitMySqlServer @PSBoundParameters; }
            # 'Microsoft.Sql/managedInstances' { VisitSqlManagedInstance @PSBoundParameters; }
            # 'Microsoft.DataFactory/factories' { VisitDataFactoryV2 @PSBoundParameters; }
            'Microsoft.Storage/storageAccounts' { VisitStorageAccount @PSBoundParameters; }
            # "Microsoft.StorageSync/storageSyncServices" { VisitStorageSyncService @PSBoundParameters; }
            'Microsoft.Web/sites' { VisitWebApp @PSBoundParameters; }
            'Microsoft.Web/sites/slots' { VisitWebApp @PSBoundParameters; }
            'Microsoft.RecoveryServices/vaults' { VisitRecoveryServices @PSBoundParameters; }
            'Microsoft.Compute/virtualMachines' { VisitVirtualMachine @PSBoundParameters; }
            'Microsoft.KeyVault/vaults' { VisitKeyVault @PSBoundParameters; }
            'Microsoft.Network/frontDoors' { VisitFrontDoor @PSBoundParameters; }
            'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies' { VisitFrontDoorWAFPolicy @PSBoundParameters; }
            'Microsoft.Subscription' { VisitSubscription @PSBoundParameters; }
            'Microsoft.Resources/resourceGroups' { VisitResourceGroup @PSBoundParameters; }
            default { $Resource; }
        }
    }
}

function SetResourceType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True, Position = 0)]
        [String]$ResourceType
    )
    process {
        if ($ResourceType -eq 'Microsoft.Resources/resourceGroups') {
            $Resource = $Resource | Add-Member -MemberType NoteProperty -Name Id -Value $Resource.ResourceId -PassThru -Force;
        }
        $Resource | Add-Member -MemberType NoteProperty -Name ResourceType -Value $ResourceType -PassThru -Force;
    }
}

#
# Export module
#

Export-ModuleMember -Function @(
    'Export-AzRuleData'
    'Export-AzTemplateRuleData'
    'Get-AzRuleTemplateLink'
);
