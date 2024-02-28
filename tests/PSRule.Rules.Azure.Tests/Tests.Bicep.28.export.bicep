// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@export()
type myStringType = 't1' | 't2'

@export()
type myOtherStringType = myStringType

type myOtherStringTypeNullable = myOtherStringType?

@export()
type myOtherStringTypeNullable2 = myOtherStringTypeNullable

@export()
var globals = {
  env: 'dev'
  instance: 1
}

@export()
func sayHello(name string) string => 'Hello ${name}!'
