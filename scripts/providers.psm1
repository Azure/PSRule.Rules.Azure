# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# Handles Azure resource provider updates.

function Update-Providers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$Path = (Join-Path -Path $PWD -ChildPath 'data')
    )
    begin {
        $providerPath = Join-Path -Path $Path -ChildPath ("./providers/");
        if (Test-Path -Path $providerPath) {
            $Null = Remove-Item -Path $providerPath -Force -Recurse;
        }
    }
    process {
        $subscriptionId = (Get-AzContext).Subscription.Id
        $providers = @(((Invoke-AzRest -Method Get -Path "/subscriptions/$subscriptionId/providers?api-version=2021-04-01&`$expand=resourceTypes/zoneMappings").Content | ConvertFrom-Json).value | Sort-Object -Property namespace -CaseSensitive);
        $aliasIndex = [ordered]@{};

        Get-AzPolicyAlias | Sort-Object -Property Namespace, ResourceType | ForEach-Object {
            $namespace = $_.Namespace.ToLower();

            if (!($aliasIndex.Contains($namespace))) {
                $aliasIndex.Add($namespace, [ordered]@{});
            }

            $aliasMappings = [ordered]@{};
            $_.Aliases | Sort-Object -Property Name | ForEach-Object {
                $aliasMappings.Add($_.Name, $_.DefaultPath);
            }

            $aliasIndex[$namespace].Add($_.ResourceType.ToLower(), $aliasMappings);
        }

        foreach ($provider in $providers) {
            if ($provider.namespace -notlike "microsoft.*") {
                continue;
            }

            $namespace = $provider.namespace.ToLower();

            $providerPath = Join-Path -Path $Path -ChildPath ("./providers/" + $namespace);
            if (!(Test-Path -Path $providerPath)) {
                $Null = New-Item -Path $providerPath -ItemType Directory -Force;
            }

            $types = @()
            $processed = [System.Collections.Generic.HashSet[string]]::new()

            $provider.resourceTypes | Sort-Object -Property resourceType | ForEach-Object {
                $a = $null
                if ($aliasIndex.contains($namespace) -and $aliasIndex[$namespace].Contains($_.resourceType.ToLower())) {
                    $a = $aliasIndex[$namespace][$_.resourceType.ToLower()]
                }

                $type = [ordered]@{
                    aliases      = $a
                    resourceType = $_.resourceType
                    apiVersions  = $_.apiVersions
                    locations    = @($_.locations | Where-Object { $_ -notlike "MSFT *" -and $_ -notlike "* (Stage)" } | Sort-Object)
                    zoneMappings = @($_.ZoneMappings | Sort-Object -Property location | ForEach-Object {
                            $zones = $_.zones
                            if ($Null -ne $zones) {
                                $zones = @($_.zones | Sort-Object)
                            }
                            [ordered]@{
                                location = $_.location
                                zones    = $zones
                            }
                        })
                }
                $types += $type;
                $Null = $processed.Add($_.resourceType.ToLower());
            }

            # Catch aliases that don't match a resource type
            if ($aliasIndex.contains($namespace)) {
                $aliasIndex[$namespace].GetEnumerator() | Where-Object { !$processed.Contains($_.Key.ToLower()) } | ForEach-Object {
                    $type = [ordered]@{
                        aliases      = $aliasIndex[$namespace][$_.Key.ToLower()]
                        resourceType = $_.Key
                    }
                    $types += $type;
                }
            }

            ConvertTo-Json -Depth 5 -InputObject $types | Set-Content -Path (Join-Path -Path $providerPath -ChildPath "types.json") -Encoding utf8 -Force;
        }
    }
}

function Update-Locations {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$Path = (Join-Path -Path $PWD -ChildPath 'data')
    )
    process {
        $subscriptionId = (Get-AzContext).Subscription.Id
        $raw = @(((Invoke-AzRest -Method Get -Path "/subscriptions/$subscriptionId/locations?api-version=2022-12-01").Content | ConvertFrom-Json).value | Sort-Object -Property namespace -CaseSensitive);

        $locationIndex = [ordered]@{};
        foreach ($rawLocation in ($raw | Where-Object { $_.displayName -notlike "MSFT *" -and $_.displayName -notlike "* (Stage)" -and $_.metadata.regionType -ne 'Logical' } | Sort-Object -Property name)) {
            $name = $rawLocation.name.ToLower();
            $physicalZones = 0
            if ($Null -ne $rawLocation.availabilityZoneMappings) {
                $physicalZones = @($rawLocation.availabilityZoneMappings).Length;
            }

            # Ignore locations that don't have any zones.
            if ($physicalZones -eq 0) {
                continue;
            }

            $location = [ordered]@{
                zones = $physicalZones
            }
            $locationIndex.Add($name, $location);
        }

        ConvertTo-Json -Depth 5 -InputObject $locationIndex | Set-Content -Path (Join-Path -Path $Path -ChildPath "locations.json") -Encoding utf8 -Force;
    }
}

Export-ModuleMember -Function @(
    'Update-Providers'
    'Update-Locations'
)
