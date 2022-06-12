// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    internal static class ExpressionHelpers
    {
        private const string TRUE = "True";
        private const string FALSE = "False";

        private static readonly CultureInfo AzureCulture = new CultureInfo("en-US");

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
            else if (o is IMock mock)
            {
                value = mock.ToString();
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

        /// <summary>
        /// Try to get an int from the existing object.
        /// </summary>
        internal static bool TryLong(object o, out long value)
        {
            if (o is int i)
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
            else if (o is MockInteger mock)
            {
                value = mock.Value;
                return true;
            }
            value = default(long);
            return false;
        }

        /// <summary>
        /// Try to get an int from the existing type and allow conversion from string.
        /// </summary>
        internal static bool TryConvertLong(object o, out long value)
        {
            if (TryLong(o, out value))
                return true;

            if (TryString(o, out var svalue) && long.TryParse(svalue, out value))
                return true;

            value = default(long);
            return false;
        }

        /// <summary>
        /// Try to get an int from the existing object.
        /// </summary>
        internal static bool TryInt(object o, out int value)
        {
            if (o is int i)
            {
                value = i;
                return true;
            }
            if (o is long l)
            {
                value = (int)l;
                return true;
            }
            else if (o is JToken token && token.Type == JTokenType.Integer)
            {
                value = token.Value<int>();
                return true;
            }
            else if (o is MockInteger mock)
            {
                value = (int)mock.Value;
                return true;
            }
            value = default(int);
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

            value = default(int);
            return false;
        }

        /// <summary>
        /// Try to get an bool from the existing object.
        /// </summary>
        internal static bool TryBool(object o, out bool value)
        {
            if (o is bool b)
            {
                value = b;
                return true;
            }
            else if (o is JToken token && token.Type == JTokenType.Boolean)
            {
                value = token.Value<bool>();
                return true;
            }
            else if (o is MockBool mock)
            {
                value = mock.Value;
                return true;
            }
            value = default(bool);
            return false;
        }

        /// <summary>
        /// Try to get an bool from the existing type and allow conversion from string or int.
        /// </summary>
        internal static bool TryConvertBool(object o, out bool value)
        {
            if (TryBool(o, out value))
                return true;

            if (TryLong(o, out var ivalue))
            {
                value = ivalue > 0;
                return true;
            }

            return TryString(o, out var svalue) && bool.TryParse(svalue, out value);
        }

        internal static bool TryArray<T>(object o, out T value) where T : class
        {
            value = default(T);
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
            else if (o is MockArray mock)
            {
                value = mock as T;
                return true;
            }
            return false;
        }

        internal static bool IsArray(object o)
        {
            return o is JArray || o is Array || o is MockArray;
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
                        var element = jArray[j];
                        if (!result.Contains(element))
                            result.Add(element);
                    }
                }
                else if (o[i] is MockArray mock && mock.Value != null && mock.Value.Count > 0)
                {
                    for (var j = 0; j < mock.Value.Count; j++)
                    {
                        var element = mock.Value[j];
                        if (!result.Contains(element))
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
            value = default(DateTime);
            return false;
        }

        /// <summary>
        /// Try to get DateTime from the existing type and allow conversion from string.
        /// </summary>
        internal static bool TryConvertDateTime(object o, out DateTime value, DateTimeStyles style = DateTimeStyles.AdjustToUniversal)
        {
            if (TryDateTime(o, out value))
                return true;

            if (TryString(o, out var svalue) && DateTime.TryParse(svalue, AzureCulture, style, out value))
                return true;

            return false;
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

            if (o is IMock mock && mock.TryGetToken(out token))
                return token;

            if (o is MockMember mockMember)
                return new JValue(mockMember.ToString());

            return new JValue(o);
        }

        internal static byte[] GetUnique(object[] args)
        {
            // Not actual hash algorithm used in Azure
            using (var algorithm = SHA256.Create())
            {
                var url_uid = new Guid("6ba7b811-9dad-11d1-80b4-00c04fd430c8").ToByteArray();
                algorithm.TransformBlock(url_uid, 0, url_uid.Length, null, 0);

                for (var i = 0; i < args.Length; i++)
                {
                    if (TryString(args[i], out var svalue))
                    {
                        var bvalue = Encoding.UTF8.GetBytes(svalue);
                        if (i == args.Length - 1)
                            algorithm.TransformFinalBlock(bvalue, 0, bvalue.Length);
                        else
                            algorithm.TransformBlock(bvalue, 0, bvalue.Length, null, 0);
                    }
                    else
                    {
                        throw new ArgumentException();
                    }
                }
                return algorithm.Hash;
            }
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
}
