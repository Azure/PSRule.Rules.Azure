#
# Validation rules for Automation Accounts
#

# Synopsis: Ensure variables are encrypted
Rule 'Azure.Automation.EncryptVariables' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ severity = 'Important'; category = 'Security configuration'; release = 'GA' } {
    $variableProperties = $null
    $variableProperties = @($TargetObject.resources | Where-Object -FilterScript {
            $_.ResourceType -eq 'Microsoft.Automation/automationAccounts/variables'
        })

    if ($null -ne $variableProperties) {
        foreach ($var in $variableProperties) {
            $var.properties.isEncrypted -eq $True
        }
        
    }
}

# Synopsis: Ensure webhook expiry is not longer than one year
Rule 'Azure.Automation.WebHookExpiry' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ severity = 'Awareness'; category = 'Security configuration'; release = 'GA' } {
    $variableProperties = $TargetObject.resources | Where-Object -FilterScript {
        $_.ResourceType -eq 'Microsoft.Automation/automationAccounts/webhooks'
    }

    if ($null -ne $variableProperties) {
        foreach ($var in $variableProperties) {
            $days = [math]::Abs([int]((Get-Date) - $var.properties.expiryTime).Days)
            $days -lt 365
        }
        
    }
}