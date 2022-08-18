// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration
{
    /// <summary>
    /// Options for configuring PSRule for Azure.
    /// </summary>
    public sealed class ConfigurationOption : IEquatable<ConfigurationOption>
    {
        internal static readonly ConfigurationOption Default = new ConfigurationOption
        {
            Subscription = SubscriptionOption.Default,
            ResourceGroup = ResourceGroupOption.Default,
            Tenant = TenantOption.Default,
            ManagementGroup = ManagementGroupOption.Default,
            ParameterDefaults = ParameterDefaultsOption.Default,
            Deployment = DeploymentOption.Default,
        };

        public ConfigurationOption()
        {
            Subscription = null;
            ResourceGroup = null;
            Tenant = null;
            ManagementGroup = null;
            ParameterDefaults = null;
            Deployment = null;
        }

        internal ConfigurationOption(ConfigurationOption option)
        {
            if (option == null)
                throw new ArgumentNullException(nameof(option));

            Subscription = option.Subscription;
            ResourceGroup = option.ResourceGroup;
            Tenant = option.Tenant;
            ManagementGroup = option.ManagementGroup;
            ParameterDefaults = option.ParameterDefaults;
            Deployment = option.Deployment;
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            return obj is ConfigurationOption option && Equals(option);
        }

        public bool Equals(ConfigurationOption other)
        {
            return other != null &&
                Subscription == other.Subscription &&
                ResourceGroup == other.ResourceGroup &&
                Tenant == other.Tenant &&
                ManagementGroup == other.ManagementGroup &&
                ParameterDefaults == other.ParameterDefaults &&
                Deployment == other.Deployment;
        }

        /// <inheritdoc/>
        public override int GetHashCode()
        {
            unchecked // Overflow is fine
            {
                var hash = 17;
                hash = hash * 23 + (Subscription != null ? Subscription.GetHashCode() : 0);
                hash = hash * 23 + (ResourceGroup != null ? ResourceGroup.GetHashCode() : 0);
                hash = hash * 23 + (Tenant != null ? Tenant.GetHashCode() : 0);
                hash = hash * 23 + (ManagementGroup != null ? ManagementGroup.GetHashCode() : 0);
                hash = hash * 23 + (ParameterDefaults != null ? ParameterDefaults.GetHashCode() : 0);
                hash = hash * 23 + (Deployment != null ? Deployment.GetHashCode() : 0);
                return hash;
            }
        }

        internal static ConfigurationOption Combine(ConfigurationOption o1, ConfigurationOption o2)
        {
            var result = new ConfigurationOption
            {
                ResourceGroup = ResourceGroupOption.Combine(o1?.ResourceGroup, o2?.ResourceGroup),
                Subscription = SubscriptionOption.Combine(o1?.Subscription, o2?.Subscription),
                Tenant = TenantOption.Combine(o1?.Tenant, o2?.Tenant),
                ManagementGroup = ManagementGroupOption.Combine(o1?.ManagementGroup, o2?.ManagementGroup),
                ParameterDefaults = ParameterDefaultsOption.Combine(o1?.ParameterDefaults, o2?.ParameterDefaults),
                Deployment = DeploymentOption.Combine(o1?.Deployment, o2?.Deployment),
            };
            return result;
        }

        /// <summary>
        /// Configures the properties of the subscription object.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_SUBSCRIPTION", ApplyNamingConventions = false)]
        public SubscriptionOption Subscription { get; set; }

        /// <summary>
        /// Configures the properties of the resourceGroup object.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_RESOURCE_GROUP", ApplyNamingConventions = false)]
        public ResourceGroupOption ResourceGroup { get; set; }

        /// <summary>
        /// Configures the properties of the tenant object.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_TENANT", ApplyNamingConventions = false)]
        public TenantOption Tenant { get; set; }

        /// <summary>
        /// Configures the properties of the managementGroup object.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_MANAGEMENT_GROUP", ApplyNamingConventions = false)]
        public ManagementGroupOption ManagementGroup { get; set; }

        /// <summary>
        /// Configures defaults for required parameters that are not specified.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_PARAMETER_DEFAULTS", ApplyNamingConventions = false)]
        public ParameterDefaultsOption ParameterDefaults { get; set; }

        /// <summary>
        /// Configures the properties of the deployment object.
        /// </summary>
        [DefaultValue(null)]
        [YamlMember(Alias = "AZURE_DEPLOYMENT", ApplyNamingConventions = false)]
        public DeploymentOption Deployment { get; set; }
    }
}
