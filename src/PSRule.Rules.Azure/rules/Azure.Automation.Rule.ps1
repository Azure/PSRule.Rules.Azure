# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Automation Accounts
#

# Synopsis: Ensure variables are encrypted
Rule 'Azure.Automation.EncryptVariables' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $variables = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/variables'
    if ($variables.Length -eq 0)
    {
        return $True;
    }
    foreach ($var in $variables) {
        $var.properties.isEncrypted -eq $True
    }
}

# Synopsis: Ensure webhook expiry is not longer than one year
Rule 'Azure.Automation.WebHookExpiry' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $webhooks = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/webhooks'
    if ($webhooks.Length -eq 0)
    {
        return $True;
    }
    foreach ($webhook in $webhooks) {
        $days = [math]::Abs([int]((Get-Date) - $webhook.properties.expiryTime).Days)
        $days -lt 365
    }
}
