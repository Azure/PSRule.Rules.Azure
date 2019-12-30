#
# Validation rules for Azure subscriptions
#

#region RBAC

# Synopsis: Use groups for assigning permissions instead of individual user accounts
Rule 'Azure.RBAC.UseGroups' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $userAssignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.ObjectType -eq 'User'
    })
    $userAssignments.Length -le 5
}

# Synopsis: Limit the number of subscription Owners
Rule 'Azure.RBAC.LimitOwner' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'Owner' -and
        ($_.Scope -like "/subscriptions/*" -or "/providers/Microsoft.Management/managementGroups/*") -and
        $_.Scope -notlike "/subscriptions/*/resourceGroups/*"
    })
    $assignments.Length -le 3
}

# Synopsis: Limit RBAC inheritance from Management Groups
Rule 'Azure.RBAC.LimitMGDelegation' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        ($_.Scope -like "/providers/Microsoft.Management/managementGroups/*")
    })
    $assignments.Length -le 3
}

# Synopsis: Avoid using classic co-administrator roles
Rule 'Azure.RBAC.CoAdministrator' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'CoAdministrator'
    })
    $assignments.Length -eq 0
}

# Synopsis: Use RBAC assignments on resource groups instead of individual resources
Rule 'Azure.RBAC.UseRGDelegation' -Type 'Microsoft.Resources/resourceGroups' -Tag @{ release = 'GA' } {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.Scope -like "/subscriptions/*/resourceGroups/*/providers/*"
    })
    $assignments.Length -eq 0
}

#endregion RBAC

#region Security Center

# Synopsis: Security Center email and phone contact details should be set
Rule 'Azure.SecurityCenter.Contact' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $contacts = GetSubResources -ResourceType 'Microsoft.Security/securityContacts'
    $Null -ne $contacts -and $contacts.Length -gt 0;
    foreach ($c in $contacts) {
        (![String]::IsNullOrEmpty($c.Email)) -and (![String]::IsNullOrEmpty($c.Phone));
    }
}

# TODO: Check Security Center recommendations

# Synopsis: Enable auto-provisioning on VMs to improve Azure Security Center insights
Rule 'Azure.SecurityCenter.Provisioning' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA' } {
    $provisioning = GetSubResources -ResourceType 'Microsoft.Security/autoProvisioningSettings'
    $Null -ne $provisioning -and $provisioning.Length -gt 0;
    foreach ($s in $provisioning) {
        Within 'AutoProvision' -InputObject $s -AllowedValue 'On';
    }
}

#endregion Security Center

# TODO: Use policy
# TODO: Use resource locks
