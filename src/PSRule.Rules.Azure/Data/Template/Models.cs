using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Collections;
using System.Collections.Generic;

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

    public sealed class MockResource
    {
        public MockResource()
        {

        }
    }

    public sealed class MockResourceList
    {
        public MockResourceList()
        {

        }
    }

    public sealed class DeploymentParameters
    {
        [JsonProperty("$schema")]
        public string Schema { get; set; }

        [JsonProperty("contentVersion")]
        public string ContentVersion { get; set; }

        [JsonProperty("parameters")]
        public Dictionary<string, DeploymentParameterValue> Parameters { get; set; }

        public sealed class DeploymentParameterValue
        {
            [JsonProperty("value")]
            public object Value { get; set; }

            public DeploymentParameterKeyVaultReference Reference {get;set;}
        }

        public class DeploymentParameterKeyVaultReference
        {
            public string SecretName { get; set; }

            public ResourceReference KeyVault { get; set; }
        }
    }

    public sealed class ResourceReference
    {
        public string Id { get; set; }
    }
}
