// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using System;
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

            if (TryInt(o, out int ivalue))
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
        internal static bool TryInt(object o, out int value)
        {
            if (o is int i)
            {
                value = i;
                return true;
            }
            else if (o is JToken token && token.Type == JTokenType.Integer)
            {
                value = token.Value<int>();
                return true;
            }
            value = 0;
            return false;
        }

        /// <summary>
        /// Try to get an int from the existing type and allow conversion from string.
        /// </summary>
        internal static bool TryConvertInt(object o, out int value)
        {
            if (TryInt(o, out value))
                return true;

            if (TryString(o, out string svalue) && int.TryParse(svalue, out value))
                return true;

            value = 0;
            return false;
        }
    }
}
