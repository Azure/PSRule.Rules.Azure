#
# Validation rules for Azure Resource Manager Template file structure
#

# Synopsis: Use ARM template file structure
Rule 'Azure.File.Template' -Type 'System.IO.FileInfo' -If { (IsTemplateFile) } -Tag @{ release = 'GA' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName
    $jsonObject | Exists '$schema', 'contentVersion', 'resources' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters', 'functions', 'variables', 'resources', 'outputs'
}

# Synopsis: Use ARM parameter file structure
Rule 'Azure.File.Parameters' -Type 'System.IO.FileInfo' -If { (IsParameterFile) } -Tag @{ release = 'GA' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName
    $jsonObject | Exists '$schema', 'contentVersion', 'parameters' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters'
}
