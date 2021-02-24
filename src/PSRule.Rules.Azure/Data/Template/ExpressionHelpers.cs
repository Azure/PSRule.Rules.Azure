// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using System;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

namespace PSRule.Rules.Azure.Data.Template
{
    internal static class ExpressionHelpers
    {
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
            else if (o is MockNode mockNode)
            {
                value = mockNode.BuildString();
                return true;
            }
            value = null;
            return false;
        }

        internal static bool TryConvertString(object o, out string value)
        {
            if (TryString(o, out value))
                return true;

            if (TryLong(o, out long ivalue))
            {
                value = ivalue.ToString(Thread.CurrentThread.CurrentCulture);
                return true;
            }
            return false;
        }

        internal static bool TryConvertStringArray(object[] o, out string[] value)
        {
            value = Array.Empty<string>();
            if (o == null || o.Length == 0 || !TryConvertString(o[0], out string s))
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

            if (TryString(o, out string svalue) && long.TryParse(svalue, out value))
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

            if (TryLong(o, out long lvalue))
            {
                value = (int)lvalue;
                return true;
            }

            if (TryString(o, out string svalue) && int.TryParse(svalue, out value))
                return true;

            value = default(int);
            return false;
        }

        /// <summary>
        /// Try to get an bool from the existing object.
        /// </summary>
        internal static bool TryBool(object o, out bool value)
        {
            if (o is bool bvalue)
            {
                value = bvalue;
                return true;
            }
            else if (o is JToken token && token.Type == JTokenType.Boolean)
            {
                value = token.Value<bool>();
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

            if (TryLong(o, out long ivalue))
            {
                value = ivalue > 0;
                return true;
            }

            if (TryString(o, out string svalue) && bool.TryParse(svalue, out value))
                return true;

            value = default(bool);
            return false;
        }

        internal static byte[] GetUnique(object[] args)
        {
            // Not actual hash algorithm used in Azure
            using (var algorithm = SHA256.Create())
            {
                byte[] url_uid = new Guid("6ba7b811-9dad-11d1-80b4-00c04fd430c8").ToByteArray();
                algorithm.TransformBlock(url_uid, 0, url_uid.Length, null, 0);

                for (var i = 0; i < args.Length; i++)
                {
                    if (TryString(args[i], out string svalue))
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
            var culture = new CultureInfo("en-us");
            for (int i = 0; i < hash.Length && i < 7; i++)
            {
                builder.Append(hash[i].ToString("x2", culture));
            }
            return builder.ToString();
        }
    }
}
