# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Event Grid
#

# Synopsis: EventGrid domains without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.EventGrid.DomainNaming' -Ref 'AZR-000461' -Type 'Microsoft.EventGrid/domains' -If { $Configuration['AZURE_EVENTGRID_DOMAIN_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_EVENTGRID_DOMAIN_NAME_FORMAT, $True);
}

# Synopsis: EventGrid topics without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.EventGrid.TopicNaming' -Ref 'AZR-000462' -Type 'Microsoft.EventGrid/topics', 'Microsoft.EventGrid/domains/topics' -If { $Configuration['AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $name = $PSRule.TargetName.Split('/')[-1];
    $Assert.Match($name, '.', $Configuration.AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT, $True);
}

# Synopsis: EventGrid system topics without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.EventGrid.SystemTopicNaming' -Ref 'AZR-000463' -Type 'Microsoft.EventGrid/systemTopics' -If { $Configuration['AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $name = $PSRule.TargetName.Split('/')[-1];
    $Assert.Match($name, '.', $Configuration.AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT, $True);
}
