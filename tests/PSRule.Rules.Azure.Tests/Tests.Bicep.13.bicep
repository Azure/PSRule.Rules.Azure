// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Tests for lambda expressions

param arrayToTest array = [
  [ 'one', 'two' ]
  [ 'three' ]
  [ 'four', 'five' ]
]

var dogs = [
  {
    name: 'Evie'
    age: 5
    interests: [ 'Ball', 'Frisbee' ]
  }
  {
    name: 'Casper'
    age: 3
    interests: [ 'Other dogs' ]
  }
  {
    name: 'Indy'
    age: 2
    interests: [ 'Butter' ]
  }
  {
    name: 'Kira'
    age: 8
    interests: [ 'Rubs' ]
  }
]

// Flatten
output arrayOutput array = flatten(arrayToTest)

// Filter
output oldDogs array = filter(dogs, dog => dog.age >= 5)
output firstOldDogs object = first(filter(dogs, dog => dog.age >= 5))
output firstOldDogsEmpty object = first(filter(dogs, dog => dog.age >= 10))

param environment string = 'subnet1'

module vnet 'Tests.Bicep.13.child.bicep' = {
  name: 'vnet'
}

module child2 'Tests.Bicep.13.child2.bicep' = {
  name: 'child2'
  params: {
    subnetId: filter(vnet.outputs.subnets, s => s.name == 'subnet1')[0].id
  }
}

output vnetId string = filter(vnet.outputs.subnets, s => s.name == environment)[0].id

// Map
output dogNames array = map(dogs, dog => dog.name)
output sayHi array = map(dogs, dog => 'Hello ${dog.name}!')
output mapObject array = map(range(0, length(dogs)), i => {
    i: i
    dog: dogs[i].name
    greeting: 'Ahoy, ${dogs[i].name}!'
  }
)

// Reduce
var ages = map(dogs, dog => dog.age)
output totalAge int = reduce(ages, 0, (cur, next) => cur + next)
output totalAgeAdd1 int = reduce(ages, 1, (cur, next) => cur + next)

// Sort
output dogsByAge array = sort(dogs, (a, b) => a.age < b.age)

// To Object
param numbers array = [ 0, 1, 2, 3 ]
output objectMap object = toObject([ 123, 456, 789 ], i => '${i / 100}')
output objectMap2 object = toObject(numbers, i => '${i}', i => {
    isEven: (i % 2) == 0
    isGreaterThan2: (i > 2)
  }
)
output objectMapNull object = toObject([ 123, 456, 789, null ], i => '${i}')

// Additional cases map in map

var mapNested = [
  {
    item: [
      'item1'
      'item2'
    ]
    value: 'value1'
  }
]

output mapInMap array = flatten(map(mapNested, a => map(a.item, b => a.value)))
