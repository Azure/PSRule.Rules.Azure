#
# Validation rules for Azure template and parameter files
#

#region Template

# Synopsis: Use ARM template file structure
Rule 'Azure.Template.TemplateFile' -Type 'System.IO.FileInfo' -If { (IsTemplateFile) } -Tag @{ release = 'GA' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName
    $jsonObject | Exists '$schema', 'contentVersion', 'resources' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters', 'functions', 'variables', 'resources', 'outputs'
}

#endregion Template

#region Parameters

# Synopsis: Use ARM parameter file structure
Rule 'Azure.Template.ParameterFile' -Type 'System.IO.FileInfo' -If { (IsParameterFile) } -Tag @{ release = 'GA' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName
    $jsonObject | Exists '$schema', 'contentVersion', 'parameters' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters'
}

#endregion Parameters
