# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure subscriptions
#

#region RBAC

# Synopsis: Use groups for assigning permissions instead of individual user accounts
Rule 'Azure.RBAC.UseGroups' -Ref 'AZR-000203' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.ObjectType -eq 'User'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 5).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Limit the number of subscription Owners
Rule 'Azure.RBAC.LimitOwner' -Ref 'AZR-000204' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
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
Rule 'Azure.RBAC.LimitMGDelegation' -Ref 'AZR-000205' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        ($_.Scope -like "/providers/Microsoft.Management/managementGroups/*")
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 3).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Avoid using classic co-administrator roles
Rule 'Azure.RBAC.CoAdministrator' -Ref 'AZR-000206' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'CoAdministrator'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Use RBAC assignments on resource groups instead of individual resources
Rule 'Azure.RBAC.UseRGDelegation' -Ref 'AZR-000207' -Type 'Microsoft.Resources/resourceGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.Scope -like "/subscriptions/*/resourceGroups/*/providers/*"
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Use JiT role activation with PIM
Rule 'Azure.RBAC.PIM' -Ref 'AZR-000208' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    # Get PIM assignment
    $assignments = @(GetSubResources -ResourceType 'Microsoft.Authorization/roleAssignments' | Where-Object {
        $_.DisplayName -eq 'MS-PIM' -and $_.ObjectType -eq 'ServicePrincipal'
    })
    $Assert.
        HasFieldValue($assignments, 'Length', 1).
        WithReason($LocalizedData.UnmanagedSubscription, $True)
}

#endregion RBAC

#region Security Center

# Synopsis: Security Center email and phone contact details should be set
Rule 'Azure.SecurityCenter.Contact' -Ref 'AZR-000209' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.SecurityCenterNotConfigured;
    $contacts = @(GetSubResources -ResourceType 'Microsoft.Security/securityContacts');
    $Null -ne $contacts -and $contacts.Length -gt 0;
    foreach ($c in $contacts) {
        $Assert.HasFieldValue($c, 'Properties.Email')
        $Assert.HasFieldValue($c, 'Properties.Phone');
    }
}

# TODO: Check Security Center recommendations

# Synopsis: Enable auto-provisioning on VMs to improve Azure Security Center insights
Rule 'Azure.SecurityCenter.Provisioning' -Ref 'AZR-000210' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $provisioning = @(GetSubResources -ResourceType 'Microsoft.Security/autoProvisioningSettings');
    $Null -ne $provisioning -and $provisioning.Length -gt 0;
    foreach ($s in $provisioning) {
        $Assert.HasFieldValue($s, 'Properties.autoProvision', 'On');
    }
}

#endregion Security Center

# TODO: Use policy
# TODO: Use resource locks

#region Monitor

# Synopsis: Configure Azure service logs
Rule 'Azure.Monitor.ServiceHealth' -Ref 'AZR-000211' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $alerts = @(GetSubResources -ResourceType 'microsoft.insights/activityLogAlerts' | Where-Object {
        @($_.Properties.condition.allOf | Where-Object { $_.field -eq 'category' -and $_.equals -eq 'ServiceHealth' }).Length -gt 0
    });
    $Null -ne $alerts -and $alerts.Length -gt 0;
    foreach ($alert in $alerts) {
        $Assert.HasFieldValue($alert, 'Properties.enabled', $True);
    }
}

#endregion Monitor
