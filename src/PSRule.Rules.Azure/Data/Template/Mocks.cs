// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface IMock
    {
        IMock Parent { get; }

        bool TryProperty(string propertyName, out IMock value);

        bool TryGetIndex(int index, out IMock value);

        bool TryGetValue(out object value);

        bool TryGetValue<TValue>(out TValue value);

        bool TryGetToken(out JToken value);
    }

    internal abstract class Mock : IMock
    {
        protected Mock(IMock parent)
        {
            Parent = parent;
        }

        public IMock Parent { get; }

        public virtual bool TryProperty(string propertyName, out IMock value)
        {
            value = null;
            return false;
        }

        public virtual bool TryGetIndex(int index, out IMock value)
        {
            value = null;
            return false;
        }

        public virtual bool TryGetValue(out object value)
        {
            value = null;
            return false;
        }

        public virtual bool TryGetValue<TValue>(out TValue value)
        {
            value = default;
            if (TryGetValue(out var v) && v != null && typeof(TValue).IsAssignableFrom(v.GetType()))
                value = (TValue)v;

            return value != null;
        }

        public virtual bool TryGetToken(out JToken value)
        {
            value = null;
            return false;
        }

        public override string ToString()
        {
            return TryGetValue(out var value) ? value.ToString() : string.Empty;
        }

        public static explicit operator int(Mock mock) => mock != null && mock.TryGetValue<int>(out var value) ? value : default;

        public static explicit operator long(Mock mock) => mock != null && mock.TryGetValue<long>(out var value) ? value : default;

        public static explicit operator bool(Mock mock) => mock != null && mock.TryGetValue<bool>(out var value) ? value : default;

        public static explicit operator string(Mock mock) => mock != null && mock.TryGetValue<string>(out var value) ? value : default;
    }

    internal abstract class MockLiteral<T> : Mock, IMock
    {
        protected MockLiteral(T value, IMock parent)
            : base(parent)
        {
            Value = value;
        }

        public T Value { get; }

        public override bool TryGetValue(out object value)
        {
            value = Value;
            return true;
        }

        public override bool TryGetToken(out JToken value)
        {
            value = new JValue(Value);
            return true;
        }
    }

    internal sealed class MockString : MockLiteral<string>
    {
        public MockString(string value, IMock parent = null)
            : base(value, parent) { }
    }

    internal sealed class MockInteger : MockLiteral<long>
    {
        public MockInteger(long value, IMock parent = null)
            : base(value, parent) { }
    }

    internal sealed class MockBool : MockLiteral<bool>
    {
        public MockBool(bool value, IMock parent = null)
            : base(value, parent) { }
    }

    internal abstract class MockNode : Mock, ILazyObject, IMock
    {
        protected MockNode(IMock parent)
            : base(parent) { }

        public override string ToString()
        {
            var builder = new StringBuilder();
            builder.Insert(0, GetString());
            var parent = Parent as MockNode;
            while (parent != null)
            {
                builder.Insert(0, ".");
                builder.Insert(0, parent.GetString());
                parent = parent.Parent as MockNode;
            }
            builder.Insert(0, "{{");
            builder.Append("}}");
            return builder.ToString();
        }

        public static explicit operator string(MockNode mock) => mock != null ? mock.ToString() : default;

        protected abstract string GetString();

        protected MockString Mock(string value)
        {
            return new MockString(value, this);
        }

        protected MockInteger Mock(long value)
        {
            return new MockInteger(value, this);
        }

        protected MockBool Mock(bool value)
        {
            return new MockBool(value, this);
        }

        protected MockArray MockArray(JArray value)
        {
            return new MockArray(value, this);
        }

        protected MockObject MockObject(JObject value)
        {
            return new MockObject(value, this);
        }

        internal MockMember MockMember(string name)
        {
            return new MockMember(null, this, name);
        }

        bool ILazyObject.TryProperty(string propertyName, out object value)
        {
            value = MockMember(propertyName);
            return true;
        }
    }

    internal sealed class MockArray : MockNode, IMock
    {
        public MockArray(JArray value, IMock parent = null)
            : base(parent)
        {
            Value = value;
        }

        public JArray Value { get; }

        public override bool TryGetIndex(int index, out IMock value)
        {
            return TryGetIndexFromValue(index, out value);
        }

        protected override string GetString()
        {
            return ToString();
        }

        public override string ToString()
        {
            return TryGetValue(out var value) ? value.ToString() : string.Empty;
        }

        private bool TryGetIndexFromValue(int index, out IMock value)
        {
            value = null;
            if (Value == null || index < 0 || index > Value.Count - 1)
                return false;

            var token = Value[index];
            if (token.Type == JTokenType.String)
                value = Mock(token.Value<string>());

            if (token.Type == JTokenType.Integer)
                value = Mock(token.Value<long>());

            if (token.Type == JTokenType.Boolean)
                value = Mock(token.Value<bool>());

            if (token.Type == JTokenType.Array)
                value = MockArray(token.Value<JArray>());

            if (token.Type == JTokenType.Object)
                value = MockObject(token.Value<JObject>());

            return true;
        }
    }

    internal abstract class MockObjectBase : MockNode, IMock, ILazyObject
    {
        internal MockObjectBase(MockNode parent)
            : base(parent) { }

        public JObject Value { get; protected set; }

        public override bool TryProperty(string propertyName, out IMock value)
        {
            return TryGetPropertyFromValue(propertyName, out value);
        }

        public override bool TryGetValue(out object value)
        {
            value = Value;
            return value != null;
        }

        public override bool TryGetToken(out JToken value)
        {
            value = Value;
            return Value != null;
        }

        private bool TryGetPropertyFromValue(string propertyName, out IMock value)
        {
            value = null;
            if (Value == null || !Value.TryGetProperty(propertyName, out JToken token))
                return false;

            if (token.Type == JTokenType.String)
                value = Mock(token.Value<string>());

            if (token.Type == JTokenType.Integer)
                value = Mock(token.Value<long>());

            if (token.Type == JTokenType.Boolean)
                value = Mock(token.Value<bool>());

            if (token.Type == JTokenType.Array)
                value = MockArray(token.Value<JArray>());

            if (token.Type == JTokenType.Object)
                value = MockObject(token.Value<JObject>());

            return true;
        }

        public bool TryProperty(string propertyName, out object value)
        {
            value = null;
            if (TryProperty(propertyName, out IMock fake))
                value = fake;

            if (value == null)
                value = MockObject(null);

            return value != null;
        }
    }

    internal sealed class MockObject : MockObjectBase
    {
        internal MockObject(JObject o, MockNode parent = null)
            : base(parent)
        {
            Value = o;
        }

        protected override string GetString()
        {
            return "Object";
        }

        public override bool TryGetToken(out JToken value)
        {
            if (!base.TryGetToken(out value))
                value = new JObject();

            return true;
        }
    }

    internal sealed class MockList : MockNode
    {
        internal MockList(string resourceId)
            : base(null)
        {
            ResourceId = resourceId;
        }

        public string ResourceId { get; }

        protected override string GetString()
        {
            return "SecretList";
        }
    }

    internal sealed class MockMember : MockNode
    {
        internal MockMember(JToken token, MockNode parent, string name)
            : base(parent)
        {
            Name = name;
            Value = token;
        }

        public string Name { get; }

        public JToken Value { get; }

        protected override string GetString()
        {
            return Name;
        }

        public override bool TryGetToken(out JToken value)
        {
            value = Value;
            return Value != null || base.TryGetToken(out value);
        }
    }

    internal sealed class MockResource : MockObjectBase
    {
        internal MockResource(string resourceType)
            : base(null)
        {
            ResourceType = resourceType;
        }

        public string ResourceType { get; }

        protected override string GetString()
        {
            return "Resource";
        }
    }
}
