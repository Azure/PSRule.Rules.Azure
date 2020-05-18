# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure subscriptions
#

#region RBAC

# Synopsis: Use groups for assigning permissions instead of individual user accounts
Rule 'Azure.RBAC.UseGroups' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.ObjectType -eq 'User'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 5).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Limit the number of subscription Owners
Rule 'Azure.RBAC.LimitOwner' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
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
Rule 'Azure.RBAC.LimitMGDelegation' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        ($_.Scope -like "/providers/Microsoft.Management/managementGroups/*")
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 3).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Avoid using classic co-administrator roles
Rule 'Azure.RBAC.CoAdministrator' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'CoAdministrator'
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

# Synopsis: Use RBAC assignments on resource groups instead of individual resources
Rule 'Azure.RBAC.UseRGDelegation' -Type 'Microsoft.Resources/resourceGroups' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.Scope -like "/subscriptions/*/resourceGroups/*/providers/*"
    })
    $Assert.
        LessOrEqual($assignments, 'Length', 0).
        WithReason(($LocalizedData.RoleAssignmentCount -f $assignments.Length), $True)
}

#endregion RBAC

#region Security Center

# Synopsis: Security Center email and phone contact details should be set
Rule 'Azure.SecurityCenter.Contact' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
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
Rule 'Azure.SecurityCenter.Provisioning' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
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
Rule 'Azure.Monitor.ServiceHealth' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $alerts = @(GetSubResources -ResourceType 'microsoft.insights/activityLogAlerts' | Where-Object {
        @($_.Properties.condition.allOf | Where-Object { $_.field -eq 'category' -and $_.equals -eq 'ServiceHealth' }).Length -gt 0
    });
    $Null -ne $alerts -and $alerts.Length -gt 0;
    foreach ($alert in $alerts) {
        $Assert.HasFieldValue($alert, 'Properties.enabled', $True);
    }
}

#endregion Monitor
