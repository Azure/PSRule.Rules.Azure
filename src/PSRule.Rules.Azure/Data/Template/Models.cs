// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
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

    public sealed class CloudEnvironment
    {
        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        [JsonProperty(PropertyName = "gallery")]
        public string Gallery { get; set; }

        [JsonProperty(PropertyName = "graph")]
        public string Graph { get; set; }

        [JsonProperty(PropertyName = "portal")]
        public string Portal { get; set; }

        [JsonProperty(PropertyName = "graphAudience")]
        public string GraphAudience { get; set; }

        [JsonProperty(PropertyName = "activeDirectoryDataLake")]
        public string ActiveDirectoryDataLake { get; set; }

        [JsonProperty(PropertyName = "batch")]
        public string Batch { get; set; }

        [JsonProperty(PropertyName = "media")]
        public string Media { get; set; }

        [JsonProperty(PropertyName = "sqlManagement")]
        public string SqlManagement { get; set; }

        [JsonProperty(PropertyName = "vmImageAliasDoc")]
        public string VmImageAliasDoc { get; set; }

        [JsonProperty(PropertyName = "resourceManager")]
        public string ResourceManager { get; set; }

        [JsonProperty(PropertyName = "authentication")]
        public CloudEnvironmentAuthentication Authentication { get; set; }

        [JsonProperty(PropertyName = "suffixes")]
        public CloudEnvironmentSuffixes Suffixes { get; set; }
    }

    public sealed class CloudEnvironmentAuthentication
    {
        [JsonProperty(PropertyName = "loginEndpoint")]
        public string loginEndpoint { get; set; }

        [JsonProperty(PropertyName = "audiences")]
        public string[] audiences { get; set; }

        [JsonProperty(PropertyName = "tenant")]
        public string tenant { get; set; }

        [JsonProperty(PropertyName = "identityProvider")]
        public string identityProvider { get; set; }
    }

    public sealed class CloudEnvironmentSuffixes
    {
        [JsonProperty(PropertyName = "acrLoginServer")]
        public string acrLoginServer { get; set; }

        [JsonProperty(PropertyName = "azureDatalakeAnalyticsCatalogAndJob")]
        public string azureDatalakeAnalyticsCatalogAndJob { get; set; }

        [JsonProperty(PropertyName = "azureDatalakeStoreFileSystem")]
        public string azureDatalakeStoreFileSystem { get; set; }

        [JsonProperty(PropertyName = "azureFrontDoorEndpointSuffix")]
        public string azureFrontDoorEndpointSuffix { get; set; }

        [JsonProperty(PropertyName = "keyvaultDns")]
        public string keyvaultDns { get; set; }

        [JsonProperty(PropertyName = "sqlServerHostname")]
        public string sqlServerHostname { get; set; }

        [JsonProperty(PropertyName = "storage")]
        public string storage { get; set; }
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
