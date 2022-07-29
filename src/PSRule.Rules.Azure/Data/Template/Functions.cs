// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Xml;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// Implementation of Azure Resource Manager template functions as ExpressionFn.
    /// </summary>
    internal static class Functions
    {
        private const string PROPERTY_FULL = "Full";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_RESOURCETYPE = "resourceType";
        private const string PROPERTY_PROVIDERNAMESPACE = "providerNamespace";
        private const string PROPERTY_LOCATION = "location";
        private const string PROPERTY_NUMBEROFZONES = "numberOfZones";
        private const string PROPERTY_OFFSET = "offset";
        private const string PROPERTY_OPERAND1 = "operand1";
        private const string PROPERTY_OPERAND2 = "operand2";
        private const string PROPERTY_VALUETOCONVERT = "valueToConvert";
        private const string FORMAT_ISO8601 = "yyyy-MM-ddTHH:mm:ssZ";

        internal readonly static IFunctionDescriptor[] Builtin = new IFunctionDescriptor[]
        {
            // Array and object
            new FunctionDescriptor("array", Array),
            new FunctionDescriptor("concat", Concat),
            new FunctionDescriptor("contains", Contains),
            new FunctionDescriptor("createArray", CreateArray),
            new FunctionDescriptor("createObject", CreateObject),
            new FunctionDescriptor("empty", Empty),
            new FunctionDescriptor("first", First),
            new FunctionDescriptor("intersection", Intersection),
            new FunctionDescriptor("items", Items),
            new FunctionDescriptor("last", Last),
            new FunctionDescriptor("length", Length),
            new FunctionDescriptor("min", Min),
            new FunctionDescriptor("max", Max),
            new FunctionDescriptor("range", Range),
            new FunctionDescriptor("skip", Skip),
            new FunctionDescriptor("take", Take),
            new FunctionDescriptor("union", Union),

            // Comparison
            new FunctionDescriptor("coalesce", Coalesce),
            new FunctionDescriptor("equals", Equals),
            new FunctionDescriptor("greater", Greater),
            new FunctionDescriptor("greaterOrEquals", GreaterOrEquals),
            new FunctionDescriptor("less", Less),
            new FunctionDescriptor("lessOrEquals", LessOrEquals),

            // Date
            new FunctionDescriptor("dateTimeAdd", DateTimeAdd),
            new FunctionDescriptor("dateTimeFromEpoch", DateTimeFromEpoch),
            new FunctionDescriptor("dateTimeToEpoch", DateTimeToEpoch),
            new FunctionDescriptor("utcNow", UtcNow),

            // Deployment
            new FunctionDescriptor("deployment", Deployment),
            new FunctionDescriptor("environment", Environment),
            new FunctionDescriptor("parameters", Parameters),
            new FunctionDescriptor("variables", Variables),

            // Logical
            new FunctionDescriptor("and", And, delayBinding: true),
            new FunctionDescriptor("bool", Bool),
            new FunctionDescriptor("false", False),
            new FunctionDescriptor("if", If, delayBinding: true),
            new FunctionDescriptor("not", Not),
            new FunctionDescriptor("or", Or),
            new FunctionDescriptor("true", True),

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

            // Object
            new FunctionDescriptor("json", Json),
            new FunctionDescriptor("null", Null),

            // Resource
            new FunctionDescriptor("extensionResourceId", ExtensionResourceId),
            new FunctionDescriptor("list", List), // Includes listAccountSas, listKeys, listSecrets, list*
            new FunctionDescriptor("pickZones", PickZones),
            new FunctionDescriptor("providers", Providers),
            new FunctionDescriptor("reference", Reference),
            new FunctionDescriptor("resourceId", ResourceId),
            new FunctionDescriptor("subscriptionResourceId", SubscriptionResourceId),
            new FunctionDescriptor("tenantResourceId", TenantResourceId),

            // Scope
            new FunctionDescriptor("resourceGroup", ResourceGroup),
            new FunctionDescriptor("subscription", Subscription),
            new FunctionDescriptor("tenant", Tenant),
            new FunctionDescriptor("managementGroup", ManagementGroup),

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
            new FunctionDescriptor("join", Join),
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
        };

        private static readonly CultureInfo AzureCulture = new CultureInfo("en-US");

        #region Array and object

        /// <summary>
        /// array(convertToArray)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-array#array
        /// </remarks>
        internal static object Array(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Array), args);

            if (ExpressionHelpers.TryArray(args[0], out object o))
                return o;

            if (ExpressionHelpers.TryJToken(args[0], out var token))
                return new JArray(token);

            return new object[] { args[0] };
        }

        internal static object Coalesce(ITemplateContext context, object[] args)
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

        internal static object Concat(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(Concat), args);

            // String
            if (ExpressionHelpers.TryConvertStringArray(args, out var s))
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

        internal static object Empty(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Empty), args);

            if (args[0] == null)
                return true;
            else if (args[0] is Array aValue)
                return aValue.Length == 0;
            else if (TryJArray(args[0], out var jArray))
                return jArray.Count == 0;
            else if (ExpressionHelpers.TryString(args[0], out var sValue))
                return string.IsNullOrEmpty(sValue);
            else if (TryJObject(args[0], out var jObject))
                return !jObject.Properties().Any();

            return false;
        }

        internal static object Contains(ITemplateContext context, object[] args)
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

        /// <summary>
        /// createArray (arg1, arg2, arg3, ...)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-array#createarray
        /// </remarks>
        internal static object CreateArray(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length == 0)
                return new JArray();

            var array = new JArray();
            for (var i = 0; i < args.Length; i++)
                array.Add(ExpressionHelpers.GetJToken(args[i]));

            return array;
        }

        /// <summary>
        /// createObject(key1, value1, key2, value2, ...)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-object#createobject
        /// </remarks>
        internal static object CreateObject(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount % 2 != 0)
                throw ArgumentsOutOfRange(nameof(CreateObject), args);

            var properties = new JProperty[argCount / 2];
            for (var i = 0; i < argCount / 2; i++)
            {
                if (!ExpressionHelpers.TryString(args[i * 2], out var name))
                    throw ArgumentInvalidString(nameof(CreateObject), $"key{i + 1}");

                properties[i] = new JProperty(name, ExpressionHelpers.GetJToken(args[i * 2 + 1]));
            }
            return new JObject(properties);
        }

        internal static object First(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(First), args);

            if (args[0] is Array avalue)
                return avalue.GetValue(0);
            else if (args[0] is JArray jArray)
                return jArray[0];
            else if (ExpressionHelpers.TryString(args[0], out var svalue))
                return new string(svalue[0], 1);

            return null;
        }

        internal static object Intersection(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Intersection), args);

            // Array
            if (args[0] is JArray jArray)
            {
                IEnumerable<JToken> intersection = jArray;
                for (var i = 1; i < args.Length; i++)
                {
                    if (!TryJArray(args[i], out var value))
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
                    if (!TryJObject(args[i], out var value))
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

        /// <summary>
        /// items(object)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-object#items
        /// </remarks>
        internal static object Items(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Items), args);

            if (ExpressionHelpers.TryJObject(args[0], out var jObject))
            {
                var result = new JArray();
                foreach (var item in jObject.Properties().OrderBy(p => p.Name))
                {
                    var i = new JObject();
                    i.Add("key", item.Name);
                    i.Add("value", item.Value);
                    result.Add(i);
                }
                return result;
            }
            return new JArray();
        }

        internal static object Json(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1 || !ExpressionHelpers.TryString(args[0], out var json))
                throw ArgumentsOutOfRange(nameof(Json), args);

            return JsonConvert.DeserializeObject(json);
        }

        /// <summary>
        /// null()
        /// </summary>
        internal static object Null(ITemplateContext context, object[] args)
        {
            return CountArgs(args) > 0 ? throw ArgumentsOutOfRange(nameof(Null), args) : (object)null;
        }

        internal static object Last(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Last), args);

            if (args[0] is Array avalue)
                return avalue.GetValue(avalue.Length - 1);
            else if (args[0] is JArray jArray)
                return jArray[jArray.Count - 1];
            else if (ExpressionHelpers.TryString(args[0], out var svalue))
                return new string(svalue[svalue.Length - 1], 1);

            return null;
        }

        internal static object Length(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Length), args);

            if (ExpressionHelpers.TryString(args[0], out var s))
                return (long)s.Length;
            else if (args[0] is Array a)
                return (long)a.Length;
            else if (args[0] is JArray jArray)
                return (long)jArray.Count;

            return (long)args[0].GetType().GetProperties().Length;
        }

        internal static object Min(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(Min), args);

            long? result = null;
            for (var i = 0; i < args.Length; i++)
            {
                if (ExpressionHelpers.TryLong(args[i], out var value))
                {
                    result = !result.HasValue || value < result ? value : result;
                }
                // Enumerate array arg
                else if (TryJArray(args[i], out var array))
                {
                    for (var j = 0; j < array.Count; j++)
                    {
                        if (ExpressionHelpers.TryLong(array[j], out value))
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

        internal static object Max(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(Max), args);

            long? result = null;
            for (var i = 0; i < args.Length; i++)
            {
                if (ExpressionHelpers.TryLong(args[i], out var value))
                {
                    result = !result.HasValue || value > result ? value : result;
                }
                // Enumerate array arg
                else if (TryJArray(args[i], out var array))
                {
                    for (var j = 0; j < array.Count; j++)
                    {
                        if (ExpressionHelpers.TryLong(array[j], out value))
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

        internal static object Range(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Range), args);

            if (!ExpressionHelpers.TryLong(args[0], out var startIndex))
                throw ArgumentInvalidInteger(nameof(Range), nameof(startIndex));

            if (!ExpressionHelpers.TryLong(args[1], out var count))
                throw ArgumentInvalidInteger(nameof(Range), nameof(count));

            var result = new long[count];
            for (var i = 0; i < count; i++)
                result[i] = startIndex++;

            return new JArray(result);
        }

        internal static object Skip(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Skip), args);

            if (!ExpressionHelpers.TryInt(args[1], out var numberToSkip))
                throw ArgumentInvalidInteger(nameof(Skip), nameof(numberToSkip));

            var skip = numberToSkip <= 0 ? 0 : numberToSkip;
            if (ExpressionHelpers.TryString(args[0], out var soriginalValue))
            {
                return skip >= soriginalValue.Length ? string.Empty : soriginalValue.Substring(skip);
            }
            else if (TryJArray(args[0], out var aoriginalvalue))
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

        internal static object Take(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Take), args);

            if (!ExpressionHelpers.TryInt(args[1], out var numberToTake))
                throw new ArgumentException();

            var take = numberToTake <= 0 ? 0 : numberToTake;
            if (ExpressionHelpers.TryString(args[0], out var soriginalValue))
            {
                if (take <= 0)
                    return string.Empty;

                take = take > soriginalValue.Length ? soriginalValue.Length : take;
                return soriginalValue.Substring(0, take);
            }
            else if (TryJArray(args[0], out var aoriginalvalue))
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

        internal static object Union(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Union), args);

            // Array
            if (ExpressionHelpers.IsArray(args[0]))
                return ExpressionHelpers.UnionArray(args);

            // Object
            if (ExpressionHelpers.IsObject(args[0]))
                return ExpressionHelpers.UnionObject(args);

            return null;
        }

        #endregion Array and object

        #region Deployment

        /// <summary>
        /// deployment()
        /// </summary>
        internal static object Deployment(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Deployment), args);

            return context.Deployment;
        }

        /// <summary>
        /// environment()
        /// </summary>
        internal static object Environment(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Environment), args);

            return JObject.FromObject(context.GetEnvironment());
        }

        /// <summary>
        /// parameters(parameterName)
        /// </summary>
        internal static object Parameters(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Parameters), args);

            if (!ExpressionHelpers.TryString(args[0], out var parameterName))
                throw ArgumentFormatInvalid(nameof(Parameters));

            if (!context.TryParameter(parameterName, out var result))
                throw new KeyNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterNotFound, parameterName));

            return result;
        }

        /// <summary>
        /// variables(variableName)
        /// </summary>
        internal static object Variables(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Variables), args);

            if (!ExpressionHelpers.TryString(args[0], out var variableName))
                throw ArgumentFormatInvalid(nameof(Variables));

            if (!context.TryVariable(variableName, out var result))
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
        internal static object ExtensionResourceId(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 3)
                throw ArgumentsOutOfRange(nameof(ExtensionResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out var value))
                    throw ArgumentFormatInvalid(nameof(ExtensionResourceId));

                segments[i] = value;
            }

            var resourceId = segments[0];
            if (!segments[1].Contains('/'))
                throw ArgumentFormatInvalid(nameof(ExtensionResourceId));

            GetResourceIdParts(segments, 1, out var resourceType, out var name);
            if (resourceType.Length != name.Length)
                throw MismatchingResourceSegments(nameof(ExtensionResourceId));

            return string.Concat(resourceId, ResourceHelper.CombineResourceId(null, null, resourceType, name));
        }

        /// <summary>
        /// list{Value}(resourceName or resourceIdentifier, apiVersion, functionValues)
        /// </summary>
        internal static object List(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 2 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(List), args);

            ExpressionHelpers.TryString(args[0], out var resourceId);
            return new MockList(resourceId);
        }

        /// <summary>
        /// pickZones(providerNamespace, resourceType, location, [numberOfZones], [offset])
        /// </summary>
        internal static object PickZones(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 3 || argCount > 5)
                throw ArgumentsOutOfRange(nameof(PickZones), args);

            if (!ExpressionHelpers.TryString(args[0], out var providerNamespace))
                throw ArgumentInvalidString(nameof(PickZones), PROPERTY_PROVIDERNAMESPACE);

            if (!ExpressionHelpers.TryString(args[1], out var resourceType))
                throw ArgumentInvalidString(nameof(PickZones), PROPERTY_RESOURCETYPE);

            if (!ExpressionHelpers.TryString(args[2], out var location))
                throw ArgumentInvalidString(nameof(PickZones), PROPERTY_LOCATION);

            var numberOfZones = 1;
            if (argCount > 3 && !ExpressionHelpers.TryInt(args[3], out numberOfZones))
                throw ArgumentInvalidInteger(nameof(PickZones), PROPERTY_NUMBEROFZONES);

            var offset = 0;
            if (argCount > 4 && !ExpressionHelpers.TryInt(args[4], out offset))
                throw ArgumentInvalidInteger(nameof(PickZones), PROPERTY_OFFSET);

            var resourceTypes = context.GetResourceType(providerNamespace, resourceType);
            if (resourceTypes == null || resourceTypes.Length == 0)
                throw ArgumentInvalidResourceType(nameof(PickZones), providerNamespace, resourceType);

            if (resourceTypes[0].ZoneMappings == null || resourceTypes[0].ZoneMappings.Length == 0)
                return new JArray();

            var mapping = resourceTypes[0].ZoneMappings.Where(z => LocationHelper.Equal(location, z.Location)).FirstOrDefault();
            if (mapping.Zones.Length == 0)
                return new JArray();

            if (mapping.Zones.Length < numberOfZones + offset)
                throw ArgumentsOutOfRange(nameof(PickZones), args);

            var zones = mapping.Zones.Skip(offset).Take(numberOfZones).ToArray();
            return new JArray(zones);
        }

        internal static object Providers(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 1 || argCount > 2)
                throw ArgumentsOutOfRange(nameof(Providers), args);

            if (!ExpressionHelpers.TryString(args[0], out var providerNamespace))
                throw ArgumentFormatInvalid(nameof(Providers));

            string resourceType = null;
            if (argCount > 1 && !ExpressionHelpers.TryString(args[1], out resourceType))
                throw ArgumentFormatInvalid(nameof(Providers));

            var resourceTypes = context.GetResourceType(providerNamespace, resourceType);
            if (resourceType == null)
                return resourceTypes;

            if (resourceTypes == null || resourceTypes.Length == 0)
                throw ArgumentInvalidResourceType(nameof(Providers), providerNamespace, resourceType);

            return resourceTypes[0];
        }

        /// <summary>
        /// reference(resourceName or resourceIdentifier, [apiVersion], ['Full'])
        /// </summary>
        internal static object Reference(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 1 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(Reference), args);

            // Resource type
            if (!ExpressionHelpers.TryString(args[0], out var resourceId))
                throw ArgumentFormatInvalid(nameof(Reference));

            var full = argCount == 3 && ExpressionHelpers.TryString(args[2], out var fullValue) && string.Equals(fullValue, PROPERTY_FULL, StringComparison.OrdinalIgnoreCase);
            if (argCount == 3 && !full)
                throw ArgumentFormatInvalid(nameof(Reference));

            // If the resource is part of the deployment try to get the object
            return context.TryGetResource(resourceId, out var resourceValue)
                ? GetReferenceResult(resourceValue, full)
                : new MockResource(resourceId);
        }

        private static object GetReferenceResult(IResourceValue resource, bool full)
        {
            if (resource is DeploymentValue deployment)
                return full ? deployment : deployment.Properties;

            if (!full && resource.Value.TryGetProperty<JObject>(PROPERTY_PROPERTIES, out var properties))
                return new MockObject(properties);

            return new MockObject(full ? resource.Value : new JObject());
        }

        /// <summary>
        /// resourceId([subscriptionId], [resourceGroupName], resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object ResourceId(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(ResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out var value))
                    throw ArgumentFormatInvalid(nameof(ResourceId));

                segments[i] = value;
            }

            // Copy segments
            var start = FindResourceTypePart(segments);
            var subscriptionId = start == 2 ? segments[0] : context.Subscription.SubscriptionId;
            var resourceGroup = start >= 1 ? segments[start - 1] : context.ResourceGroup.Name;
            GetResourceIdParts(segments, start, out var resourceType, out var name);
            if (resourceType.Length != name.Length)
                throw MismatchingResourceSegments(nameof(ResourceId));

            return ResourceHelper.CombineResourceId(subscriptionId, resourceGroup, resourceType, name);
        }

        /// <summary>
        /// subscriptionResourceId([subscriptionId], resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /subscriptions/{subscriptionId}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object SubscriptionResourceId(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(SubscriptionResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out var value))
                    throw ArgumentFormatInvalid(nameof(SubscriptionResourceId));

                segments[i] = value;
            }

            // Copy segements
            var start = FindResourceTypePart(segments);
            var subscriptionId = start == 1 ? segments[0] : context.Subscription.SubscriptionId;
            GetResourceIdParts(segments, start, out var resourceType, out var name);
            if (resourceType.Length != name.Length)
                throw MismatchingResourceSegments(nameof(SubscriptionResourceId));

            return ResourceHelper.CombineResourceId(subscriptionId, null, resourceType, name);
        }

        /// <summary>
        /// tenantResourceId(resourceType, resourceName1, [resourceName2], ...)
        /// </summary>
        /// <returns>
        /// /providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
        /// </returns>
        internal static object TenantResourceId(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(TenantResourceId), args);

            var segments = new string[args.Length];
            for (var i = 0; i < segments.Length; i++)
            {
                if (!ExpressionHelpers.TryString(args[i], out var value))
                    throw ArgumentFormatInvalid(nameof(TenantResourceId));

                segments[i] = value;
            }

            // Copy segements
            var start = FindResourceTypePart(segments);
            GetResourceIdParts(segments, start, out var resourceType, out var name);
            if (resourceType.Length != name.Length)
                throw MismatchingResourceSegments(nameof(TenantResourceId));

            return ResourceHelper.CombineResourceId(null, null, resourceType, name);
        }

        #endregion Resource

        #region Scope

        /// <summary>
        /// resourceGroup()
        /// </summary>
        internal static object ResourceGroup(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(ResourceGroup), args);

            return context.ResourceGroup;
        }

        /// <summary>
        /// subscription()
        /// </summary>
        internal static object Subscription(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Subscription), args);

            return context.Subscription;
        }

        /// <summary>
        /// tenant()
        /// </summary>
        internal static object Tenant(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(Tenant), args);

            return context.Tenant;
        }

        /// <summary>
        /// managementGroup()
        /// </summary>
        internal static object ManagementGroup(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(ManagementGroup), args);

            return context.ManagementGroup;
        }

        #endregion Scope

        #region Numeric

        internal static object Add(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Add), args);

            if (!ExpressionHelpers.TryConvertLong(args[0], out var operand1))
                throw ArgumentInvalidInteger(nameof(Add), PROPERTY_OPERAND1);

            if (!ExpressionHelpers.TryConvertLong(args[1], out var operand2))
                throw ArgumentInvalidInteger(nameof(Add), PROPERTY_OPERAND2);

            return operand1 + operand2;
        }

        internal static object CopyIndex(ITemplateContext context, object[] args)
        {
            var loopName = CountArgs(args) >= 1 && ExpressionHelpers.TryString(args[0], out var svalue) ? svalue : null;
            var offset = CountArgs(args) == 1 && ExpressionHelpers.TryConvertInt(args[0], out var ivalue) ? ivalue : 0;
            if (CountArgs(args) == 2 && offset == 0 && ExpressionHelpers.TryConvertInt(args[1], out var ivalue2))
                offset = ivalue2;

            if (!context.CopyIndex.TryGetValue(loopName, out var value))
                throw new ArgumentException();

            return offset + value.Index;
        }

        internal static object Div(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Div), args);

            if (!ExpressionHelpers.TryConvertLong(args[0], out var operand1))
                throw ArgumentInvalidInteger(nameof(Div), PROPERTY_OPERAND1);

            if (!ExpressionHelpers.TryConvertLong(args[1], out var operand2))
                throw ArgumentInvalidInteger(nameof(Div), PROPERTY_OPERAND2);

            if (operand2 == 0)
                throw new DivideByZeroException();

            return operand1 / operand2;
        }

        internal static object Float(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Float), args);

            if (ExpressionHelpers.TryConvertLong(args[0], out var ivalue))
                return (float)ivalue;
            else if (ExpressionHelpers.TryString(args[0], out var svalue))
                return float.Parse(svalue, AzureCulture);

            throw ArgumentInvalidInteger(nameof(Float), PROPERTY_VALUETOCONVERT);
        }

        internal static object Int(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Int), args);

            if (ExpressionHelpers.TryConvertLong(args[0], out var value))
                return value;

            throw ArgumentInvalidInteger(nameof(Int), PROPERTY_VALUETOCONVERT);
        }

        internal static object Mod(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Mod), args);

            if (!ExpressionHelpers.TryConvertLong(args[0], out var operand1))
                throw ArgumentInvalidInteger(nameof(Mod), PROPERTY_OPERAND1);

            if (!ExpressionHelpers.TryConvertLong(args[1], out var operand2))
                throw ArgumentInvalidInteger(nameof(Mod), PROPERTY_OPERAND2);

            if (operand2 == 0)
                throw new DivideByZeroException();

            return operand1 % operand2;
        }

        internal static object Mul(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Mul), args);

            if (!ExpressionHelpers.TryConvertLong(args[0], out var operand1))
                throw ArgumentInvalidInteger(nameof(Mul), PROPERTY_OPERAND1);

            if (!ExpressionHelpers.TryConvertLong(args[1], out var operand2))
                throw ArgumentInvalidInteger(nameof(Mul), PROPERTY_OPERAND2);

            return operand1 * operand2;
        }

        internal static object Sub(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Sub), args);

            if (!ExpressionHelpers.TryConvertLong(args[0], out var operand1))
                throw ArgumentInvalidInteger(nameof(Sub), PROPERTY_OPERAND1);

            if (!ExpressionHelpers.TryConvertLong(args[1], out var operand2))
                throw ArgumentInvalidInteger(nameof(Sub), PROPERTY_OPERAND2);

            return operand1 - operand2;
        }

        #endregion Numeric

        #region Comparison

        /// <summary>
        /// equals(arg1, arg2)
        /// </summary>
        internal static object Equals(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Equals), args);

            return ExpressionHelpers.Equal(args[0], args[1]);
        }

        /// <summary>
        /// greater(arg1, arg2)
        /// </summary>
        internal static object Greater(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Greater), args);

            return Compare(args[0], args[1]) > 0;
        }


        /// <summary>
        /// greaterOrEquals(arg1, arg2)
        /// </summary>
        internal static object GreaterOrEquals(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(GreaterOrEquals), args);

            return Compare(args[0], args[1]) >= 0;
        }


        /// <summary>
        /// less(arg1, arg2)
        /// </summary>
        internal static object Less(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Less), args);

            return Compare(args[0], args[1]) < 0;
        }

        /// <summary>
        /// lessOrEquals(arg1, arg2)
        /// </summary>
        internal static object LessOrEquals(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(LessOrEquals), args);

            return Compare(args[0], args[1]) <= 0;
        }

        #endregion Comparison

        #region Date

        /// <summary>
        /// dateTimeAdd(base, duration, [format])
        /// </summary>
        internal static object DateTimeAdd(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 2 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(DateTimeAdd), args);

            if (!ExpressionHelpers.TryConvertDateTime(args[0], out var startTime))
                throw ArgumentInvalidString(nameof(DateTimeAdd), "base");

            if (!ExpressionHelpers.TryString(args[1], out var duration))
                throw ArgumentInvalidString(nameof(DateTimeAdd), nameof(duration));

            string format = null;
            if (argCount == 3 && !ExpressionHelpers.TryString(args[2], out format))
                throw ArgumentInvalidString(nameof(DateTimeAdd), nameof(format));

            var timeToAdd = XmlConvert.ToTimeSpan(duration);
            var result = startTime.Add(timeToAdd);
            return format == null ? result.ToString(AzureCulture) : result.ToString(format, AzureCulture);
        }

        /// <summary>
        /// dateTimeFromEpoch(epochTime)
        /// </summary>
        internal static object DateTimeFromEpoch(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount != 1)
                throw ArgumentsOutOfRange(nameof(DateTimeFromEpoch), args);

            if (!ExpressionHelpers.TryLong(args[0], out var epochTime))
                throw ArgumentInvalidInteger(nameof(DateTimeFromEpoch), nameof(epochTime));

            return DateTimeOffset.FromUnixTimeSeconds(epochTime).DateTime.ToString(FORMAT_ISO8601, AzureCulture);
        }

        /// <summary>
        /// dateTimeToEpoch(dateTime)
        /// </summary>
        internal static object DateTimeToEpoch(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount != 1)
                throw ArgumentsOutOfRange(nameof(DateTimeToEpoch), args);

            if (!ExpressionHelpers.TryConvertDateTime(args[0], out var dateTime))
                throw ArgumentInvalidDateTime(nameof(DateTimeToEpoch), nameof(dateTime));

            return new DateTimeOffset(dateTime).ToUnixTimeSeconds();
        }

        /// <summary>
        /// utcNow(format)
        /// </summary>
        internal static object UtcNow(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (CountArgs(args) > 1)
                throw ArgumentsOutOfRange(nameof(UtcNow), args);

            var format = "yyyyMMddTHHmmssZ";
            if (argCount == 1 && !ExpressionHelpers.TryString(args[0], out format))
                throw ArgumentInvalidString(nameof(UtcNow), nameof(format));

            return DateTime.UtcNow.ToString(format, AzureCulture);
        }

        #endregion Date

        #region Logical

        /// <summary>
        /// and(arg1, arg2, ...)
        /// </summary>
        internal static object And(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length < 2)
                throw ArgumentsOutOfRange(nameof(And), args);

            for (var i = 0; i < args.Length; i++)
            {
                var expression = GetExpression(context, args[i]);
                if (!ExpressionHelpers.TryBool(expression, out var bValue) || !bValue)
                    return false;
            }
            return true;
        }

        /// <summary>
        /// bool(arg1)
        /// </summary>
        internal static object Bool(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Bool), args);

            if (ExpressionHelpers.TryConvertBool(args[0], out var value))
                return value;

            throw ArgumentFormatInvalid(nameof(Bool));
        }

        /// <summary>
        /// false()
        /// </summary>
        internal static object False(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(False), args);

            return false;
        }

        /// <summary>
        /// if(condition, trueValue, falseValue)
        /// </summary>
        internal static object If(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 3)
                throw ArgumentsOutOfRange(nameof(If), args);

            var expression = GetExpression(context, args[0]);
            if (ExpressionHelpers.TryBool(expression, out var condition))
                return condition ? GetExpression(context, args[1]) : GetExpression(context, args[2]);

            throw ArgumentFormatInvalid(nameof(If));
        }

        /// <summary>
        /// not(arg1)
        /// </summary>
        internal static object Not(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(Not), args);

            if (!ExpressionHelpers.TryBool(args[0], out var value))
                throw ArgumentInvalidBoolean(nameof(Not), "arg1");

            return !value;
        }

        /// <summary>
        /// or(arg1, arg2, ...)
        /// </summary>
        internal static object Or(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length < 2)
                throw ArgumentsOutOfRange(nameof(Or), args);

            for (var i = 0; i < args.Length; i++)
            {
                if (ExpressionHelpers.TryBool(args[i], out var value) && value)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// true()
        /// </summary>
        internal static object True(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) > 0)
                throw ArgumentsOutOfRange(nameof(True), args);

            return true;
        }

        #endregion Logical

        #region String

        internal static object Base64(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64), args);

            if (!ExpressionHelpers.TryString(args[0], out var inputString))
                throw ArgumentInvalidString(nameof(Base64), nameof(inputString));

            return Convert.ToBase64String(Encoding.UTF8.GetBytes(inputString));
        }

        internal static object Base64ToJson(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64ToJson), args);

            if (!ExpressionHelpers.TryString(args[0], out var base64Value))
                throw ArgumentInvalidString(nameof(Base64ToJson), nameof(base64Value));

            return JObject.Parse(Encoding.UTF8.GetString(Convert.FromBase64String(base64Value)));
        }

        internal static object Base64ToString(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Base64ToString), args);

            if (!ExpressionHelpers.TryString(args[0], out var base64Value))
                throw ArgumentInvalidString(nameof(Base64ToString), nameof(base64Value));

            return Encoding.UTF8.GetString(Convert.FromBase64String(base64Value));
        }

        internal static object DataUri(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(DataUri), args);

            if (!ExpressionHelpers.TryString(args[0], out var value))
                throw new ArgumentException();

            return string.Concat("data:text/plain;charset=utf8;base64,", Convert.ToBase64String(Encoding.UTF8.GetBytes(value)));
        }

        internal static object DataUriToString(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(DataUriToString), args);

            if (!ExpressionHelpers.TryString(args[0], out var value))
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

        internal static object EndsWith(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2 || !ExpressionHelpers.TryString(args[0], out var s1) || !ExpressionHelpers.TryString(args[1], out var s2))
                throw ArgumentsOutOfRange(nameof(EndsWith), args);

            return s1.EndsWith(s2, StringComparison.OrdinalIgnoreCase);
        }

        internal static object Format(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 2)
                throw ArgumentsOutOfRange(nameof(Format), args);

            if (!ExpressionHelpers.TryString(args[0], out var formatString))
                throw new ArgumentException();

            var remaining = new object[args.Length - 1];
            System.Array.Copy(args, 1, remaining, 0, remaining.Length);
            return string.Format(AzureCulture, formatString, remaining);
        }

        internal static object Guid(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) < 1)
                throw ArgumentsOutOfRange(nameof(Guid), args);

            var hash = ExpressionHelpers.GetUnique(args);
            var guidBytes = new byte[16];
            System.Array.Copy(hash, 0, guidBytes, 0, 16);
            return new Guid(guidBytes).ToString();
        }

        /// <summary>
        /// indexOf(stringToSearch, stringToFind)
        /// indexOf(arrayToSearch, itemToFind)
        /// </summary>
        internal static object IndexOf(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(IndexOf), args);

            if (ExpressionHelpers.TryString(args[0], out var stringToSearch) &&
                ExpressionHelpers.TryString(args[1], out var stringToFind))
                return IndexOfString(stringToSearch, stringToFind);

            return IndexOfArray(args[0], args[1], first: true);
        }

        /// <summary>
        /// indexOf(stringToSearch, stringToFind)
        /// </summary>
        /// <remarks>
        /// <seealso href="https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-string#indexof"/>
        /// </remarks>
        private static object IndexOfString(string stringToSearch, string stringToFind)
        {
            return (long)stringToSearch.IndexOf(stringToFind, StringComparison.OrdinalIgnoreCase);
        }

        private static object LastIndexOfString(string stringToSearch, string stringToFind)
        {
            return (long)stringToSearch.LastIndexOf(stringToFind, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// indexOf(arrayToSearch, itemToFind)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-array#indexof
        /// </remarks>
        private static object IndexOfArray(object o1, object o2, bool first)
        {
            // Find int in array
            if (ExpressionHelpers.TryLong(o2, out var longToFind) &&
                ExpressionHelpers.TryFindLongIndex(o1, longToFind, out var index, first))
                return index;

            // Find string in array
            if (ExpressionHelpers.TryString(o2, out var stringToFind) &&
                ExpressionHelpers.TryFindStringIndex(o1, stringToFind, out index, caseSensitive: true, first))
                return index;

            // Find array in array
            if (ExpressionHelpers.TryArray(o2, out var arrayToFind) &&
                ExpressionHelpers.TryFindArrayIndex(o1, arrayToFind, out index, first))
                return index;

            // Find object in array
            if (ExpressionHelpers.TryJObject(o2, out var objectToFind) &&
                ExpressionHelpers.TryFindObjectIndex(o1, objectToFind, out index, first))
                return index;

            return (long)-1;
        }

        /// <summary>
        /// lastIndexOf(stringToSearch, stringToFind)
        /// lastIndexOf(arrayToSearch, itemToFind)
        /// </summary>
        internal static object LastIndexOf(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(LastIndexOf), args);

            if (ExpressionHelpers.TryString(args[0], out var stringToSearch) &&
                ExpressionHelpers.TryString(args[1], out var stringToFind))
                return LastIndexOfString(stringToSearch, stringToFind);

            return IndexOfArray(args[0], args[1], first: false);
        }

        /// <summary>
        /// join(inputArray, delimiter)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-string#join
        /// </remarks>
        internal static object Join(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Join), args);

            if (!ExpressionHelpers.TryString(args[1], out var delimiter))
                throw ArgumentInvalidString(nameof(Join), "delimiter");

            if (!ExpressionHelpers.TryStringArray(args[0], out var inputArray))
                throw ArgumentInvalidStringArray(nameof(Join), "inputArray");

            return string.Join(delimiter, inputArray);
        }

        internal static object NewGuid(ITemplateContext context, object[] args)
        {
            if (!(args == null || args.Length == 0))
                throw ArgumentsOutOfRange(nameof(NewGuid), args);

            return System.Guid.NewGuid().ToString();
        }

        internal static object PadLeft(ITemplateContext context, object[] args)
        {
            var argCount = CountArgs(args);
            if (argCount < 2 || argCount > 3)
                throw ArgumentsOutOfRange(nameof(PadLeft), args);

            var paddingCharacter = " ";

            if (!ExpressionHelpers.TryInt(args[1], out var totalLength))
                throw ArgumentInvalidInteger(nameof(PadLeft), "totalLength");

            if (argCount == 3 && (!ExpressionHelpers.TryString(args[2], out paddingCharacter) || paddingCharacter.Length > 1))
                throw new ArgumentException();

            if (ExpressionHelpers.TryString(args[0], out var svalue))
                return svalue.PadLeft(totalLength, paddingCharacter[0]);
            else if (ExpressionHelpers.TryInt(args[1], out var ivalue))
                return ivalue.ToString(AzureCulture).PadLeft(totalLength, paddingCharacter[0]);

            throw new ArgumentException();
        }

        internal static object StartsWith(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2 || !ExpressionHelpers.TryString(args[0], out var s1) || !ExpressionHelpers.TryString(args[1], out var s2))
                throw ArgumentsOutOfRange(nameof(StartsWith), args);

            return s1.StartsWith(s2, StringComparison.OrdinalIgnoreCase);
        }

        internal static object String(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 1)
                throw ArgumentsOutOfRange(nameof(String), args);

            if (ExpressionHelpers.TryBoolString(args[0], out var value))
                return value;

            return JsonConvert.SerializeObject(args[0]);
        }

        internal static object Substring(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length < 1 || args.Length > 3 || !ExpressionHelpers.TryString(args[0], out var value))
                throw ArgumentsOutOfRange(nameof(Substring), args);

            if (args.Length == 2 && ExpressionHelpers.TryInt(args[1], out var startIndex))
                return value.Substring(startIndex);
            else if (args.Length == 3 && ExpressionHelpers.TryInt(args[1], out var startIndex2) && ExpressionHelpers.TryInt(args[2], out var length))
                return value.Substring(startIndex2, length);

            throw ArgumentFormatInvalid(nameof(Substring));
        }

        internal static object ToLower(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(ToLower), args);

            if (args[0] is char c)
                return new string(char.ToLower(c, Thread.CurrentThread.CurrentCulture), 1);

            if (!ExpressionHelpers.TryString(args[0], out var stringToChange))
                throw new ArgumentException();

            return stringToChange.ToLower(AzureCulture);
        }

        internal static object ToUpper(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(ToUpper), args);

            if (args[0] is char c)
                return new string(char.ToUpper(c, Thread.CurrentThread.CurrentCulture), 1);

            if (!ExpressionHelpers.TryString(args[0], out var stringToChange))
                throw new ArgumentException();

            return stringToChange.ToUpper(AzureCulture);
        }

        internal static object Trim(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(Trim), args);

            if (!ExpressionHelpers.TryString(args[0], out var stringToTrim))
                throw new ArgumentException();

            return stringToTrim.Trim();
        }

        internal static object UniqueString(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) == 0)
                throw ArgumentsOutOfRange(nameof(UniqueString), args);

            return ExpressionHelpers.GetUniqueString(args).Substring(0, 13);
        }

        internal static object Uri(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 2)
                throw ArgumentsOutOfRange(nameof(Uri), args);

            if (!ExpressionHelpers.TryString(args[0], out var baseUri))
                throw ArgumentInvalidString(nameof(Uri), "baseUri");

            if (!ExpressionHelpers.TryString(args[1], out var relativeUri))
                throw ArgumentInvalidString(nameof(Uri), "relativeUri");

            var result = new Uri(new Uri(baseUri), relativeUri);
            return result.ToString();
        }

        internal static object UriComponent(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(UriComponent), args);

            if (!ExpressionHelpers.TryString(args[0], out var stringToEncode))
                throw ArgumentInvalidString(nameof(UriComponent), "stringToEncode");

            return HttpUtility.UrlEncode(stringToEncode);
        }

        internal static object UriComponentToString(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 1)
                throw ArgumentsOutOfRange(nameof(UriComponentToString), args);

            if (!ExpressionHelpers.TryString(args[0], out var uriEncodedString))
                throw ArgumentInvalidString(nameof(UriComponentToString), "uriEncodedString");

            return HttpUtility.UrlDecode(uriEncodedString);
        }

        internal static object Replace(ITemplateContext context, object[] args)
        {
            if (CountArgs(args) != 3)
                throw ArgumentsOutOfRange(nameof(Replace), args);

            if (!ExpressionHelpers.TryString(args[0], out var originalString) ||
                !ExpressionHelpers.TryString(args[1], out var oldString) ||
                !ExpressionHelpers.TryString(args[2], out var newString))
                throw ArgumentFormatInvalid(nameof(Replace));

            return originalString.Replace(oldString, newString);
        }

        /// <summary>
        /// split(inputString, delimiter)
        /// </summary>
        /// <remarks>
        /// https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-string#split
        /// </remarks>
        internal static object Split(ITemplateContext context, object[] args)
        {
            if (args == null || args.Length != 2)
                throw ArgumentsOutOfRange(nameof(Split), args);

            if (!ExpressionHelpers.TryString(args[0], out var inputString))
                throw ArgumentInvalidString(nameof(Split), "inputString");

            // Handle mocks to prevent exception
            if (inputString.StartsWith("{{", StringComparison.OrdinalIgnoreCase) && inputString.EndsWith("}}", StringComparison.OrdinalIgnoreCase))
                return new MockArray(null, null);

            string[] delimiter = null;
            if (ExpressionHelpers.TryString(args[1], out var single))
            {
                delimiter = new string[] { single };
            }
            else if (ExpressionHelpers.TryStringArray(args[1], out var delimiterArray))
            {
                delimiter = delimiterArray;
            }
            else
                throw ArgumentFormatInvalid(nameof(Split));

            return new JArray(inputString.Split(delimiter, StringSplitOptions.None));
        }

        #endregion String

        #region Helper functions

        private static int Compare(object left, object right)
        {
            if (ExpressionHelpers.TryLong(left, out var longLeft) && ExpressionHelpers.TryLong(right, out var longRight))
                return Comparer<long>.Default.Compare(longLeft, longRight);
            else if (ExpressionHelpers.TryString(left, out var stringLeft) && ExpressionHelpers.TryString(right, out var stringRight))
                return StringComparer.Ordinal.Compare(stringLeft, stringRight);

            return Comparer.Default.Compare(left, right);
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
                if (ExpressionHelpers.ObjectEquals(array.GetValue(i), objectToFind))
                    return true;
            }
            return false;
        }

        private static int CountArgs(object[] args)
        {
            return args == null ? 0 : args.Length;
        }

        private static int FindResourceTypePart(string[] segments)
        {
            for (var i = 0; i < segments.Length; i++)
                if (segments[i].Contains('/'))
                    return i;

            return 0;
        }

        private static void GetResourceIdParts(string[] segments, int start, out string[] resourceType, out string[] name)
        {
            var typeParts = segments[start].Split('/');
            var depth = string.IsNullOrEmpty(typeParts[typeParts.Length - 1]) ? typeParts.Length - 2 : typeParts.Length - 1;
            resourceType = new string[depth];
            resourceType[0] = string.Concat(typeParts[0], '/', typeParts[1]);
            for (var i = 1; i < depth; i++)
                resourceType[i] = typeParts[i + 1];

            name = new string[segments.Length - (start + 1)];
            if (name.Length == resourceType.Length)
                System.Array.Copy(segments, start + 1, name, 0, depth);
        }

        private static object GetExpression(ITemplateContext context, object o)
        {
            return o is ExpressionFnOuter fn ? fn(context) : o;
        }

        #endregion Helper functions

        #region Exceptions

        /// <summary>
        /// The number of arguments '{1}' is not within the allowed range for '{0}'.
        /// </summary>
        private static ExpressionArgumentException ArgumentsOutOfRange(string expression, object[] args)
        {
            var length = args == null ? 0 : args.Length;
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentsOutOfRange, expression, length)
            );
        }

        /// <summary>
        /// The arguments for '{0}' are not in the expected format or type.
        /// </summary>
        private static ExpressionArgumentException ArgumentFormatInvalid(string expression)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentFormatInvalid, expression)
            );
        }

        /// <summary>
        /// The argument '{0}' for '{1}' is not a valid integer.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidInteger(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidInteger, operand, expression)
            );
        }

        /// <summary>
        /// The argument '{0}' for '{1}' is not a valid time.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidDateTime(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidDateTime, operand, expression)
            );
        }

        /// <summary>
        /// The argument '{0}' for '{1}' is not a valid boolean.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidBoolean(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidBoolean, operand, expression)
            );
        }

        /// <summary>
        /// The argument '{0}' for '{1}' is not a valid string.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidString(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidString, operand, expression)
            );
        }

        /// <summary>
        /// The argument '{0}' for '{1}' is not a valid string array.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidStringArray(string expression, string operand)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidStringArray, operand, expression)
            );
        }

        /// <summary>
        /// The resource type '{1}/{2}' for '{0}' is not known.
        /// </summary>
        private static ExpressionArgumentException ArgumentInvalidResourceType(string expression, string providerNamespace, string resourceType)
        {
            return new ExpressionArgumentException(
                expression,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidResourceType, expression, providerNamespace, resourceType)
            );
        }

        /// <summary>
        /// The number of resource segments needs to match the provided resource type.
        /// </summary>
        private static TemplateFunctionException MismatchingResourceSegments(string expression)
        {
            return new TemplateFunctionException(
                expression,
                FunctionErrorType.MismatchingResourceSegments,
                PSRuleResources.MismatchingResourceSegments
            );
        }

        #endregion Exceptions
    }
}
