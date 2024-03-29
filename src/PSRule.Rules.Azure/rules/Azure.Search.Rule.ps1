# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cognitive Search
#

# Synopsis: Use a minimum of a basic SKU.
Rule 'Azure.Search.SKU' -Ref 'AZR-000172' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $Assert.NotIn($TargetObject, 'Sku.Name', @(
        'free'
    ));
}

# Synopsis: Use a minimum of 2 replicas to receive an SLA for index queries.
Rule 'Azure.Search.QuerySLA' -Ref 'AZR-000173' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.replicaCount', 2);
}

# Synopsis: Use a minimum of 3 replicas to receive an SLA for query and index updates.
Rule 'Azure.Search.IndexSLA' -Ref 'AZR-000174' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.replicaCount', 3);
}

# Synopsis: Configure managed identities to access Azure resources.
Rule 'Azure.Search.ManagedIdentity' -Ref 'AZR-000175' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = @('IM-3', 'IM-3') } {
    $Assert.HasFieldValue($TargetObject, 'Identity.Type', 'SystemAssigned');
}

# Synopsis: Azure Cognitive Search service names should meet naming requirements.
Rule 'Azure.Search.Name' -Ref 'AZR-000176' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/rest/api/searchmanagement/services/createorupdate

    # Between 2 and 60 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 2);
    $Assert.LessOrEqual($PSRule, 'TargetName', 60);

    # Lowercase letters, numbers, and dashes
    # The first two and last one character must be a letter or a number
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]{2}(([a-z0-9-](?!--)){0,57}[a-z0-9])?$', $True);
}
