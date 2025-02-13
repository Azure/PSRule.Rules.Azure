// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management.Automation;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure;

/// <summary>
/// Extension methods for dictionary instances.
/// </summary>
internal static class DictionaryExtensions
{
    [DebuggerStepThrough]
    public static bool TryPopValue(this IDictionary<string, object> dictionary, string key, out object value)
    {
        return dictionary.TryGetValue(key, out value) && dictionary.Remove(key);
    }

    [DebuggerStepThrough]
    public static bool TryPopValue<T>(this IDictionary<string, object> dictionary, string key, out T value)
    {
        value = default;
        if (dictionary.TryGetValue(key, out var v) && dictionary.Remove(key) && v is T result)
        {
            value = result;
            return true;
        }
        return false;
    }

    public static bool TryPopHashtable(this IDictionary<string, object> dictionary, string key, out Hashtable value)
    {
        value = null;
        if (dictionary.TryPopValue(key, out var o) && o is Hashtable result)
        {
            value = result;
            return true;
        }
        if (dictionary.TryPopValue(key, out PSObject pso))
        {
            value = pso.ToHashtable();
            return true;
        }

        return false;
    }

    [DebuggerStepThrough]
    public static bool TryGetValue<T>(this IDictionary<string, object> dictionary, string key, out T value)
    {
        value = default;
        if (dictionary.TryGetValue(key, out var v) && v is T result)
        {
            value = result;
            return true;
        }
        return false;
    }

    [DebuggerStepThrough]
    public static bool TryGetValue(this IDictionary dictionary, string key, out object value)
    {
        value = default;
        if (dictionary.Contains(key))
        {
            value = dictionary[key];
            return true;
        }
        return false;
    }

    [DebuggerStepThrough]
    public static bool TryPopBool(this IDictionary<string, object> dictionary, string key, out bool value)
    {
        value = default;
        return dictionary.TryGetValue(key, out var v) && dictionary.Remove(key) && bool.TryParse(v.ToString(), out value);
    }

    public static bool TryGetString(this IDictionary<string, object> dictionary, string key, out string value)
    {
        value = null;
        if (dictionary.TryGetValue(key, out var o) && o is string s)
        {
            value = s;
            return true;
        }
        if (dictionary.TryGetValue(key, out s))
        {
            value = s;
            return true;
        }
        return false;
    }

    public static bool TryGetBool(this IDictionary<string, object> dictionary, string key, out bool? value)
    {
        value = null;
        if (!dictionary.TryGetValue(key, out var o))
            return false;

        if (o is bool result || (o is string svalue && bool.TryParse(svalue, out result)))
        {
            value = result;
            return true;
        }
        return false;
    }

    public static bool TryGetLong(this IDictionary<string, object> dictionary, string key, out long? value)
    {
        value = null;
        if (!dictionary.TryGetValue(key, out var o))
            return false;

        if (o is long result || (o is string svalue && long.TryParse(svalue, out result)))
        {
            value = result;
            return true;
        }
        return false;
    }

    public static bool TryGetArray(this IDictionary<string, object> dictionary, string parameterName, out JToken value)
    {
        value = default;
        if (!dictionary.TryGetValue<List<object>>(parameterName, out var result))
            return false;

        value = JArray.FromObject(result);
        return true;
    }

    public static bool TryGetObject(this IDictionary<string, object> dictionary, string parameterName, out JToken value)
    {
        value = default;
        if (!dictionary.TryGetValue<Dictionary<object, object>>(parameterName, out var result))
            return false;

        value = JObject.FromObject(result);
        return true;
    }

    /// <summary>
    /// Add an item to the dictionary if it doesn't already exist in the dictionary.
    /// </summary>
    [DebuggerStepThrough]
    public static void AddUnique(this IDictionary<string, object> dictionary, IEnumerable<KeyValuePair<string, object>> values)
    {
        if (values == null || dictionary == null)
            return;

        foreach (var kv in values)
        {
            if (!dictionary.ContainsKey(kv.Key))
                dictionary.Add(kv.Key, kv.Value);
        }
    }
}
