﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;

namespace PSRule.Rules.Azure
{
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

        [DebuggerStepThrough]
        public static bool TryPopBool(this IDictionary<string, object> dictionary, string key, out bool value)
        {
            value = default;
            return dictionary.TryGetValue(key, out var v) && dictionary.Remove(key) && bool.TryParse(v.ToString(), out value);
        }

        public static bool TryGetString(this IDictionary<string, object> dictionary, string key, out string value)
        {
            value = null;
            if (!dictionary.TryGetValue(key, out var o))
                return false;

            if (o is string result)
            {
                value = result;
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

        [DebuggerStepThrough]
        public static void AddUnique(this IDictionary<string, object> dictionary, IEnumerable<KeyValuePair<string, object>> values)
        {
            if (values == null)
                return;

            foreach (var kv in values)
                if (!dictionary.ContainsKey(kv.Key))
                    dictionary.Add(kv.Key, kv.Value);
        }
    }
}
