#
# Validation rules for Azure subscriptions
#

# TODO: Check RBAC, use of groups for assignments
# TODO: Check RBAC, limited number of subscription Owners
# TODO: Check RBAC, not assigned on individual resources, on resource groups

# Description: Security Center email and phone contact details should be set
Rule 'Azure.Subscription.SecurityCenterContact' -If { ResourceType 'Microsoft.Subscription' } -Tag @{ severity = 'Important'; category = 'Security operations' } {
    $contacts = $TargetObject.resources | Where-Object { $_.ResourceType -eq 'Microsoft.Security/securityContacts' };
    $Null -ne $contacts;
    foreach ($c in $contacts) {
        (![String]::IsNullOrEmpty($c.Email)) -and (![String]::IsNullOrEmpty($c.Phone));
    }
}

# TODO: Check Security Center recommendations

# Description: Enable auto-provisioning on VMs to improve Security Center insights
Rule 'Azure.Subscription.SecurityCenterProvisioning' -If { ResourceType 'Microsoft.Subscription' } -Tag @{ severity = 'Important'; category = 'Security operations' } {
    $provisioning = $TargetObject.resources | Where-Object { $_.ResourceType -eq 'Microsoft.Security/autoProvisioningSettings' };
    $Null -ne $provisioning;
    foreach ($s in $provisioning) {
        Within 'AutoProvision' -InputObject $s -AllowedValue 'On';
    }
}
