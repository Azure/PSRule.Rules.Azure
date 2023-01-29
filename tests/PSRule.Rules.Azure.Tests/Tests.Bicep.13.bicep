// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Tests for lambda expressions

param arrayToTest array = [
  ['one', 'two']
  ['three']
  ['four', 'five']
]

var dogs = [
  {
    name: 'Evie'
    age: 5
    interests: ['Ball', 'Frisbee']
  }
  {
    name: 'Casper'
    age: 3
    interests: ['Other dogs']
  }
  {
    name: 'Indy'
    age: 2
    interests: ['Butter']
  }
  {
    name: 'Kira'
    age: 8
    interests: ['Rubs']
  }
]

// Flatten
output arrayOutput array = flatten(arrayToTest)

// Filter
output oldDogs array = filter(dogs, dog => dog.age >= 5)

// Map
output dogNames array = map(dogs, dog => dog.name)
output sayHi array = map(dogs, dog => 'Hello ${dog.name}!')
output mapObject array = map(range(0, length(dogs)), i => {
  i: i
  dog: dogs[i].name
  greeting: 'Ahoy, ${dogs[i].name}!'
})

// Reduce
var ages = map(dogs, dog => dog.age)
output totalAge int = reduce(ages, 0, (cur, next) => cur + next)
output totalAgeAdd1 int = reduce(ages, 1, (cur, next) => cur + next)

// Sort
output dogsByAge array = sort(dogs, (a, b) => a.age < b.age)
