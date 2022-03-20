// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure
{
    internal interface ILazyValue
    {
        object GetValue();
    }

    internal interface ILazyObject
    {
        bool TryProperty(string propertyName, out object value);
    }

    internal sealed class LazyValue : ILazyValue
    {
        private readonly Func<object> _Value;

        public LazyValue(Func<object> value)
        {
            _Value = value;
        }

        public object GetValue()
        {
            return _Value();
        }
    }
}
