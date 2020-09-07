// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// Implementation of Azure Resource Manager template functions as ExpressionFn.
    /// </summary>
    internal static class Functions
    {
        internal readonly static IFunctionDescriptor[] Builtin = new IFunctionDescriptor[]
        {
            // Array and object
            new FunctionDescriptor("array", Array),
            new FunctionDescriptor("coalesce", Coalesce),
            new FunctionDescriptor("concat", Concat),
            new FunctionDescriptor("contains", Contains),
            new FunctionDescriptor("createArray", CreateArray),
            new FunctionDescriptor("empty", Empty),
            new FunctionDescriptor("first", First),
            new FunctionDescriptor("intersection", Intersection),
            new FunctionDescriptor("json", Json),
            new FunctionDescriptor("last", Last),
            new FunctionDescriptor("length", Length),
            new FunctionDescriptor("min", Min),
            new FunctionDescriptor("max", Max),
            new FunctionDescriptor("range", Range),
            new FunctionDescriptor("skip", Skip),
            new FunctionDescriptor("take", Take),
            new FunctionDescriptor("union", Union),

            // Comparison
            new FunctionDescriptor("equals", Equals),
            new FunctionDescriptor("greater", Greater),
            new FunctionDescriptor("greaterOrEquals", GreaterOrEquals),
            new FunctionDescriptor("less", Less),
            new FunctionDescriptor("lessOrEquals", LessOrEquals),

            // Deployment
            new FunctionDescriptor("deployment", Deployment),
            new FunctionDescriptor("parameters", Parameters),
            new FunctionDescriptor("variables", Variables),

            // Logical
            new FunctionDescriptor("and", And),
            new FunctionDescriptor("bool", Bool),
            new FunctionDescriptor("if", If),
            new FunctionDescriptor("not", Not),
            new FunctionDescriptor("or", Or),

            // Numeric
            new FunctionDescriptor("add", Add),
            new FunctionDescriptor("copyIndex", CopyIndex),
            new FunctionDescriptor("div", Div),
            new FunctionDescriptor("float", Float),
            new FunctionDescriptor("int", Int),
            // min - also in array and object
            // max - also in array and object
            new FunctionDescriptor("mod", Mod),
            new FunctionDescriptor("mul", Mul),
            new FunctionDescriptor("sub", Sub),

            // Resource
            new FunctionDescriptor("extensionResourceId", ExtensionResourceId),
            new FunctionDescriptor("list", List), // Includes listAccountSas, listKeys, listSecrets, list*
            // providers
            new FunctionDescriptor("reference", Reference),
            new FunctionDescriptor("resourceGroup", ResourceGroup),
            new FunctionDescriptor("resourceId", ResourceId),
            new FunctionDescriptor("subscription", Subscription),
            new FunctionDescriptor("subscriptionResourceId", SubscriptionResourceId),
            new FunctionDescriptor("tenantResourceId", TenantResourceId),

            // String
            new FunctionDescriptor("base64", Base64),
            new FunctionDescriptor("base64ToJson", Base64ToJson),
            new FunctionDescriptor("base64ToString", Base64ToString),
            // concat - also in array and object
            // contains - also in array and object
            new FunctionDescriptor("dataUri", DataUri),
            new FunctionDescriptor("dataUriToString", DataUriToString),
            // empty - also in array and object
            new FunctionDescriptor("endsWith", EndsWith),
            // first - also in array and object
            new FunctionDescriptor("format", Format),
            new FunctionDescriptor("guid", Guid),
            new FunctionDescriptor("indexOf", IndexOf),
            // last - also in array and object
            new FunctionDescriptor("lastIndexOf", LastIndexOf),
            // length - also in array and object
            new FunctionDescriptor("newGuid", NewGuid),
            new FunctionDescriptor("padLeft", PadLeft),
            new FunctionDescriptor("replace", Replace),
            // skip - also in array and object
            new FunctionDescriptor("split", Split),
            new FunctionDescriptor("startsWith", StartsWith),
            new FunctionDescriptor("string", String),
            new FunctionDescriptor("substring", Substring),
            // take - also in array and object
            new FunctionDescriptor("toLower", ToLower),
            new FunctionDescriptor("toUpper", ToUpper),
            new FunctionDescriptor("trim", Trim),
            new FunctionDescriptor("uniqueString", UniqueString),
            new FunctionDescriptor("uri", Uri),
            new FunctionDescriptor("uriComponent", UriComponent),
            new FunctionDescriptor("uriComponentToString", UriComponentToString),
            new FunctionDescriptor("utcNow", UtcNow),
        };

        private static readonly CultureInfo AzureCulture = new CultureInfo("en-US");

        #region Array and object

        internal static object Array(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Array), args);

            return new JArray(args[0]);
        }

        internal static object Coalesce(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(Coalesce), args);

            for (var i = 0; i < args.Length; i++)
            {
                if (!IsNull(args[i]))
                    return args[i];
            }
            return args[0];
        }

        internal static object Concat(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(Concat), args);

            // String
            if (ExpressionHelpers.TryConvertStringArray(args, out string[] s))
            {
                return string.Concat(s);
            }
            // Array
            else if (args[0] is Array || args[0] is JArray)
            {
                var result = new List<object>();
                for (var i = 0; i < args.Length; i++)
                {
                    if (args[i] is Array array)
                    {
                        for (var j = 0; j < array.Length; j++)
                            result.Add(array.GetValue(j));
                    }
                    else if (args[i] is JArray jArray)
                    {
                        for (var j = 0; j < jArray.Count; j++)
                            result.Add(jArray[j]);
                    }
                }
                return result.ToArray();
            }
            throw ArgumentFormatInvalid(nameof(Concat));
        }

        internal static Array Concat(Array[] array)
        {
            var result = new List<object>();
            for (var i = 0; i < array.Length; i++)
            {
                for (var j = 0; j < array[i].Length; j++)
                    result.Add(array[i].GetValue(j));
            }
            return result.ToArray();
        }

        internal static object Empty(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Empty), args);

            if (args[0] == null)
                return true;
            else if (args[0] is Array avalue)
                return avalue.Length == 0;
            else if (args[0] is JArray jArray)
                return jArray.Count == 0;
            else if (args[0] is string svalue)
                return string.IsNullOrEmpty(svalue);
            else if (args[0] is JObject jObject)
                return !jObject.Properties().Any();

            return false;
        }

        internal static object Contains(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Contains), args);

            var objectToFind = args[1];

            if (args[0] is Array avalue)
                return Contains(avalue, objectToFind);
            else if (args[0] is JArray jArray)
                return jArray.Contains(JToken.FromObject(objectToFind));
            else if (args[0] is string svalue)
                return svalue.Contains(objectToFind.ToString());
            else if (args[0] is JObject jObject)
                return jObject.ContainsKey(objectToFind.ToString());

            return false;
        }

        internal static object CreateArray(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(CreateArray), args);

            return new JArray(args);
        }

        internal static object First(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(First), args);

            if (args[0] is Array avalue)
                return avalue.GetValue(0);
            else if (args[0] is JArray jArray)
                return jArray[0];
            else if (args[0] is string svalue)
                return svalue[0];

            return null;
        }

        internal static object Intersection(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Intersection), args);

            // Array
            if (args[0] is JArray jArray)
            {
                IEnumerable<JToken> intersection = jArray;
                for (var i = 1; i < args.Length; i++)
                {
                    if (!TryJArray(args[i], out JArray value))
                        throw new ArgumentException();

                    intersection = intersection.Intersect(value);
                }
                return new JArray(intersection.ToArray());
            }

            // Object
            if (args[0] is JObject jObject)
            {
                var intersection = jObject.DeepClone() as JObject;
                for (var i = 1; i < args.Length; i++)
                {
                    if (!TryJObject(args[i], out JObject value))
                        throw new ArgumentException();

                    foreach (var prop in intersection.Properties().ToArray())
                    {
                        if (!(value.ContainsKey(prop.Name) && JToken.DeepEquals(value[prop.Name], prop.Value)))
                            intersection.Remove(prop.Name);
                    }
                }
                return intersection;
            }
            throw new ArgumentException();
        }

        internal static object Json(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1 || !ExpressionHelpers.TryString(args[0], out string json))
                throw new ArgumentOutOfRangeException();

            return JsonConvert.DeserializeObject(json);
        }

        internal static object Last(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Last), args);

            if (args[0] is Array avalue)
                return avalue.GetValue(avalue.Length - 1);
            else if (args[0] is JArray jArray)
                return jArray[jArray.Count - 1];
            else if (args[0] is string svalue)
                return svalue[svalue.Length - 1];

            return null;
        }

        internal static object Length(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Length), args);

            if (args[0] is string s)
                return s.Length;
            else if (args[0] is Array a)
                return a.Length;
            else if (args[0] is JArray jArray)
                return jArray.Count;

            return args[0].GetType().GetProperties().Length;
        }

        internal static object Min(TemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(Min), args);

            int? result = null;
            for (var i = 0; i < args.Length; i++)
            {
                if (ExpressionHelpers.TryInt(args[i], out int value))
                {
                    result = !result.HasValue || value < result ? value : result;
                }
                // Enumerate array arg
                else if (TryJArray(args[i], out JArray array))
                {
                    for (var j = 0; j < array.Count; j++)
                    {
                        if (ExpressionHelpers.TryInt(array[j], out value))
                        {
                            result = !result.HasValue || value < result ? value : result;
                        }
                        else
                            throw new ArgumentException();
                    }
                }
                else
                    throw new ArgumentException();
            }
            return result;
        }

        internal static object Max(TemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(Max), args);

            int? result = null;
            for (var i = 0; i < args.Length; i++)
            {
                if (ExpressionHelpers.TryInt(args[i], out int value))
                {
                    result = !result.HasValue || value > result ? value : result;
                }
                // Enumerate array arg
                else if (TryJArray(args[i], out JArray array))
                {
                    for (var j = 0; j < array.Count; j++)
                    {
                        if (ExpressionHelpers.TryInt(array[j], out value))
                        {
                            result = !result.HasValue || value > result ? value : result;
                        }
                        else
                            throw new ArgumentException();
                    }
                }
                else
                    throw new ArgumentException();
            }
            return result;
        }

        internal static object Range(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Range), args);

            if (!ExpressionHelpers.TryInt(args[0], out int startingInteger))
                throw new ArgumentException();

            if (!ExpressionHelpers.TryInt(args[1], out int numberofElements))
                throw new ArgumentException();

            var result = new int[numberofElements];
            for (var i = 0; i < numberofElements; i++)
                result[i] = startingInteger++;

            return new JArray(result);
        }

        internal static object Skip(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Skip), args);

            if (!ExpressionHelpers.TryInt(args[1], out int numberToSkip))
                throw new ArgumentException();

            int skip = numberToSkip <= 0 ? 0 : numberToSkip;
            if (ExpressionHelpers.TryString(args[0], out string soriginalValue))
            {
                if (skip >= soriginalValue.Length)
                    return string.Empty;

                return soriginalValue.Substring(skip);
            }
            else if (TryJArray(args[0], out JArray aoriginalvalue))
            {
                if (skip >= aoriginalvalue.Count)
                    return new JArray();

                var result = new JArray();
                for (var i = skip; i < aoriginalvalue.Count; i++)
                    result.Add(aoriginalvalue[i]);

                return result;
            }

            throw new ArgumentException();
        }

        internal static object Take(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Take), args);

            if (!ExpressionHelpers.TryInt(args[1], out int numberToTake))
                throw new ArgumentException();

            int take = numberToTake <= 0 ? 0 : numberToTake;
            if (ExpressionHelpers.TryString(args[0], out string soriginalValue))
            {
                if (take <= 0)
                    return string.Empty;

                take = take > soriginalValue.Length ? soriginalValue.Length : take;
                return soriginalValue.Substring(0, take);
            }
            else if (TryJArray(args[0], out JArray aoriginalvalue))
            {
                if (take <= 0)
                    return new JArray();

                var result = new JArray();
                for (var i = 0; i < aoriginalvalue.Count && i < take; i++)
                    result.Add(aoriginalvalue[i]);

                return result;
            }

            throw new ArgumentException();
        }

        internal static object Union(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Union), args);

            // Array
            if (args[0] is Array)
            {
                Array[] arrays = new Array[args.Length];
                args.CopyTo(arrays, 0);
                return Union(arrays);
            }
            else if (args[0] is JArray)
            {
                JArray[] arrays = new JArray[args.Length];
                for (var i = 0; i < arrays.Length; i++)
                {
                    arrays[i] = args[i] as JArray;
                }
                return Union(arrays);
            }

            // Object
            if (args[0] is JObject jObject1)
            {
                var result = new JObject(jObject1);
                for (var i = 1; i < args.Length && args[i] is JObject jObject2; i++)
                {
                    foreach (var property in jObject2.Properties())
                    {
                        if (!result.ContainsKey(property.Name))
                            result.Add(property.Name, property.Value);
                    }
                }
                return result;
            }
            return null;
        }

        private static Array Union(Array[] arrays)
        {
            var result = new List<object>();
            for (var i = 0; i < arrays.Length; i++)
            {
                for (var j = 0; arrays[i] != null && j < arrays[i].Length; j++)
                {
                    var value = arrays[i].GetValue(j);
                    if (!result.Contains(value))
                        result.Add(value);
                }
            }
            return result.ToArray();
        }

        private static JArray Union(JArray[] arrays)
        {
            var result = new JArray();
            for (var i = 0; i < arrays.Length; i++)
            {
                for (var j = 0; j < arrays[i].Count; j++)
                {
                    var element = arrays[i][j];
                    if (!result.Contains(element))
                        result.Add(element);
                }

            }
            return result;
        }

        #endregion Array and object

        #region Deployment

        internal static object Deployment(TemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Deployment), args);

            return context.Deployment;
        }

        internal static object Parameters(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Parameters), args);

            if (!ExpressionHelpers.TryString(args[0], out string parameterName))
                throw ArgumentFormatInvalid(nameof(Parameters));

            if (!context.TryParameter(parameterName, out object result))
                throw new KeyNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterNotFound, parameterName));

            return result;
        }

        internal static object Variables(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Variables), args);

            if (!ExpressionHelpers.TryString(args[0], out string variableName))
                throw ArgumentFormatInvalid(nameof(Variables));

            if (!context.TryVariable(variableName, out object result))
                throw new KeyNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.VariableNotFound, variableName));

            return result;
        }

        #endregion Deployment

        #region Resource

        /// <summary>
        /// extensionResourceId(resourceId, resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// {scope}/providers/{extensionResourceProviderNamespace}/{extensionResourceType}/{extensionResourceName}
        /// </returns>
        internal static object ExtensionResourceId(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 3)
                throw ArgumentsOutOfRange(nameof(ExtensionResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out string value))
                    throw ArgumentFormatInvalid(nameof(ExtensionResourceId));

                segments[i] = value;
            }

            var resourceId = segments[0];
            if (!segments[1].Contains('/'))
                throw new ArgumentException();

            var resourceType = TrimResourceType(segments[1]);
            var nameDepth = resourceType.Split('/').Length - 1;
            if ((segments.Length - 2) != nameDepth)
                throw new TemplateFunctionException(nameof(ExtensionResourceId), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

            var name = new string[nameDepth];
            System.Array.Copy(segments, 2, name, 0, nameDepth);
            var nameParts = string.Join("/", name);
            return string.Concat(resourceId, "/providers/", resourceType, "/", nameParts);
        }

        /// <summary>
        /// list{Value}(resourceName or resourceIdentifier, apiVersion, functionValues)
        /// </summary>
        internal static object List(TemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 2 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(List), args);

            ExpressionHelpers.TryString(args[0], out string resourceId);
            return new MockList(resourceId);
        }

        internal static object Reference(TemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 1 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(Reference), args);

            ExpressionHelpers.TryString(args[0], out string resourceType);
            return new MockResource(resourceType);
        }

        /// <summary>
        /// resourceGroup()
        /// </summary>
        internal static object ResourceGroup(TemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(ResourceGroup), args);

            return context.ResourceGroup;
        }

        /// <summary>
        /// resourceId([subscriptionId], [resourceGroupName], resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object ResourceId(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(ResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out string value))
                    throw ArgumentFormatInvalid(nameof(ResourceId));

                segments[i] = value;
            }

            string subscriptionId = context.Subscription.SubscriptionId;
            string resourceGroup = context.ResourceGroup.Name;
            string resourceType = null;
            string nameParts = null;

            for (var i = 0; resourceType == null && i < segments.Length; i++)
            {
                if (segments[i].Contains('/'))
                {
                    // Copy earlier segments
                    if (i == 1)
                        resourceGroup = segments[0];
                    else if (i == 2)
                    {
                        resourceGroup = segments[1];
                        subscriptionId = segments[0];
                    }
                    resourceType = TrimResourceType(segments[i]);
                    var nameDepth = resourceType.Split('/').Length - 1;

                    if ((segments.Length - 1 - i) != nameDepth)
                        throw new TemplateFunctionException(nameof(ResourceId), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

                    string[] name = new string[nameDepth];
                    System.Array.Copy(segments, i + 1, name, 0, nameDepth);
                    nameParts = string.Join("/", name);
                }
            }
            return string.Concat("/subscriptions/", subscriptionId, "/resourceGroups/", resourceGroup, "/providers/", resourceType, "/", nameParts);
        }
        
        /// <summary>
        /// subscription()
        /// </summary>
        internal static object Subscription(TemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Subscription), args);

            return context.Subscription;
        }

        /// <summary>
        /// subscriptionResourceId([subscriptionId], resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /subscriptions/{subscriptionId}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object SubscriptionResourceId(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(SubscriptionResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out string value))
                    throw ArgumentFormatInvalid(nameof(SubscriptionResourceId));

                segments[i] = value;
            }

            string subscriptionId = context.Subscription.SubscriptionId;
            string resourceType = null;
            string nameParts = null;

            for (var i = 0; resourceType == null && i < segments.Length; i++)
            {
                if (segments[i].Contains('/'))
                {
                    // Copy earlier segments
                    if (i == 1)
                        subscriptionId = segments[0];

                    resourceType = TrimResourceType(segments[i]);
                    var nameDepth = resourceType.Split('/').Length - 1;

                    if ((segments.Length - 1 - i) != nameDepth)
                        throw new TemplateFunctionException(nameof(SubscriptionResourceId), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

                    string[] name = new string[nameDepth];
                    System.Array.Copy(segments, i + 1, name, 0, nameDepth);
                    nameParts = string.Join("/", name);
                }
            }
            return string.Concat("/subscriptions/", subscriptionId, "/providers/", resourceType, "/", nameParts);
        }

        /// <summary>
        /// tenantResourceId(resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object TenantResourceId(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(TenantResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out string value))
                    throw ArgumentFormatInvalid(nameof(TenantResourceId));

                segments[i] = value;
            }

            string resourceType = null;
            string nameParts = null;

            for (var i = 0; resourceType == null && i < segments.Length; i++)
            {
                if (segments[i].Contains('/'))
                {
                    resourceType = TrimResourceType(segments[i]);
                    var nameDepth = resourceType.Split('/').Length - 1;

                    if ((segments.Length - 1 - i) != nameDepth)
                        throw new TemplateFunctionException(nameof(TenantResourceId), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

                    string[] name = new string[nameDepth];
                    System.Array.Copy(segments, i + 1, name, 0, nameDepth);
                    nameParts = string.Join("/", name);
                }
            }
            return string.Concat("/providers/", resourceType, "/", nameParts);
        }

        #endregion Resource

        #region Numeric

        internal static object Add(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Add), args);

            if (!ExpressionHelpers.TryConvertInt(args[0], out int operand1))
                throw ArgumentInvalidInteger(nameof(Add), "operand1");

            if (!ExpressionHelpers.TryConvertInt(args[1], out int operand2))
                throw ArgumentInvalidInteger(nameof(Add), "operand2");

            return operand1 + operand2;
        }

        internal static object CopyIndex(TemplateContext context, object[] args)
        {
            string loopName = CountArgs(args) >= 1 && args[0] is string svalue ? svalue : null;
            int offset = CountArgs(args) == 1 && (args[0] is int ivalue || (args[0] is string sivalue && int.TryParse(sivalue, out ivalue))) ? ivalue : 0;
            if (CountArgs(args) == 2 && offset == 0 && (args[1] is int ivalue2 || (args[1] is string sivalue2 && int.TryParse(sivalue2, out ivalue2))))
                offset = ivalue2;

            if (!context.CopyIndex.TryGetValue(loopName, out TemplateContext.CopyIndexState value))
                throw new ArgumentException();

            return offset + value.Index;
        }

        internal static object Div(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Div), args);

            if (!ExpressionHelpers.TryConvertInt(args[0], out int operand1))
                throw ArgumentInvalidInteger(nameof(Div), "operand1");

            if (!ExpressionHelpers.TryConvertInt(args[1], out int operand2))
                throw ArgumentInvalidInteger(nameof(Div), "operand2");

            if (operand2 == 0)
                throw new DivideByZeroException();

            return operand1 / operand2;
        }

        internal static object Float(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Float), args);

            if (ExpressionHelpers.TryConvertInt(args[0], out int ivalue))
                return (float)ivalue;
            else if (ExpressionHelpers.TryString(args[0], out string svalue))
                return float.Parse(svalue, new CultureInfo("en-us"));

            throw ArgumentInvalidInteger(nameof(Float), "valueToConvert");
        }

        internal static object Int(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Int), args);

            if (ExpressionHelpers.TryConvertInt(args[0], out int value))
                return value;

            throw ArgumentInvalidInteger(nameof(Int), "valueToConvert");
        }

        internal static object Mod(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Mod), args);

            if (!ExpressionHelpers.TryConvertInt(args[0], out int operand1))
                throw ArgumentInvalidInteger(nameof(Mod), "operand1");

            if (!ExpressionHelpers.TryConvertInt(args[1], out int operand2))
                throw ArgumentInvalidInteger(nameof(Mod), "operand2");

            if (operand2 == 0)
                throw new DivideByZeroException();

            return operand1 % operand2;
        }

        internal static object Mul(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Mul), args);

            if (!ExpressionHelpers.TryConvertInt(args[0], out int operand1))
                throw ArgumentInvalidInteger(nameof(Mul), "operand1");

            if (!ExpressionHelpers.TryConvertInt(args[1], out int operand2))
                throw ArgumentInvalidInteger(nameof(Mul), "operand2");

            return operand1 * operand2;
        }

        internal static object Sub(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Sub), args);

            if (!ExpressionHelpers.TryConvertInt(args[0], out int operand1))
                throw ArgumentInvalidInteger(nameof(Sub), "operand1");

            if (!ExpressionHelpers.TryConvertInt(args[1], out int operand2))
                throw ArgumentInvalidInteger(nameof(Sub), "operand2");

            return operand1 - operand2;
        }

        #endregion Numeric

        #region Comparison

        /// <summary>
        /// equals(arg1, arg2)
        /// </summary>
        internal static object Equals(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Equals), args);

            // One null
            if (args[0] == null || args[1] == null)
                return args[0] == args[1];

            // Arrays
            if (args[0] is Array array1 && args[1] is Array array2)
                return SequenceEqual(array1, array2);
            else if (args[0] is Array || args[1] is Array)
                return false;

            // String and int
            if (args[0] is string s1 && args[1] is string s2)
                return s1 == s2;
            else if (args[0] is string || args[1] is string)
                return false;
            else if (args[0] is int i1 && args[1] is int i2)
                return i1 == i2;
            else if (args[0] is int || args[1] is int)
                return false;

            // Objects
            return ObjectEquals(args[0], args[1]);
        }

        /// <summary>
        /// greater(arg1, arg2)
        /// </summary>
        internal static object Greater(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Greater), args);

            return Compare(args[0], args[1]) > 0;
        }


        /// <summary>
        /// greaterOrEquals(arg1, arg2)
        /// </summary>
        internal static object GreaterOrEquals(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(GreaterOrEquals), args);

            return Compare(args[0], args[1]) >= 0;
        }


        /// <summary>
        /// less(arg1, arg2)
        /// </summary>
        internal static object Less(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Less), args);

            return Compare(args[0], args[1]) < 0;
        }

        /// <summary>
        /// lessOrEquals(arg1, arg2)
        /// </summary>
        internal static object LessOrEquals(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(LessOrEquals), args);

            return Compare(args[0], args[1]) <= 0;
        }

        #endregion Comparison

        #region Logical

        /// <summary>
        /// and(arg1, arg2, ...)
        /// </summary>
        internal static object And(TemplateContext context, object[] args)
        {
            if (args == null || args.Length < 2)
                throw ArgumentsOutOfRange(nameof(And), args);

            var bools = new bool[args.Length];
            args.CopyTo(bools, 0);
            for (var i = 0; i < bools.Length; i++)
            {
                if (!bools[i])
                    return false;
            }
            return true;
        }

        /// <summary>
        /// bool(arg1)
        /// </summary>
        internal static object Bool(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Bool), args);

            if (args[0] is string svalue)
                return bool.Parse(svalue);
            else if (args[0] is int ivalue)
                return ivalue > 0;

            return false;
        }

        /// <summary>
        /// if(condition, trueValue, falseValue)
        /// </summary>
        internal static object If(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 3)
                throw ArgumentsOutOfRange(nameof(If), args);

            return args[0] is bool condition && condition == true ? args[1] : args[2];
        }

        /// <summary>
        /// not(arg1)
        /// </summary>
        internal static object Not(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Not), args);

            return !(bool)args[0];
        }

        /// <summary>
        /// or(arg1, arg2, ...)
        /// </summary>
        internal static object Or(TemplateContext context, object[] args)
        {
            if (args == null || args.Length < 2)
                throw ArgumentsOutOfRange(nameof(Or), args);

            var bools = new bool[args.Length];
            args.CopyTo(bools, 0);
            for (var i = 0; i < bools.Length; i++)
            {
                if (bools[i])
                    return true;
            }
            return false;
        }

        #endregion Logical

        #region String

        internal static object Base64(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64), args);

            if (!ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentException();

            return Convert.ToBase64String(Encoding.UTF8.GetBytes(value));
        }

        internal static object Base64ToJson(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64ToJson), args);

            if (!ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentException();

            return JObject.Parse(Encoding.UTF8.GetString(Convert.FromBase64String(value)));
        }

        internal static object Base64ToString(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64ToString), args);

            if (!ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentException();

            return Encoding.UTF8.GetString(Convert.FromBase64String(value));
        }

        internal static object DataUri(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(DataUri), args);

            if (!ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentException();

            return string.Concat("data:text/plain;charset=utf8;base64,", Convert.ToBase64String(Encoding.UTF8.GetBytes(value)));
        }

        internal static object DataUriToString(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(DataUriToString), args);

            if (!ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentException();

            var scheme = value.Substring(0, 5);
            if (scheme != "data:")
                throw new ArgumentException();

            var dataStart = value.IndexOf(',');
            var mediaType = value.Substring(5, dataStart - 5);
            var base64 = false;
            if (mediaType.EndsWith(";base64", ignoreCase: true, culture: AzureCulture))
            {
                base64 = true;
                mediaType = mediaType.Remove(mediaType.Length - 7);
            }
            var encoding = Encoding.UTF8;
            var data = value.Substring(dataStart + 1);
            return base64 ? encoding.GetString(Convert.FromBase64String(data)) : data;
        }

        internal static object EndsWith(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2 || !ExpressionHelpers.TryString(args[0], out string s1) || !ExpressionHelpers.TryString(args[1], out string s2))
                throw new ArgumentOutOfRangeException();

            return s1.EndsWith(s2, StringComparison.OrdinalIgnoreCase);
        }

        internal static object Format(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Format), args);

            if (!ExpressionHelpers.TryString(args[0], out string formatString))
                throw new ArgumentException();

            var remaining = new object[args.Length - 1];
            System.Array.Copy(args, 1, remaining, 0, remaining.Length);
            return string.Format(AzureCulture, formatString, remaining);
        }

        internal static object Guid(TemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(Guid), args);

            var hash = GetUnique(args);
            var guidBytes = new byte[16];
            System.Array.Copy(hash, 0, guidBytes, 0, 16);
            return new Guid(guidBytes).ToString();
        }

        internal static object IndexOf(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(IndexOf), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToSearch))
                throw new ArgumentException();

            if (!ExpressionHelpers.TryString(args[1], out string stringToFind))
                throw new ArgumentException();

            return stringToSearch.IndexOf(stringToFind, StringComparison.OrdinalIgnoreCase);
        }

        internal static object LastIndexOf(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(LastIndexOf), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToSearch))
                throw new ArgumentException();

            if (!ExpressionHelpers.TryString(args[1], out string stringToFind))
                throw new ArgumentException();

            return stringToSearch.LastIndexOf(stringToFind, StringComparison.OrdinalIgnoreCase);
        }

        internal static object NewGuid(TemplateContext context, object[] args)
        {
            if (!(args == null || args.Length == 0))
                throw ArgumentsOutOfRange(nameof(NewGuid), args);

            return System.Guid.NewGuid().ToString();
        }

        internal static object PadLeft(TemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 2 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(PadLeft), args);

            string paddingCharacter = " ";

            if (!ExpressionHelpers.TryInt(args[1], out int totalLength))
                throw ArgumentInvalidInteger(nameof(PadLeft), "totalLength");

            if (argCount == 3 && (!ExpressionHelpers.TryString(args[2], out paddingCharacter) || paddingCharacter.Length > 1))
                throw new ArgumentException();

            if (ExpressionHelpers.TryString(args[0], out string svalue))
                return svalue.PadLeft(totalLength, paddingCharacter[0]);
            else if (ExpressionHelpers.TryInt(args[1], out int ivalue))
                return ivalue.ToString(new CultureInfo("en-us")).PadLeft(totalLength, paddingCharacter[0]);

            throw new ArgumentException();
        }

        internal static object StartsWith(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2 || !ExpressionHelpers.TryString(args[0], out string s1) || !ExpressionHelpers.TryString(args[1], out string s2))
                throw new ArgumentOutOfRangeException();

            return s1.StartsWith(s2, StringComparison.OrdinalIgnoreCase);
        }

        internal static object String(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(String), args);

            return JsonConvert.SerializeObject(args[0]);
        }

        internal static object Substring(TemplateContext context, object[] args)
        {
            if (args == null || args.Length < 1 || args.Length > 3 || !ExpressionHelpers.TryString(args[0], out string value))
                throw ArgumentsOutOfRange(nameof(Substring), args);

            if (args.Length == 2 && ExpressionHelpers.TryInt(args[1], out int startIndex))
                return value.Substring(startIndex);
            else if (args.Length == 3 && ExpressionHelpers.TryInt(args[1], out int startIndex2) && ExpressionHelpers.TryInt(args[2], out int length))
                return value.Substring(startIndex2, length);

            throw ArgumentFormatInvalid(nameof(Substring));
        }

        internal static object ToLower(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(ToLower), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToChange))
                throw new ArgumentException();

            return stringToChange.ToLower(AzureCulture);
        }

        internal static object ToUpper(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(ToUpper), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToChange))
                throw new ArgumentException();

            return stringToChange.ToUpper(AzureCulture);
        }

        internal static object Trim(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Trim), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToTrim))
                throw new ArgumentException();

            return stringToTrim.Trim();
        }

        internal static object UniqueString(TemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(UniqueString), args);

            var hash = GetUnique(args);
            var builder = new StringBuilder();
            var culture = new CultureInfo("en-us");
            for (int i = 0; i < hash.Length && i < 7; i++)
            {
                builder.Append(hash[i].ToString("x2", culture));
            }
            return builder.ToString().Substring(0, 13);
        }

        internal static object Uri(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Uri), args);

            if (!ExpressionHelpers.TryString(args[0], out string baseUri))
                throw new ArgumentException(PSRuleResources.FunctionInvalidString, "baseUri");

            if (!ExpressionHelpers.TryString(args[1], out string relativeUri))
                throw new ArgumentException(PSRuleResources.FunctionInvalidString, "relativeUri");

            var result = new Uri(new Uri(baseUri), relativeUri);
            return result.ToString();
        }

        internal static object UriComponent(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(UriComponent), args);

            if (!ExpressionHelpers.TryString(args[0], out string stringToEncode))
                throw new ArgumentException(PSRuleResources.FunctionInvalidString, "stringToEncode");

            return HttpUtility.UrlEncode(stringToEncode);
        }

        internal static object UriComponentToString(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(UriComponentToString), args);

            if (!ExpressionHelpers.TryString(args[0], out string uriEncodedString))
                throw new ArgumentException(PSRuleResources.FunctionInvalidString, "uriEncodedString");

            return HttpUtility.UrlDecode(uriEncodedString);
        }

        internal static object UtcNow(TemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (CountArgs(args) > 1)
                throw ArgumentsOutOfRange(nameof(UtcNow), args);

            var format = "yyyyMMddTHHmmssZ";
            if (argCount == 1 && !ExpressionHelpers.TryString(args[0], out format))
                throw new ArgumentException(PSRuleResources.FunctionInvalidString, "format");

            return DateTime.UtcNow.ToString(format, AzureCulture);
        }

        internal static object Replace(TemplateContext context, object[] args)
        {
            if (CountArgs(args) != 3)
                throw ArgumentsOutOfRange(nameof(Replace), args);

            if (!ExpressionHelpers.TryString(args[0], out string originalString) || !ExpressionHelpers.TryString(args[1], out string oldString) || !ExpressionHelpers.TryString(args[2], out string newString))
                throw new ArgumentException();

            return originalString.Replace(oldString, newString);
        }

        internal static object Split(TemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2 || !ExpressionHelpers.TryString(args[0], out string value))
                throw new ArgumentOutOfRangeException();

            string[] delimiter = null;

            if (ExpressionHelpers.TryString(args[1], out string single))
            {
                delimiter = new string[] { single };
            }
            else if (args[1] is Array delimiters)
            {
                delimiter = new string[delimiters.Length];
                delimiters.CopyTo(delimiter, 0);
            }
            else if (TryJArray(args[1], out JArray jArray))
            {
                delimiter = jArray.Values<string>().ToArray();
            }
            else
                throw new ArgumentException();

            return new JArray(value.Split(delimiter, StringSplitOptions.None));
        }

        #endregion String

        #region Helper functions

        private static int Compare(object left, object right)
        {
            return Comparer.Default.Compare(left, right);
        }

        private static bool SequenceEqual(Array array1, Array array2)
        {
            if (array1.Length != array2.Length)
                return false;

            for (var i = 0; i < array1.Length; i++)
            {
                if (array1.GetValue(i) != array2.GetValue(i))
                    return false;
            }
            return true;
        }

        private static bool ObjectEquals(object o1, object o2)
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

        private static bool IsNull(object o)
        {
            return o == null || (o is JToken token && token.Type == JTokenType.Null);
        }

        private static bool IsString(object o)
        {
            return o is string || (o is JToken token && token.Type == JTokenType.String);
        }

        private static bool TryJArray(object o, out JArray value)
        {
            value = null;
            if (o is JArray jArray)
            {
                value = jArray;
                return true;
            }
            return false;
        }

        private static bool TryJObject(object o, out JObject value)
        {
            value = null;
            if (o is JObject jObject)
            {
                value = jObject;
                return true;
            }
            return false;
        }

        private static bool Contains(Array array, object o)
        {
            var objectToFind = o;
            if (objectToFind is JToken jToken)
                objectToFind = jToken.Value<object>();

            for (var i = 0; i < array.Length; i++)
            {
                if (ObjectEquals(array.GetValue(i), objectToFind))
                    return true;
            }
            return false;
        }

        private static int CountArgs(object[] args)
        {
            return args == null ? 0 : args.Length;
        }

        private static byte[] GetUnique(object[] args)
        {
            // Not actual hash algorithm used in Azure
            using (var algorithm = SHA256.Create())
            {
                byte[] url_uid = new Guid("6ba7b811-9dad-11d1-80b4-00c04fd430c8").ToByteArray();
                algorithm.TransformBlock(url_uid, 0, url_uid.Length, null, 0);

                for (var i = 0; i < args.Length; i++)
                {
                    if (ExpressionHelpers.TryString(args[i], out string svalue))
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

        private static string TrimResourceType(string resourceType)
        {
            return resourceType[resourceType.Length - 1] == '/' ? resourceType = resourceType.Substring(0, resourceType.Length - 1) : resourceType;
        }

        #endregion Helper functions

        #region Exceptions

        private static ExpressionArgumentException ArgumentsOutOfRange(string expression, object[] args)
        {
            var length = args == null ? 0 : args.Length;
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentsOutOfRange, expression, length)
            );
        }

        private static ExpressionArgumentException ArgumentFormatInvalid(string expression)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentFormatInvalid, expression)
            );
        }

        private static ExpressionArgumentException ArgumentInvalidInteger(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidInteger, operand, expression)
            );
        }

        #endregion Exceptions
    }
}
