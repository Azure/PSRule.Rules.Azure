# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cognitive Search
#

# Synopsis: Use a minimum of a basic SKU.
Rule 'Azure.Search.SKU' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.NotIn($TargetObject, 'Sku.Name', @(
        'free'
    ));
}

# Synopsis: Use a minimum of 2 replicas to receive an SLA for index queries.
Rule 'Azure.Search.QuerySLA' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.replicaCount', 2);
}

# Synopsis: Use a minimum of 3 replicas to receive an SLA for query and index updates.
Rule 'Azure.Search.IndexSLA' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.replicaCount', 3);
}

# Synopsis: Configure managed identities to access Azure resources.
Rule 'Azure.Search.ManagedIdentity' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.HasFieldValue($TargetObject, 'Identity.Type', 'SystemAssigned');
}

# Synopsis: Use Cognitive Search naming requirements.
Rule 'Azure.Search.Name' -Type 'Microsoft.Search/searchServices' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    # https://docs.microsoft.com/rest/api/searchmanagement/services/createorupdate

    # Between 2 and 60 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 2);
    $Assert.LessOrEqual($PSRule, 'TargetName', 60);

    # Lowercase letters, numbers, and dashes
    # The first two and last one character must be a letter or a number
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]{2}(([a-z0-9-](?!--)){0,57}[a-z0-9])?$', $True);
}
