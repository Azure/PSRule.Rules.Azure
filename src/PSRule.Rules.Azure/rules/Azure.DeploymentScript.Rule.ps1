# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Deployment Scripts
#

# Synopsis: Deployment scripts should use a pinned URL to prevent supply chain attacks.
Rule 'Azure.DeploymentScript.Pinned' -Ref 'AZR-000536' -Type 'Microsoft.Resources/deploymentScripts' -Tag @{ release = 'GA'; ruleSet = '2026_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.WAF/maturity' = 'L2'; } {
    $pinnedPattern = '^https://raw\.githubusercontent\.com/[^/]+/[^/]+/[0-9a-f]{40}/';

    $uris = @();
    if ($Null -ne $TargetObject.properties.primaryScriptUri) {
        $uris += $TargetObject.properties.primaryScriptUri;
    }
    if ($Null -ne $TargetObject.properties.supportingScriptUris) {
        $uris += @($TargetObject.properties.supportingScriptUris);
    }

    $gitHubUris = @($uris | Where-Object { $_ -like 'https://raw.githubusercontent.com/*' });
    if ($gitHubUris.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($uri in $gitHubUris) {
        $Assert.Create($uri -match $pinnedPattern, $LocalizedData.GitHubRawScriptUnpinned, $uri);
    }
}
