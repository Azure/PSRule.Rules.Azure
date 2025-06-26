// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Expressions;

#nullable enable

/// <summary>
/// Wraps deployment output values so they can be accessed directly.
/// </summary>
internal sealed class OutputValues(IReadOnlyDictionary<string, ILazyValue> inner) : IReadOnlyDictionary<string, object>
{
    private const string PROPERTY_VALUE = "value";

    private IReadOnlyDictionary<string, ILazyValue> _Inner = inner;

    public object this[string key]
    {
        get
        {
            return GetValue(key) ?? throw new KeyNotFoundException($"The key '{key}' was not found in the output values.");
        }
    }

    public IEnumerable<string> Keys => _Inner.Keys;

    public IEnumerable<object> Values
    {
        get
        {
            foreach (var kv in _Inner)
            {
                var value = GetValue(kv.Key);
                if (value != null)
                {
                    yield return value;
                }
            }
        }
    }

    public int Count => _Inner.Count;

    public bool ContainsKey(string key)
    {
        return _Inner.ContainsKey(key);
    }

    public IEnumerator<KeyValuePair<string, object>> GetEnumerator()
    {
        foreach (var kv in _Inner)
        {
            var value = GetValue(kv.Key);
            if (value != null)
            {
                yield return new KeyValuePair<string, object>(kv.Key, value);
            }
        }
    }

    public bool TryGetValue(string key, out object value)
    {
        value = GetValue(key)!;
        return value != null;
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    private JToken? GetValue(string key)
    {
        return _Inner.TryGetValue(key, out var value) && ExpressionHelpers.TryPropertyOrField(value.GetValue(), PROPERTY_VALUE, out var result)
            ? JToken.FromObject(result)
            : null;
    }
}

#nullable restore
