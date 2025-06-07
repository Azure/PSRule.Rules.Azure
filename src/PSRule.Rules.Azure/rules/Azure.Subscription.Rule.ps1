# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure subscriptions
#

#region RBAC

# Synopsis: Use groups for assigning permissions instead of individual user accounts
Rule 'Azure.RBAC.UseGroups' -Ref 'AZR-000203' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.ObjectType -eq 'User'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 5).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Limit the number of subscription Owners
Rule 'Azure.RBAC.LimitOwner' -Ref 'AZR-000204' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'Owner' -and
        ($_.Scope -like "/subscriptions/*" -or "/providers/Microsoft.Management/managementGroups/*") -and
        $_.Scope -notlike "/subscriptions/*/resourceGroups/*"
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 3).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Limit RBAC inheritance from Management Groups
Rule 'Azure.RBAC.LimitMGDelegation' -Ref 'AZR-000205' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        ($_.Scope -like "/providers/Microsoft.Management/managementGroups/*")
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 3).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Avoid using classic co-administrator roles
Rule 'Azure.RBAC.CoAdministrator' -Ref 'AZR-000206' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'CoAdministrator'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Use RBAC assignments on resource groups instead of individual resources
Rule 'Azure.RBAC.UseRGDelegation' -Ref 'AZR-000207' -Type 'Microsoft.Resources/resourceGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.Scope -like "/subscriptions/*/resourceGroups/*/providers/*"
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Use JiT role activation with PIM
Rule 'Azure.RBAC.PIM' -Ref 'AZR-000208' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PA-7' } {
    # Get PIM assignment
    $assignments = @(GetSubResources -ResourceType 'Microsoft.Authorization/roleAssignments' | Where-Object {
        $_.DisplayName -eq 'MS-PIM' -and $_.ObjectType -eq 'ServicePrincipal'
    })
    $Assert.
        HasFieldValue($assignments, 'Length', 1).
        WithReason($LocalizedData.UnmanagedSubscription, $True)
}

# Synopsis: Subscriptions without a standard tagging convention may be difficult to identify and manage.
Rule 'Azure.Subscription.RequiredTags' -Ref 'AZR-000479' -Type 'Microsoft.Subscription/aliases' -If { $Configuration.GetStringValues('AZURE_SUBSCRIPTION_REQUIRED_TAGS').Length -gt 0 } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
    $required = $Configuration.GetStringValues('AZURE_SUBSCRIPTION_REQUIRED_TAGS')
    if ($required.Length -eq 0) {
        return $Assert.Pass();
    }

    # Check that the tag exists.
    if (!$Assert.HasField($PSRule.TargetObject, 'properties.additionalProperties.tags', $False).Result) {
        return $Assert.Fail($LocalizedData.ResourceHasNoTags, [String]::Join(', ', $required)).PathPrefix('properties.additionalProperties.tags');
    }
    $Assert.HasFields($PSRule.TargetObject.properties.additionalProperties.tags, $required, $True);

    # Check for required name format.
    foreach ($tagName in $required) {
        $requiredValueFormat = $Configuration.GetValueOrDefault("AZURE_TAG_FORMAT_FOR_$($tagName.ToUpper())", $Null)
        if (![String]::IsNullOrWhiteSpace($requiredValueFormat)) {
            $Assert.Match($PSRule.TargetObject, "properties.additionalProperties.tags.$tagName", $requiredValueFormat, $True);
        }
    }
}

#endregion RBAC

#region Monitor

# Synopsis: Configure Azure service logs
Rule 'Azure.Monitor.ServiceHealth' -Ref 'AZR-000211' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $alerts = @(GetSubResources -ResourceType 'microsoft.insights/activityLogAlerts' | Where-Object {
        @($_.Properties.condition.allOf | Where-Object { $_.field -eq 'category' -and $_.equals -eq 'ServiceHealth' }).Length -gt 0
    });
    $Null -ne $alerts -and $alerts.Length -gt 0;
    foreach ($alert in $alerts) {
        $Assert.HasFieldValue($alert, 'Properties.enabled', $True);
    }
}

#endregion Monitor

#region Security

# Synopsis: Alerts that have not received a response may indicate a security issue that requires attention.
Rule 'Azure.DefenderCloud.ActiveAlerts' -Ref 'AZR-000489' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $alerts = @(GetSubResources -ResourceType 'Microsoft.Security/Locations/alerts' | Where-Object {
        $_.properties.status -eq 'Active' -and
        $_.properties.severity -in @('High', 'Medium')
    })
    $Assert.LessOrEqual($alerts, '.', 0).Reason($LocalizedData.ActiveSecurityAlerts, $alerts.Length);

    # Use up to 5 alerts as reasons for failure.
    for ($i = 0; $i -lt $alerts.Length -and $i -lt 5; $i++) {
        $alert = $alerts[$i];
        $Assert.Fail($alert.properties.alertDisplayName);
    }
}

#endregion Security
