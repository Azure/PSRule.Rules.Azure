// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// Options that affect the properties of the <c>resourceGroup()</c> object during expansion.
/// </summary>
public sealed class ResourceGroupOption : IEquatable<ResourceGroupOption>
{
    private const string DEFAULT_SUBSCRIPTION_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
    private const string DEFAULT_NAME = "ps-rule-test-rg";
    private const string DEFAULT_TYPE = "Microsoft.Resources/resourceGroups";
    private const string DEFAULT_LOCATION = "eastus";
    private const string DEFAULT_MANAGED_BY = null;
    private const Hashtable DEFAULT_TAGS = null;
    private const string DEFAULT_PROVISIONING_STATE = "Succeeded";

    private const string ID_PREFIX = "/subscriptions/";
    private const string RGID_PREFIX = "/resourceGroups/";

    internal static readonly ResourceGroupOption Default = new()
    {
        SubscriptionId = DEFAULT_SUBSCRIPTION_ID,
        Name = DEFAULT_NAME,
        Location = DEFAULT_LOCATION,
        ManagedBy = DEFAULT_MANAGED_BY,
        Tags = new Hashtable(StringComparer.OrdinalIgnoreCase),
        Properties = new ResourceGroupProperties(DEFAULT_PROVISIONING_STATE),
    };

    private string _SubscriptionId;
    private string _Name;

    /// <summary>
    /// Creates an empty resource group option.
    /// </summary>
    public ResourceGroupOption()
    {
        Name = null;
        Location = null;
        ManagedBy = null;
        Tags = null;
        Properties = null;
    }

    internal ResourceGroupOption(ResourceGroupOption option)
    {
        if (option == null)
            return;

        Name = option.Name;
        Location = option.Location;
        ManagedBy = option.Location;
        Tags = option.Tags;
        Properties = option.Properties;
    }

    internal ResourceGroupOption(string name, string location, string managedBy, Hashtable tags, string provisioningState)
    {
        Name = name ?? DEFAULT_NAME;
        Location = location ?? DEFAULT_LOCATION;
        ManagedBy = managedBy ?? DEFAULT_MANAGED_BY;
        Tags = tags ?? new Hashtable(StringComparer.OrdinalIgnoreCase);
        Properties = new ResourceGroupProperties(provisioningState);
    }

    /// <summary>
    /// A set of resource group properties.
    /// </summary>
    public sealed class ResourceGroupProperties
    {
        /// <summary>
        /// Create default resource group properties.
        /// </summary>
        public ResourceGroupProperties()
        {
            ProvisioningState = DEFAULT_PROVISIONING_STATE;
        }

        internal ResourceGroupProperties(string provisioningState)
        {
            ProvisioningState = provisioningState ?? DEFAULT_PROVISIONING_STATE;
        }

        /// <summary>
        /// The provisioning state of the resource group.
        /// </summary>
        public string ProvisioningState { get; }

        internal static ResourceGroupProperties FromHashtable(Hashtable properties)
        {
            var option = new ResourceGroupProperties();
            if (properties != null)
            {
                var index = PSRuleOption.BuildIndex(properties);
                if (index.TryPopValue("ProvisioningState", out string s))
                    option = new ResourceGroupProperties(s);
            }
            return option;
        }
    }

    /// <inheritdoc/>
    public override bool Equals(object obj)
    {
        return obj is ResourceGroupOption option && Equals(option);
    }

    /// <inheritdoc/>
    public bool Equals(ResourceGroupOption other)
    {
        return other != null &&
            SubscriptionId == other.SubscriptionId &&
            Name == other.Name &&
            Location == other.Location &&
            ManagedBy == other.ManagedBy &&
            Tags == other.Tags &&
            Properties == other.Properties;
    }

    /// <summary>
    /// Compares two resource group options to determine if they are equal.
    /// </summary>
    public static bool operator ==(ResourceGroupOption o1, ResourceGroupOption o2)
    {
        return Equals(o1, o2);
    }

    /// <summary>
    /// Compares two resource group options to determine if they are not equal.
    /// </summary>
    public static bool operator !=(ResourceGroupOption o1, ResourceGroupOption o2)
    {
        return !Equals(o1, o2);
    }

    /// <summary>
    /// Compares two resource group options to determine if they are equal.
    /// </summary>
    public static bool Equals(ResourceGroupOption o1, ResourceGroupOption o2)
    {
        return (object.Equals(null, o1) && object.Equals(null, o2)) ||
            (!object.Equals(null, o1) && o1.Equals(o2));
    }

    /// <inheritdoc/>
    public override int GetHashCode()
    {
        unchecked // Overflow is fine
        {
            var hash = 17;
            hash = hash * 23 + (SubscriptionId != null ? SubscriptionId.GetHashCode() : 0);
            hash = hash * 23 + (Name != null ? Name.GetHashCode() : 0);
            hash = hash * 23 + (Location != null ? Location.GetHashCode() : 0);
            hash = hash * 23 + (ManagedBy != null ? ManagedBy.GetHashCode() : 0);
            hash = hash * 23 + (Tags != null ? Tags.GetHashCode() : 0);
            hash = hash * 23 + (Properties != null ? Properties.GetHashCode() : 0);
            return hash;
        }
    }

    internal static ResourceGroupOption Combine(ResourceGroupOption o1, ResourceGroupOption o2)
    {
        var result = new ResourceGroupOption()
        {
            SubscriptionId = o1?.SubscriptionId ?? o2?.SubscriptionId,
            Name = o1?.Name ?? o2?.Name,
            Location = o1?.Location ?? o2?.Location,
            ManagedBy = o1?.ManagedBy ?? o2?.ManagedBy,
            Tags = o1?.Tags ?? o2?.Tags,
            Properties = o1?.Properties ?? o2?.Properties,
        };
        return result;
    }

    /// <summary>
    /// The unique GUID associated with the subscription.
    /// </summary>
    [YamlIgnore]
    public string SubscriptionId
    {
        get => _SubscriptionId;
        set
        {
            _SubscriptionId = value;
            if (string.IsNullOrEmpty(_SubscriptionId) || string.IsNullOrEmpty(Name))
                return;

            Id = string.Concat(ID_PREFIX, _SubscriptionId, RGID_PREFIX, _Name);
        }
    }

    /// <summary>
    /// A unique identifier for the resource group.
    /// </summary>
    /// <remarks>
    /// This is a calculated property based on SubscriptionId and Name.
    /// </remarks>
    [YamlIgnore]
    public string Id { get; private set; }

    /// <summary>
    /// The name of the resource group.
    /// </summary>
    [DefaultValue(null)]
    public string Name
    {
        get => _Name;
        set
        {
            _Name = value;
            if (string.IsNullOrEmpty(_SubscriptionId) || string.IsNullOrEmpty(Name))
                return;

            Id = string.Concat(ID_PREFIX, SubscriptionId, RGID_PREFIX, _Name);
        }
    }

    /// <summary>
    /// The Azure resource type.
    /// </summary>
    [YamlIgnore]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Must be instance property for later evaluation.")]
    public string Type => DEFAULT_TYPE;

    /// <summary>
    /// The location of the resource group.
    /// </summary>
    [DefaultValue(null)]
    public string Location { get; set; }

    /// <summary>
    /// The value of the managed by property.
    /// </summary>
    [DefaultValue(null)]
    public string ManagedBy { get; set; }

    /// <summary>
    /// Any tags assigned to the resource group.
    /// </summary>
    [DefaultValue(null)]
    public Hashtable Tags { get; set; }

    /// <summary>
    /// Additional properties for the resource group.
    /// </summary>
    [DefaultValue(null)]
    public ResourceGroupProperties Properties { get; set; }

    internal static ResourceGroupOption FromHashtable(Hashtable hashtable)
    {
        var option = new ResourceGroupOption();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("SubscriptionId", out string s))
                option.SubscriptionId = s;

            if (index.TryPopValue("Name", out s))
                option.Name = s;

            if (index.TryPopValue("Location", out s))
                option.Location = s;

            if (index.TryPopValue("ManagedBy", out s))
                option.ManagedBy = s;

            if (index.TryPopValue("Tags", out Hashtable tags))
                option.Tags = tags;

            if (index.TryPopHashtable("Properties", out var properties))
                option.Properties = ResourceGroupProperties.FromHashtable(properties);
        }
        return option;
    }
}
