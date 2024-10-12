// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Data.Template;

internal sealed class LazyValue(Func<object> value) : ILazyValue
{
    private readonly Func<object> _Value = value;

    public object GetValue()
    {
        return _Value();
    }
}
