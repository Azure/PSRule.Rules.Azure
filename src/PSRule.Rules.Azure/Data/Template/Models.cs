// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace PSRule.Rules.Azure.Data.Template
{
    [JsonConverter(typeof(StringEnumConverter))]
    internal enum ParameterType
    {
        Array,

        Bool,

        Int,

        Object,

        String,

        SecureString,

        SecureObject
    }

    public sealed class Subscription
    {
        private const string DEFAULT_ID = "/subscriptions/{{Subscription.SubscriptionId}}";
        private const string DEFAULT_SUBSCRIPTIONID = "{{Subscription.SubscriptionId}}";
        private const string DEFAULT_TENANTID = "{{Subscription.TenantId}}";
        private const string DEFAULT_DISPLAYNAME = "{{Subscription.Name}}";

        internal readonly static Subscription Default = new Subscription();

        internal Subscription()
        {
            SubscriptionId = DEFAULT_SUBSCRIPTIONID;
            TenantId = DEFAULT_TENANTID;
            DisplayName = DEFAULT_DISPLAYNAME;
            Id = DEFAULT_ID;
        }

        internal Subscription(string subscriptionId, string tenantId, string displayName)
        {
            SubscriptionId = subscriptionId;
            TenantId = tenantId;
            DisplayName = displayName;
            Id = string.Concat("/subscriptions/", SubscriptionId);
        }

        public readonly string Id;

        public readonly string SubscriptionId;

        public readonly string TenantId;

        public readonly string DisplayName;
    }

    public sealed class ResourceGroup
    {
        private const string DEFAULT_ID = "/subscriptions/{{Subscription.SubscriptionId}}/resourceGroups/{{ResourceGroup.Name}}";
        private const string DEFAULT_NAME = "{{ResourceGroup.Name}}";
        private const string DEFAULT_TYPE = "Microsoft.Resources/resourceGroups";
        private const string DEFAULT_LOCATION = "{{ResourceGroup.Location}}";
        private const string DEFAULT_MANAGEDBY = "{{ResourceGroup.ManagedBy}}";
        private const Hashtable DEFAULT_TAGS = null;
        private const string DEFAULT_PROVISIONINGSTATE = "Succeeded";

        internal readonly static ResourceGroup Default = new ResourceGroup();

        internal ResourceGroup()
        {
            Id = DEFAULT_ID;
            Name = DEFAULT_NAME;
            Type = DEFAULT_TYPE;
            Location = DEFAULT_LOCATION;
            ManagedBy = DEFAULT_MANAGEDBY;
            Tags = DEFAULT_TAGS;
            Properties = new ResourceGroupProperties(DEFAULT_PROVISIONINGSTATE);
        }

        internal ResourceGroup(string id, string name, string location, string managedBy, Hashtable tags)
            : this()
        {
            Id = id;
            Name = name;
            Location = location;
            ManagedBy = managedBy;
            Tags = tags;
        }

        public sealed class ResourceGroupProperties
        {
            public readonly string ProvisioningState;

            internal ResourceGroupProperties(string provisioningState)
            {
                ProvisioningState = provisioningState;
            }
        }

        public readonly string Id;

        public readonly string Name;

        public readonly string Type;

        public readonly string Location;

        public readonly string ManagedBy;

        public readonly Hashtable Tags;

        public readonly ResourceGroupProperties Properties;
    }

    public sealed class ResourceProvider
    {
        internal ResourceProvider()
        {
            Types = new Dictionary<string, ResourceProviderType>(StringComparer.OrdinalIgnoreCase);
        }

        public Dictionary<string, ResourceProviderType> Types { get; }
    }

    public sealed class ResourceProviderType
    {
        public string ResourceType { get; set; }

        public string[] Locations { get; set; }

        public string[] ApiVersions { get; set; }
    }

    public abstract class MockNode
    {
        protected MockNode(MockNode parent)
        {
            Parent = parent;
        }

        public MockNode Parent { get; }

        internal MockMember GetMember(string name)
        {
            return new MockMember(this, name);
        }

        internal string BuildString()
        {
            var builder = new StringBuilder();
            builder.Insert(0, GetString());
            var parent = Parent;
            while (parent != null)
            {
                builder.Insert(0, ".");
                builder.Insert(0, parent.GetString());
                parent = parent.Parent;
            }
            builder.Insert(0, "{{");
            builder.Append("}}");
            return builder.ToString();
        }

        protected abstract string GetString();
    }

    public sealed class MockResource : MockNode
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

    public sealed class MockList : MockNode
    {
        internal MockList(string resourceId)
            : base(null)
        {
            ResourceId = resourceId;
        }

        public string ResourceId { get; }

        protected override string GetString()
        {
            return "List";
        }
    }

    public sealed class MockMember : MockNode
    {
        internal MockMember(MockNode parent, string name)
            : base(parent)
        {
            Name = name;
        }

        public string Name { get; }

        protected override string GetString()
        {
            return Name;
        }
    }
}
