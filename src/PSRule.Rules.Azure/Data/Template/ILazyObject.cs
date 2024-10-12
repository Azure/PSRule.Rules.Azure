// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

internal interface ILazyObject
{
    bool TryProperty(string propertyName, out object value);
}
