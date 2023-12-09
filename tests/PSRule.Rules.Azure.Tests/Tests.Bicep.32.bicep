// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2578

module subnet1 './Tests.Bicep.32.subnet.bicep' = {
  name: 'subnet1'
  params: {
    subnetNum: '1'
  }
}

module subnet2 './Tests.Bicep.32.subnet.bicep' = {
  name: 'subnet2'
  params: {
    subnetNum: '2'
  }
  dependsOn: [
    subnet1
    dep_subnet1_1
  ]
}

module subnet3 './Tests.Bicep.32.subnet.bicep' = {
  name: 'subnet3'
  params: {
    subnetNum: '3'
  }
  dependsOn: [
    subnet2
  ]
}

module subnet4 './Tests.Bicep.32.subnet.bicep' = [for (item, index) in range(1, 3): {
  name: 'subnet4-${index}'
  params: {
    subnetNum: '4-${index}'
  }
  dependsOn: [
    subnet2
  ]
}]

module dep_subnet1_1 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_1'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet2_1 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet2_1'
  params: {
    subnetResourceId: subnet2.outputs.subnetResourceId
  }
}

module dep_subnet1_2 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_2'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet1_3 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_3'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet1_4 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_4'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet1_5 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_5'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet1_6 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet1_6'
  params: {
    subnetResourceId: subnet1.outputs.subnetResourceId
  }
}

module dep_subnet3_1 './Tests.Bicep.32.dep.bicep' = {
  name: 'dep_subnet3_1'
  params: {
    subnetResourceId: subnet3.outputs.subnetResourceId
  }
  dependsOn: [
    subnet4
  ]
}

module dep_subnet4_1 './Tests.Bicep.32.dep.bicep' = [for (item, index) in range(1, 3): {
  name: 'dep_subnet4_${index}'
  params: {
    subnetResourceId: subnet4[index].outputs.subnetResourceId
  }
}]
