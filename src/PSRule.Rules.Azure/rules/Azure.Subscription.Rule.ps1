#
# Validation rules for Azure subscriptions
#

# Synopsis: Use groups for assigning permissions instead of individual user accounts
Rule 'Azure.Subscription.UseGroups' -Type 'Microsoft.Subscription' {
    $userAssignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.ObjectType -eq 'User'
    })
    $userAssignments.Length -le 5
}

# Synopsis: Limit the number of subscription Owners
Rule 'Azure.Subscription.LimitOwner' -Type 'Microsoft.Subscription' {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.RoleDefinitionName -eq 'Owner' -and
        ($_.Scope -like "/subscriptions/*" -or "/providers/Microsoft.Management/managementGroups/*") -and
        $_.Scope -notlike "/subscriptions/*/resourceGroups/*"
    })
    $assignments.Length -le 3
}

# Synopsis: Limit RBAC inheritance from Management Groups
Rule 'Azure.Subscription.LimitMGDelegation' -Type 'Microsoft.Subscription' {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        ($_.Scope -like "/providers/Microsoft.Management/managementGroups/*")
    })
    $assignments.Length -le 3
}

# Synopsis: Security Center email and phone contact details should be set
Rule 'Azure.Subscription.SecurityCenterContact' -Type 'Microsoft.Subscription' -Tag @{ severity = 'Important'; category = 'Security operations' } {
    $contacts = $TargetObject.resources | Where-Object { $_.ResourceType -eq 'Microsoft.Security/securityContacts' };
    $Null -ne $contacts;
    foreach ($c in $contacts) {
        (![String]::IsNullOrEmpty($c.Email)) -and (![String]::IsNullOrEmpty($c.Phone));
    }
}

# TODO: Check Security Center recommendations

# Synopsis: Enable auto-provisioning on VMs to improve Security Center insights
Rule 'Azure.Subscription.SecurityCenterProvisioning' -Type 'Microsoft.Subscription' -Tag @{ severity = 'Important'; category = 'Security operations' } {
    $provisioning = $TargetObject.resources | Where-Object { $_.ResourceType -eq 'Microsoft.Security/autoProvisioningSettings' };
    $Null -ne $provisioning;
    foreach ($s in $provisioning) {
        Within 'AutoProvision' -InputObject $s -AllowedValue 'On';
    }
}

# Synopsis: Use RBAC assignments on resource groups instead of individual resources
Rule 'Azure.Subscription.UseRGDelegation' -Type 'Microsoft.Resources/resourceGroups' {
    $assignments = @($TargetObject.resources | Where-Object {
        $_.ResourceType -eq 'Microsoft.Authorization/roleAssignments' -and
        $_.Scope -like "/subscriptions/*/resourceGroups/*/providers/*"
    })
    $assignments.Length -eq 0
}

# TODO: Use policy
# TODO: Use resource locks
