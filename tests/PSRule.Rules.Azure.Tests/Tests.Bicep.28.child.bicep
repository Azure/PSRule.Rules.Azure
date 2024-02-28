// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { myOtherStringType, myOtherStringTypeNullable2, globals } from './Tests.Bicep.28.export.bicep'
import { sayHello } from './Tests.Bicep.28.export.bicep'

param value myOtherStringType = 't2'

param valueNullable myOtherStringTypeNullable2

output outValue myOtherStringType = value

output outValueNullable myOtherStringTypeNullable2 = valueNullable

output hello string = sayHello('value')

output outGlobal object = globals
