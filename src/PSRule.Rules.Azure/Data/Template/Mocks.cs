// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface IMock
    {
        TypePrimitive BaseType { get; }

        bool IsSecret { get; }

        TValue GetValue<TValue>();

        JToken GetValue(TypePrimitive type);

        JToken GetValue(object key);

        string GetString();
    }

    internal interface IUnknownMock : IMock
    {

    }

    internal sealed class Mock
    {
        /// <summary>
        /// Mock an unknown property or value.
        /// </summary>
        internal class MockUnknownObject : MockObject, IUnknownMock
        {
            public MockUnknownObject()
                : base(secret: false) { }

            public MockUnknownObject(bool secret)
                : base(secret) { }

            TypePrimitive IMock.BaseType => TypePrimitive.None;

            public static new JToken FromObject(object o)
            {
                return Mock.FromObject(o);
            }

            public override JToken GetValue(TypePrimitive type)
            {
                return TryMutate(type, this, out var replaced) ? replaced : null;
            }

            public override JToken GetValue(object key)
            {
                if ((key is int || key is long) && TryMutate<JArray>(this, out var replaced))
                {
                    var result = new MockUnknownObject(IsSecret);
                    replaced.Add(result);
                    return result;
                }
                return base.GetValue(key);
            }

            public override TValue GetValue<TValue>()
            {
                if (TryMutate<TValue>(this, out var replaced))
                    return replaced;

                return GetSimpleValue<TValue>(this);
            }
        }

        internal class MockUnknownArray : MockArray, IUnknownMock
        {
            public MockUnknownArray()
                : base(secret: false) { }

            public MockUnknownArray(bool secret)
                : base(secret) { }
        }

        internal sealed class MockSecret : MockUnknownObject
        {
            public MockSecret(string resourceId)
                : base(secret: true)
            {
                ResourceId = resourceId;
            }

            public string ResourceId { get; }

            public override string ToString()
            {
                return "SecretList";
            }
        }

        internal sealed class MockResource : MockUnknownObject
        {
            public MockResource(string resourceId)
                : base()
            {
                ResourceId = resourceId;
                ResourceHelper.TryResourceIdComponents(resourceId, out var subscriptionId, out var resourceGroupName, out string resourceType, out string name);
                if (resourceId != null)
                    Add("id", new JValue(resourceId));

                if (subscriptionId != null)
                    Add("subscriptionId", new JValue(subscriptionId));

                if (resourceType != null)
                    Add("type", new JValue(resourceType));

                if (name != null)
                    Add("name", new JValue(name));

                var properties = new MockUnknownObject();
                Add("properties", properties);
            }

            public string ResourceId { get; }

            public override JToken this[object key] { get => base[key]; set => base[key] = value; }

            public override string GetString()
            {
                return "Resource";
            }
        }

        /// <summary>
        /// Mock a simple value.
        /// </summary>
        internal sealed class MockValue : JValue, IMock
        {
            public MockValue(JValue value)
                : base(value)
            {
                BaseType = GetTypePrimitive(value);
            }

            public MockValue(string value)
                : base(value)
            {
                BaseType = TypePrimitive.String;
            }

            public MockValue(int value)
                : base(value)
            {
                BaseType = TypePrimitive.Int;
            }

            public MockValue(bool value)
                : base(value)
            {
                BaseType = TypePrimitive.Bool;
            }

            public bool IsSecret => false;

            public TypePrimitive BaseType { get; }

            public override JToken this[object key] { get => base[key]; set => base[key] = value; }

            public TValue GetValue<TValue>()
            {
                return GetSimpleValue<TValue>(this);
            }

            public JToken GetValue(TypePrimitive type)
            {
                if (type == TypePrimitive.None || BaseType == type)
                    return this;

                if (TryMutate(type, this, out var value))
                    return value;

                return null;
            }

            public JToken GetValue(object key)
            {
                throw new NotImplementedException();
            }

            public string GetString()
            {
                throw new NotImplementedException();
            }
        }

        internal class MockArray : JArray, IMock
        {
            public MockArray(JArray value)
                : base(value) { }

            public MockArray(bool secret = false)
                : base()
            {
                IsSecret = secret;
            }

            TypePrimitive IMock.BaseType => TypePrimitive.Array;

            public bool IsSecret { get; }

            public TValue GetValue<TValue>()
            {
                return GetArrayValue<TValue>(this);
            }

            public JToken GetValue(TypePrimitive type)
            {
                return type == TypePrimitive.None || type == TypePrimitive.Array ? this : null;
            }

            public JToken GetValue(object key)
            {
                if (key is long l)
                    key = (int)l;
                else if (key is byte b)
                    key = (int)b;

                if (key is not int i)
                    return new MockUnknownObject(IsSecret);

                if (i == -1)
                    i = Count == 0 ? 0 : Count - 1;

                var t = base[i];
                return t == null ? new MockUnknownObject(IsSecret) : Mock.FromObject(t);
            }

            public override JToken this[object key]
            {
                get
                {
                    return GetValue(key);
                }
                set { base[key] = value; }
            }

            public new JToken this[int index]
            {
                get { return GetValue(index); }
                set { base[index] = value; }
            }

            public override IEnumerable<T?> Values<T>() where T : default
            {
                return base.Values<T>();
            }

            public override T? Value<T>(object key) where T : default
            {
                return base.Value<T>(key);
            }

            public string GetString()
            {
                return "Object";
            }
        }

        internal class MockObject : JObject, IMock
        {
            public MockObject(JObject value, bool secret = false)
                : base(value)
            {
                IsSecret = secret;
            }

            public MockObject(bool secret = false)
                : base()
            {
                IsSecret = secret;
            }

            public new JToken? this[string propertyName]
            {
                get { return GetValue(propertyName); }
                set { base[propertyName] = value; }
            }

            public override JToken this[object key]
            {
                get
                {
                    return GetValue(key);
                }
                set { base[key] = value; }
            }

            public override T? Value<T>(object key) where T : default
            {
                return base.Value<T>(key);
            }

            public override IEnumerable<T?> Values<T>() where T : default
            {
                return base.Values<T>();
            }

            public bool IsSecret { get; }

            TypePrimitive IMock.BaseType => TypePrimitive.Object;

            public virtual TValue GetValue<TValue>()
            {
                return GetSimpleValue<TValue>(this);
            }

            public virtual JToken GetValue(TypePrimitive type)
            {
                return this;
            }

            public virtual JToken GetValue(object key)
            {
                key = GetBaseObject(key);
                var result = base[key];
                if (result == null)
                {
                    // Guess string type for common scenarios.
                    if (key is string s_key && TryWellKnownStringProperty(this, s_key, out var s_value))
                        result = s_value;
                    else
                        result = new MockUnknownObject(IsSecret);

                    base[key] = result;
                }
                else if (result is JObject jObject)
                {
                    result = new MockObject(jObject);
                    base[key] = result;
                }
                else if (result is JArray jArray)
                {
                    result = new MockArray(jArray);
                    base[key] = result;
                }
                return result;
            }

            public override string ToString()
            {
                var builder = new StringBuilder();
                builder.Insert(0, GetString());
                var parent = Parent as IMock ?? Parent?.Parent as IMock;
                while (parent != null)
                {
                    builder.Insert(0, ".");
                    builder.Insert(0, parent.GetString());
                    parent = (parent as JToken).Parent as IMock ?? (parent as JToken).Parent?.Parent as IMock;
                }
                builder.Insert(0, "{{");
                builder.Append("}}");
                return builder.ToString();
            }

            public virtual string GetString()
            {
                return "Object";
            }
        }

        private static TValue GetSimpleValue<TValue>(JToken value)
        {
            if (typeof(TValue).IsAssignableFrom(value.GetType()) && value is TValue castTValue)
                return castTValue;

            if (value != null && value is not IUnknownMock)
                return value.Value<TValue>();

            if (typeof(TValue) == typeof(string) && string.Empty is TValue s)
                return s;

            return default;
        }

        /// <summary>
        /// Tokens are mutated when originally the type of token is unknown.
        /// </summary>
        private static bool TryMutate<TValue>(JToken current, out TValue replaced)
        {
            replaced = default;
            if (current is TValue value)
            {
                replaced = value;
                return true;
            }

            var isSecret = current is IMock mock && mock.IsSecret;

            if (typeof(JArray).IsAssignableFrom(typeof(TValue)))
            {
                var replacement = new MockUnknownArray(isSecret);
                current.Replace(replacement);
                replaced = replacement is TValue replacementResult ? replacementResult : default;
                return true;
            }
            else if (typeof(JObject).IsAssignableFrom(typeof(TValue)))
            {
                var replacement = new MockUnknownObject(isSecret);
                current.Replace(replacement);
                replaced = replacement is TValue replacementResult ? replacementResult : default;
            }
            return false;
        }

        /// <summary>
        /// Tokens are mutated when originally the type of token is unknown.
        /// </summary>
        private static bool TryMutate(TypePrimitive type, JToken current, out JToken replaced)
        {
            replaced = default;
            if (type is TypePrimitive.Object or TypePrimitive.SecureObject)
            {
                replaced = TryMutate<MockUnknownObject>(current, out var uo) ? uo : default;
                return replaced != default;
            }
            else if (type == TypePrimitive.Array)
            {
                replaced = TryMutate<MockUnknownArray>(current, out var uo) ? uo : default;
                return replaced != default;
            }
            else if (type is TypePrimitive.String or TypePrimitive.SecureString)
            {
                var isSecret = type == TypePrimitive.SecureString || current is IMock mock && mock.IsSecret;
                replaced = new MockValue(isSecret ? "{{Secret}}" : string.Empty);
                current.Replace(replaced);
                return true;
            }
            return false;
        }

        private static TValue GetArrayValue<TValue>(JToken value)
        {
            throw new NotImplementedException();
        }

        private static JToken FromObject(object o)
        {
            var token = JToken.FromObject(o);

            if (token.Type is JTokenType.String or
                JTokenType.Integer or
                JTokenType.Boolean or
                JTokenType.Float or
                JTokenType.Date or
                JTokenType.Guid or
                JTokenType.TimeSpan or
                JTokenType.Uri)
                return new MockValue(token.Value<JValue>());

            if (token.Type == JTokenType.Array)
                return new MockArray(token.Value<JArray>());

            if (token.Type == JTokenType.Object)
                return new MockObject(token.Value<JObject>());

            throw new NotImplementedException();
        }

        private static TypePrimitive GetTypePrimitive(JToken token)
        {
            if (token.Type == JTokenType.String)
                return TypePrimitive.String;

            if (token.Type == JTokenType.Integer)
                return TypePrimitive.Int;

            if (token.Type == JTokenType.Boolean)
                return TypePrimitive.Bool;

            throw new NotImplementedException();
        }

        private static bool TryWellKnownStringProperty(JObject o, string key, out JValue value)
        {
            value = default;
            if (StringComparer.OrdinalIgnoreCase.Equals(key, "primaryConnectionString") ||
                StringComparer.OrdinalIgnoreCase.Equals(key, "secondaryConnectionString"))
            {
                value = new JValue(key);
                return true;
            }

            // Handle name and type
            if (StringComparer.OrdinalIgnoreCase.Equals(key, "name"))
            {
                value = TryExpandId(o) && o.TryGetProperty<JValue>("name", out var nameValue) ? nameValue : new JValue(key);
                return true;
            }
            else if (StringComparer.OrdinalIgnoreCase.Equals(key, "type") && TryExpandId(o))
            {
                value = o.TryGetProperty<JValue>("type", out var nameValue) ? nameValue : default;
                return true;
            }
            return false;
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0007:Use implicit type", Justification = "Don't convert to var to ignore ambiguous type reference.")]
        private static bool TryExpandId(JObject o)
        {
            if (o.TryGetProperty("id", out var id) && ResourceHelper.TryResourceIdComponents(id, out _, out _, out string resourceType, out string resourceName))
            {
                o["name"] = resourceName;
                o["type"] = resourceType;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Unwrap the base object from a JToken.
        /// </summary>
        private static object GetBaseObject(object o)
        {
            if (o is JToken t_string && t_string.Type == JTokenType.String)
                return t_string.Value<string>();

            if (o is JToken t_int && t_int.Type == JTokenType.Integer)
                return t_int.Value<int>();

            return o;
        }
    }
}
