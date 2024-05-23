// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for:
// - https://github.com/Azure/PSRule.Rules.Azure/issues/2859
// - https://github.com/Azure/PSRule.Rules.Azure/issues/2860

// Basic array case
var arrayA = [
  1
  2
  3
]

var arrayB = [
  4
  5
  6
]

output arrayResult int[] = [...arrayA, ...arrayB, 10]

// Basic object case
var objectA = {
  a: 1
  b: 2
  c: 3
}

var objectB = {
  d: 4
  e: 5
  f: 6
}

output objectResult object = { ...objectA, ...objectB, g: 10 }

// Detailed cases

var arrA = [2, 3]
output example1 int[] = [1, ...arrA, 4] // equivalent to [ 1, 2, 3, 4 ]

var objA = { bar: 'bar' }
output example2 object = { foo: 'foo', ...objA } // equivalent to { foo: 'foo', bar: 'bar' }

// Object keys

output example3 string[] = objectKeys({ a: 1, b: 2 }) // returns [ 'a', 'b' ]
output example3a string[] = objectKeys({}) // returns []
output example3b string[] = objectKeys({ b: 2, a: 1 }) // returns [ 'a', 'b' ]
output example3c string[] = objectKeys({ A: 2, a: 1 }) // returns [ 'A', 'a' ]
output example3d string[] = objectKeys({ a: 2, A: 1 }) // returns [ 'a', 'A' ]

// Map values

output example4 object = mapValues({ foo: 'foo' }, val => toUpper(val)) // returns { foo: 'FOO' }

// Group by

output example5 object = groupBy(['foo', 'bar', 'baz'], x => substring(x, 0, 1)) // returns { f: [ 'foo' ], b: [ 'bar', 'baz' ]

// Shallow merge

output example6 object = shallowMerge([{ foo: 'foo' }, { bar: 'bar' }]) // returns { foo: 'foo', bar: 'bar' }

// Map

output example7 object[] = map(['a', 'b'], (x, i) => { index: i, val: x }) // returns [ { index: 0, val: 'a' }, { index: 1, val: 'b' } ]

// Reduce

output example8 int = reduce([2, 3, 7], 0, (cur, next, i) => (i % 2 == 0) ? cur + next : cur) // returns 9

// Filter

output example9 string[] = filter(['foo', 'bar', 'baz'], (val, i) => i < 2 && substring(val, 0, 1) == 'b') // returns [ 'bar' ]
