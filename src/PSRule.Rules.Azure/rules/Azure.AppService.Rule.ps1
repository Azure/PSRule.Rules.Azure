# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Services
#

# Synopsis: Use an App Service Plan with at least two (2) instances
Rule 'Azure.AppService.PlanInstanceCount' -Type 'Microsoft.Web/serverfarms' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.GreaterOrEqual($TargetObject, 'Sku.capacity', 2);
}

# Synopsis: Use at least a Standard App Service Plan
Rule 'Azure.AppService.MinPlan' -Type 'Microsoft.Web/serverfarms' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Sku.tier', @('PremiumV2', 'Premium', 'Standard'))
}

# Synopsis: Disable client affinity for stateless services
Rule 'Azure.AppService.ARRAffinity' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.clientAffinityEnabled', $False)
}

# Synopsis: Use HTTPS only
Rule 'Azure.AppService.UseHTTPS' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.httpsOnly', $True)
}

# Synopsis: Use at least TLS 1.2
Rule 'Azure.AppService.MinTLS' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $siteConfig = GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config'
    $siteConfig.Properties | Within 'minTlsVersion' '1.2' -Reason ($LocalizedData.MinTLSVersion -f $siteConfig.Properties.minTlsVersion)
}
