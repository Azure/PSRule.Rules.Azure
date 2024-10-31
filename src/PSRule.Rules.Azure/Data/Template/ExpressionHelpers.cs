// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

internal static class ExpressionHelpers
{
    private const string TRUE = "True";
    private const string FALSE = "False";

    private static readonly CultureInfo AzureCulture = new("en-US");

    internal static bool IsString(object o)
    {
        return o is string ||
            o is JToken token && token.Type == JTokenType.String ||
            o is IMock mock && mock.BaseType == TypePrimitive.String;
    }

    internal static bool IsAnyString(object[] o)
    {
        for (var i = 0; o != null && i < o.Length; i++)
            if (IsString(o[i]))
                return true;

        return false;
    }

    internal static bool TryString(object o, out string value)
    {
        if (o is string s)
        {
            value = s;
            return true;
        }
        else if (o is JToken token && token.Type == JTokenType.String)
        {
            value = token.Value<string>();
            return true;
        }
        else if (o is IMock mock && (mock.BaseType == TypePrimitive.String || mock is IUnknownMock))
        {
            value = mock.GetValue<string>();
            return true;
        }
        value = null;
        return false;
    }

    internal static bool TryConvertString(object o, out string value)
    {
        if (TryString(o, out value))
            return true;

        if (TryLong(o, out var i))
        {
            value = i.ToString(Thread.CurrentThread.CurrentCulture);
            return true;
        }
        return false;
    }

    internal static bool TryConvertStringArray(object[] o, out string[] value)
    {
        value = Array.Empty<string>();
        if (o == null || o.Length == 0 || !TryConvertString(o[0], out var s))
            return false;

        value = new string[o.Length];
        value[0] = s;
        for (var i = 1; i < o.Length; i++)
        {
            if (TryConvertString(o[i], out s))
                value[i] = s;
        }
        return true;
    }

    internal static bool TryFindStringIndex(object o, string stringToFind, out long index, bool caseSensitive, bool first)
    {
        index = -1;
        var comparer = caseSensitive ? StringComparer.Ordinal : StringComparer.OrdinalIgnoreCase;
        var array = GetStringArray(o);
        for (var i = 0; i < array.Length; i++)
        {
            if (comparer.Equals(array[i], stringToFind))
            {
                index = i;
                if (first)
                    break;
            }
        }
        return index >= 0;
    }

    internal static bool TryFindLongIndex(object o, long longToFind, out long index, bool first)
    {
        index = -1;
        var array = GetLongArray(o);
        for (var i = 0; i < array.Length; i++)
        {
            if (array[i] == longToFind)
            {
                index = i;
                if (first)
                    break;
            }
        }
        return index >= 0;
    }

    internal static bool TryFindArrayIndex(object o, Array arrayToFind, out long index, bool first)
    {
        index = -1;
        if (!TryArray(o, out var array))
            return false;

        for (var i = 0; i < array.Length; i++)
        {
            if (TryArray(array.GetValue(i), out var arrayToSearch) &&
                SequenceEqual(arrayToSearch, arrayToFind))
            {
                index = i;
                if (first)
                    break;
            }
        }
        return index >= 0;
    }

    internal static bool TryFindObjectIndex(object o, object objectToFind, out long index, bool first)
    {
        index = -1;
        if (!TryArray(o, out var array))
            return false;

        for (var i = 0; i < array.Length; i++)
        {
            if (Equal(array.GetValue(i), objectToFind))
            {
                index = i;
                if (first)
                    break;
            }
        }
        return index >= 0;
    }

    internal static bool TryIndex(object o, object index, out object value)
    {
        value = null;
        if (o == null) return false;

        if (o is IMock mock)
        {
            value = mock.GetValue(index);
            return true;
        }

        if (TryArray(o, out var array) && TryConvertInt(index, out var arrayIndex))
        {
            if (array.Length <= arrayIndex)
                return false;

            value = array.GetValue(arrayIndex);
            return true;
        }

        if (o is JObject jObject && TryString(index, out var propertyName))
        {
            if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var property))
                return false;

            value = property;
            return true;
        }

        if (o is ILazyObject lazy && TryConvertString(index, out var memberName) && lazy.TryProperty(memberName, out value))
            return true;

        return TryString(index, out propertyName) && TryPropertyOrField(o, propertyName, out value);
    }

    internal static bool TryPropertyOrField(object o, string propertyName, out object value)
    {
        value = null;
        if (IsNull(o)) return false;

        var resultType = o.GetType();

        if (o is IMock mock)
        {
            value = mock.GetValue(propertyName);
            return true;
        }

        if (o is ILazyObject lazy && lazy.TryProperty(propertyName, out value))
            return true;

        if (o is JObject jObject)
        {
            if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var propertyToken))
                return false;

            value = propertyToken;
            return true;
        }

        if (o is JToken jToken && o is not JValue)
        {
            var propertyToken = jToken[propertyName];
            if (propertyToken == null)
                return false;

            value = propertyToken.Value<object>();
            return true;
        }

        // Try dictionary
        if (o is IDictionary dictionary && dictionary.TryGetValue(propertyName, out value))
            return true;

        // Try property or field
        return resultType.TryGetValue(o, propertyName, out value);
    }

    internal static bool SequenceEqual(Array array1, Array array2)
    {
        if (array1.Length != array2.Length)
            return false;

        for (var i = 0; i < array1.Length; i++)
        {
            if (!Equal(array1.GetValue(i), array2.GetValue(i)))
                return false;
        }
        return true;
    }

    internal static bool Equal(object o1, object o2)
    {
        // One null
        if (IsNull(o1) || IsNull(o2))
            return IsNull(o1) && IsNull(o2);

        // Arrays
        if (o1 is Array array1 && o2 is Array array2)
            return SequenceEqual(array1, array2);
        else if (o1 is Array || o2 is Array)
            return false;

        // String and int
        if (TryString(o1, out var s1) && TryString(o2, out var s2))
            return s1 == s2;
        else if (TryString(o1, out _) || TryString(o2, out _))
            return false;
        else if (TryLong(o1, out var i1) && TryLong(o2, out var i2))
            return i1 == i2;
        else if (TryLong(o1, out var _) || TryLong(o2, out var _))
            return false;

        // JTokens
        if (o1 is JToken t1 && o2 is JToken t2)
            return JTokenEquals(t1, t2);

        // Objects
        return ObjectEquals(o1, o2);
    }

    private static bool IsNull(object o)
    {
        return o == null || (o is JToken token && token.Type == JTokenType.Null);
    }

    private static bool JTokenEquals(JToken t1, JToken t2)
    {
        return JToken.DeepEquals(t1, t2);
    }

    internal static bool ObjectEquals(object o1, object o2)
    {
        var objectType = o1.GetType();
        if (objectType != o2.GetType())
            return false;

        var props = objectType.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.GetProperty);
        for (var i = 0; i < props.Length; i++)
        {
            if (!object.Equals(props[i].GetValue(o1), props[i].GetValue(o2)))
                return false;
        }
        return true;
    }

    private static long[] GetLongArray(object o)
    {
        if (o is Array array)
        {
            var result = new long[array.Length];
            for (var i = 0; i < array.Length; i++)
            {
                if (TryLong(array.GetValue(i), out var l))
                    result[i] = l;
            }
            return result;
        }
        else if (o is JArray jArray)
        {
            var result = new long[jArray.Count];
            for (var i = 0; i < jArray.Count; i++)
            {
                if (TryLong(jArray[i], out var l))
                    result[i] = l;
            }
            return result;
        }
        else if (o is IEnumerable<long> l)
        {
            return l.ToArray();
        }
        else if (o is IEnumerable<int> i)
        {
            return i.Select(n => (long)n).ToArray();
        }
        else if (o is IEnumerable e)
        {
            var result = e.OfType<long>().ToArray();
            if (result.Length == 0)
                result = e.OfType<int>().Select(i => (long)i).ToArray();

            return result;
        }
        return [];
    }

    internal static bool TryStringArray(object o, out string[] value)
    {
        value = null;
        if (o is Array array)
        {
            value = new string[array.Length];
            for (var i = 0; i < array.Length; i++)
            {
                if (TryString(array.GetValue(i), out var s))
                    value[i] = s;
            }
        }
        else if (o is JArray jArray)
        {
            value = new string[jArray.Count];
            for (var i = 0; i < jArray.Count; i++)
            {
                if (TryString(jArray[i], out var s))
                    value[i] = s;
            }
        }
        else if (o is IEnumerable<string> enumerable)
        {
            value = enumerable.ToArray();
        }
        else if (o is IEnumerable e)
        {
            value = e.OfType<string>().ToArray();
        }
        return value != null;
    }

    private static string[] GetStringArray(object o)
    {
        return TryStringArray(o, out var value) ? value : Array.Empty<string>();
    }

    /// <summary>
    /// Try to get an int from the existing object.
    /// </summary>
    internal static bool TryLong(object o, out long value)
    {
        if (o is IMock mock)
        {
            value = mock.GetValue<long>();
            return true;
        }
        else if (o is int i)
        {
            value = i;
            return true;
        }
        else if (o is long l)
        {
            value = l;
            return true;
        }
        else if (o is JToken token && token.Type == JTokenType.Integer)
        {
            value = token.Value<long>();
            return true;
        }
        value = default;
        return false;
    }

    /// <summary>
    /// Try to get an int from the existing type and allow conversion from string.
    /// </summary>
    internal static bool TryConvertLong(object o, out long value)
    {
        if (TryLong(o, out value))
            return true;

        if (TryString(o, out var s) && long.TryParse(s, out value))
            return true;

        value = default;
        return false;
    }

    /// <summary>
    /// Try to get an int from the existing object.
    /// </summary>
    internal static bool TryInt(object o, out int value)
    {
        if (o is IMock mock)
        {
            value = mock.GetValue<int>();
            return true;
        }
        else if (o is int i)
        {
            value = i;
            return true;
        }
        else if (o is long l)
        {
            value = (int)l;
            return true;
        }
        else if (o is JToken token && token.Type == JTokenType.Integer)
        {
            value = token.Value<int>();
            return true;
        }
        value = default;
        return false;
    }

    /// <summary>
    /// Try to get an int from the existing type and allow conversion from string.
    /// </summary>
    internal static bool TryConvertInt(object o, out int value)
    {
        if (TryInt(o, out value))
            return true;

        if (TryLong(o, out var l))
        {
            value = (int)l;
            return true;
        }

        if (TryString(o, out var s) && int.TryParse(s, out value))
            return true;

        value = default;
        return false;
    }

    /// <summary>
    /// Try to get an bool from the existing object.
    /// </summary>
    internal static bool TryBool(object o, out bool value)
    {
        if (o is IMock mock)
        {
            value = mock.GetValue<bool>();
            return true;
        }
        else if (o is bool b)
        {
            value = b;
            return true;
        }
        else if (o is JToken token && token.Type == JTokenType.Boolean)
        {
            value = token.Value<bool>();
            return true;
        }
        value = default;
        return false;
    }

    /// <summary>
    /// Try to get an bool from the existing type and allow conversion from string or int.
    /// </summary>
    internal static bool TryConvertBool(object o, out bool value)
    {
        if (TryBool(o, out value))
            return true;

        if (TryLong(o, out var i))
        {
            value = i > 0;
            return true;
        }

        return TryString(o, out var s) && bool.TryParse(s, out value);
    }

    internal static bool TryArray<T>(object o, out T value) where T : class
    {
        value = default;
        if (o is JArray jArray)
        {
            value = jArray as T;
            return true;
        }
        else if (o is Array array)
        {
            value = array as T;
            return true;
        }
        return false;
    }

    internal static bool TryArray(object o, out Array value)
    {
        value = null;
        if (o is Array array)
        {
            value = array;
            return true;
        }
        else if (o is JArray jArray)
        {
            var jr = new JToken[jArray.Count];
            jArray.CopyTo(jr, 0);
            value = jr;
            return true;
        }
        else if (o is IEnumerable<string>)
        {
            value = GetStringArray(o);
            return true;
        }
        else if (o is IEnumerable<long> or IEnumerable<int>)
        {
            value = GetLongArray(o);
            return true;
        }
        else if (o is Mock.MockUnknownObject mockObject && mockObject.Count == 0 && mockObject.TryMutateTo(TypePrimitive.Array, out var replaced) && replaced is JArray jArrayMock)
        {
            var jr = new JToken[jArrayMock.Count];
            jArrayMock.CopyTo(jr, 0);
            value = jr;
            return true;
        }
        return false;
    }

    internal static bool TryJArray(object o, out JArray value)
    {
        value = null;
        if (o is Array array)
        {
            value = new JArray(array.OfType<object>());
            return true;
        }
        else if (o is JArray jArray)
        {
            value = jArray;
            return true;
        }
        else if (o is IEnumerable<string>)
        {
            value = new JArray(GetStringArray(o));
            return true;
        }
        else if (o is IEnumerable<long> or IEnumerable<int>)
        {
            value = new JArray(GetLongArray(o));
            return true;
        }
        else if (o is Mock.MockUnknownObject mockObject && mockObject.Count == 0 && mockObject.TryMutateTo(TypePrimitive.Array, out var replaced) && replaced is JArray jArrayMock)
        {
            value = jArrayMock;
            return true;
        }
        return false;
    }

    internal static bool IsArray(object o)
    {
        return o is JArray or Array or Mock.MockArray;
    }

    internal static object UnionArray(object[] o)
    {
        if (o == null || o.Length == 0)
            return Array.Empty<object>();

        var result = new List<object>();
        for (var i = 0; i < o.Length; i++)
        {
            if (!IsArray(o[i]))
                continue;

            if (o[i] is JArray jArray && jArray.Count > 0)
            {
                for (var j = 0; j < jArray.Count; j++)
                {
                    var element = GetBaseObject(jArray[j]);
                    if (element != null && !result.Contains(element))
                        result.Add(element);
                }
            }
            else if (o[i] is Array array && array.Length > 0)
            {
                for (var j = 0; j < array.Length; j++)
                {
                    var element = array.GetValue(j);
                    if (!result.Contains(element))
                        result.Add(element);
                }
            }
        }
        return result.ToArray();
    }

    private static object GetBaseObject(JToken token)
    {
        object result = token;
        if (token.Type == JTokenType.String)
        {
            result = token.Value<string>();
        }
        else if (token.Type == JTokenType.Integer)
        {
            result = token.Value<long>();
        }
        else if (token.Type == JTokenType.Boolean)
        {
            result = token.Value<bool>();
        }
        else if (token.Type == JTokenType.Null)
        {
            result = null;
        }
        return result;
    }

    internal static bool IsObject(object o)
    {
        return o is JObject or
            IDictionary or
            IDictionary<string, string> or
            Dictionary<string, object>;
    }

    internal static bool TryJObject(object o, out JObject value)
    {
        value = null;
        if (o is JObject jObject)
        {
            value = jObject;
            return true;
        }
        else if (o is IDictionary<string, string> dss)
        {
            value = new JObject();
            foreach (var kv in dss)
            {
                if (!value.ContainsKey(kv.Key))
                    value.Add(kv.Key, JToken.FromObject(kv.Value));
            }
            return true;
        }
        else if (o is IDictionary<string, object> dso)
        {
            value = new JObject();
            foreach (var kv in dso)
            {
                if (!value.ContainsKey(kv.Key))
                    value.Add(kv.Key, JToken.FromObject(kv.Value));
            }
            return true;
        }
        else if (o is IDictionary d)
        {
            value = new JObject();
            foreach (DictionaryEntry kv in d)
            {
                var key = kv.Key.ToString();
                if (!value.ContainsKey(key))
                    value.Add(key, JToken.FromObject(kv.Value));
            }
            return true;
        }
        return false;
    }

    /// <summary>
    /// Union an object by merging in properties.
    /// If there are duplicate keys, the last key wins.
    /// </summary>
    internal static object UnionObject(object[] o, bool deepMerge)
    {
        var result = new JObject();
        if (o == null || o.Length == 0)
            return result;

        for (var i = 0; i < o.Length; i++)
        {
            if (o[i] is JObject jObject)
            {
                foreach (var property in jObject.Properties())
                {
                    ReplaceOrMergeProperty(result, property.Name, property.Value, deepMerge);
                }
            }
            else if (o[i] is IDictionary<string, string> dss)
            {
                foreach (var kv in dss)
                {
                    ReplaceOrMergeProperty(result, kv.Key, JToken.FromObject(kv.Value), deepMerge);
                }
            }
            else if (o[i] is IDictionary<string, object> dso)
            {
                foreach (var kv in dso)
                {
                    ReplaceOrMergeProperty(result, kv.Key, JToken.FromObject(kv.Value), deepMerge);
                }
            }
            else if (o[i] is IDictionary d)
            {
                foreach (DictionaryEntry kv in d)
                {
                    var key = kv.Key.ToString();
                    ReplaceOrMergeProperty(result, key, JToken.FromObject(kv.Value), deepMerge);
                }
            }
        }
        return result;
    }

    private static void ReplaceOrMergeProperty(JObject o, string propertyName, JToken propertyValue, bool deepMerge)
    {
        if (!o.TryGetProperty(propertyName, out JToken currentValue))
        {
            o.Add(propertyName, propertyValue);
            return;
        }

        if (deepMerge && currentValue is JObject currentObject && propertyValue is JObject newObject)
        {
            foreach (var property in newObject.Properties())
            {
                ReplaceOrMergeProperty(currentObject, property.Name, property.Value, deepMerge);
            }
        }
        else
        {
            o[propertyName] = propertyValue;
        }

    }

    /// <summary>
    /// Try to get DateTime from the existing object.
    /// </summary>
    internal static bool TryDateTime(object o, out DateTime value)
    {
        if (o is DateTime dvalue)
        {
            value = dvalue;
            return true;
        }
        else if (o is JToken token && token.Type == JTokenType.Date)
        {
            value = token.Value<DateTime>();
            return true;
        }
        value = default;
        return false;
    }

    /// <summary>
    /// Try to get DateTime from the existing type and allow conversion from string.
    /// </summary>
    internal static bool TryConvertDateTime(object o, out DateTime value, DateTimeStyles style = DateTimeStyles.AdjustToUniversal)
    {
        if (TryDateTime(o, out value))
            return true;

        return TryString(o, out var svalue) &&
            (DateTime.TryParseExact(svalue, "yyyyMMddTHHmmssZ", AzureCulture, style, out value) ||
            DateTime.TryParse(svalue, AzureCulture, style, out value));
    }

    internal static bool TryJToken(object o, out JToken value)
    {
        value = default;
        if (o is JToken token)
        {
            value = token;
            return true;
        }
        else if (o is string s)
        {
            value = new JValue(s);
            return true;
        }
        else if (TryLong(o, out var l))
        {
            value = new JValue(l);
            return true;
        }
        else if (o is Array a)
        {
            value = new JArray(a);
            return true;
        }
        else if (o is Hashtable hashtable)
        {
            value = JObject.FromObject(hashtable);
            return true;
        }
        return false;
    }

    internal static JToken GetJToken(object o)
    {
        //if (o is IMock mock)
        //    return mock;

        if (o is JToken token)
            return token;

        if (o is bool b)
            return new JValue(b);

        if (o is long l)
            return new JValue(l);

        if (o is int i)
            return new JValue(i);

        if (o is string s)
            return new JValue(s);

        if (o is Array array)
            return new JArray(array);

        if (o is Hashtable hashtable)
            return JObject.FromObject(hashtable);

        return new JValue(o);
    }

    internal static byte[] GetUnique(object[] args)
    {
        // Not actual hash algorithm used in Azure
        using var algorithm = SHA256.Create();
        var url_uid = new Guid("6ba7b811-9dad-11d1-80b4-00c04fd430c8").ToByteArray();
        algorithm.TransformBlock(url_uid, 0, url_uid.Length, null, 0);
        for (var i = 0; i < args.Length; i++)
        {
            if (GetStringForMock(args[i], out var s) || TryString(args[i], out s))
            {
                var bvalue = Encoding.UTF8.GetBytes(s);
                if (i == args.Length - 1)
                    algorithm.TransformFinalBlock(bvalue, 0, bvalue.Length);
                else
                    algorithm.TransformBlock(bvalue, 0, bvalue.Length, null, 0);
            }
        }
        return algorithm.Hash;
    }

    private static bool GetStringForMock(object o, out string value)
    {
        value = null;
        if (o is not IUnknownMock mock)
            return false;

        value = mock.ToString();
        return true;
    }

    internal static string GetUniqueString(object[] args)
    {
        var hash = GetUnique(args);
        var builder = new StringBuilder();
        for (var i = 0; i < hash.Length && i < 7; i++)
            builder.Append(hash[i].ToString("x2", AzureCulture));

        return builder.ToString();
    }

    internal static bool TryBoolString(object o, out string value)
    {
        value = null;
        if (o is bool bValue)
        {
            value = GetBoolString(bValue);
            return true;
        }
        if (o is JValue jValue && jValue.Type == JTokenType.Boolean)
        {
            value = GetBoolString(jValue.Value<bool>());
            return true;
        }
        return false;
    }

    private static string GetBoolString(bool value)
    {
        return value ? TRUE : FALSE;
    }
}
