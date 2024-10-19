// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// Options that affect the properties of the <c>managementGroup()</c> object during expansion.
/// </summary>
public sealed class ManagementGroupOption : IEquatable<ManagementGroupOption>
{
    private const string DEFAULT_NAME = "psrule-test";
    private const string DEFAULT_DISPLAYNAME = "PSRule Test Management Group";
    private const string DEFAULT_TENANTID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
    private const string DEFAULT_UPDATEDBY = "00000000-0000-0000-0000-000000000000";
    private const string DEFAULT_UPDATEDTIME = "2020-07-23T21:05:52.661306Z";
    private const string DEFAULT_VERSION = "1";
    private const string DEFAULT_PARENT_DISPLAYNAME = "Tenant Root Group";

    private const string DEFAULT_TYPE = "/providers/Microsoft.Management/managementGroups";

    internal static readonly ManagementGroupOption Default = new()
    {
        Name = DEFAULT_NAME,
        Properties = new ManagementGroupProperties(DEFAULT_DISPLAYNAME, DEFAULT_TENANTID),
    };

    private string _Name;

    /// <summary>
    /// Creates an empty management group option.
    /// </summary>
    public ManagementGroupOption()
    {
        Name = null;
        Properties = null;
    }

    internal ManagementGroupOption(ManagementGroupOption option)
    {
        if (option == null)
            return;

        Name = option.Name;
        Properties = option.Properties;
    }

    internal ManagementGroupOption(string name, string displayName, string tenantId)
    {
        Name = name ?? DEFAULT_NAME;
        Properties = new ManagementGroupProperties(displayName, tenantId);
    }

    /// <summary>
    /// Properties for the management group.
    /// </summary>
    public sealed class ManagementGroupProperties
    {
        /// <summary>
        /// Create a default management group properties.
        /// </summary>
        public ManagementGroupProperties()
        {
            DisplayName = DEFAULT_DISPLAYNAME;
            TenantId = DEFAULT_TENANTID;
            Details = new ManagementGroupDetails();
        }

        internal ManagementGroupProperties(string displayName, string tenantId)
        {
            DisplayName = displayName ?? DEFAULT_DISPLAYNAME;
            TenantId = tenantId ?? DEFAULT_TENANTID;
            Details = new ManagementGroupDetails();
        }

        /// <summary>
        /// The display name of the management group.
        /// </summary>
        [DefaultValue(null)]
        public string DisplayName { get; set; }

        /// <summary>
        /// A GUID for the tenant that the management group belongs to.
        /// </summary>
        [YamlIgnore]
        public string TenantId { get; internal set; }

        /// <summary>
        /// Additional details of the management group.
        /// </summary>
        public ManagementGroupDetails Details { get; internal set; }

        internal static ManagementGroupProperties FromHashtable(Hashtable properties)
        {
            var result = new ManagementGroupProperties();
            if (properties != null)
            {
                var index = PSRuleOption.BuildIndex(properties);
                if (index.TryPopValue("DisplayName", out string displayName))
                    result.DisplayName = displayName;

                if (index.TryPopValue("TenantId", out string tenantId))
                    result.TenantId = tenantId;

                if (index.TryPopHashtable("Details", out var details))
                    result.Details = ManagementGroupDetails.FromHashtable(details);
            }
            return result;
        }
    }

    /// <summary>
    /// Details for the management group.
    /// </summary>
    public sealed class ManagementGroupDetails
    {
        /// <summary>
        /// Create a default management group details.
        /// </summary>
        public ManagementGroupDetails()
        {
            Parent = new ManagementGroupParent();
            UpdatedBy = DEFAULT_UPDATEDBY;
            UpdatedTime = DEFAULT_UPDATEDTIME;
            Version = DEFAULT_VERSION;
        }

        /// <summary>
        /// Additional details about the parent of the management group.
        /// </summary>
        [YamlIgnore]
        public ManagementGroupParent Parent { get; private set; }

        /// <summary>
        /// What identity last updated the management group.
        /// </summary>
        [DefaultValue(null)]
        public string UpdatedBy { get; set; }

        /// <summary>
        /// When the management group was last updated.
        /// </summary>
        [DefaultValue(null)]
        public string UpdatedTime { get; set; }

        /// <summary>
        /// The version.
        /// </summary>
        [DefaultValue(null)]
        public string Version { get; set; }

        internal static ManagementGroupDetails FromHashtable(Hashtable details)
        {
            var result = new ManagementGroupDetails();
            if (details != null)
            {
                var index = PSRuleOption.BuildIndex(details);
                if (index.TryPopHashtable("Parent", out var parent))
                    result.Parent = ManagementGroupParent.FromHashtable(parent);

                if (index.TryPopValue("UpdatedBy", out string updatedBy))
                    result.UpdatedBy = updatedBy;

                if (index.TryPopValue("UpdatedTime", out string updatedTime))
                    result.UpdatedTime = updatedTime;

                if (index.TryPopValue("Version", out string version))
                    result.Version = version;
            }
            return result;
        }
    }

    /// <summary>
    /// Parent properties for the management group.
    /// </summary>
    public sealed class ManagementGroupParent
    {
        private string _Name;

        /// <summary>
        /// Create a default management group parent.
        /// </summary>
        public ManagementGroupParent()
        {
            Name = DEFAULT_TENANTID;
            DisplayName = DEFAULT_PARENT_DISPLAYNAME;
        }

        internal ManagementGroupParent(string name, string displayName)
        {
            Name = name ?? DEFAULT_TENANTID;
            DisplayName = displayName ?? DEFAULT_PARENT_DISPLAYNAME;
        }

        /// <summary>
        /// The resource identifier for the parent.
        /// </summary>
        [YamlIgnore]
        public string Id { get; private set; }

        /// <summary>
        /// The name of the parent.
        /// </summary>
        [DefaultValue(null)]
        public string Name
        {
            get { return _Name; }
            set
            {
                _Name = value;
                Id = string.Concat(DEFAULT_TYPE, "/", _Name);
            }
        }

        /// <summary>
        /// The display name of the parent.
        /// </summary>
        [DefaultValue(null)]
        public string DisplayName { get; set; }

        internal static ManagementGroupParent FromHashtable(Hashtable parent)
        {
            var result = new ManagementGroupParent();
            if (parent != null)
            {
                var index = PSRuleOption.BuildIndex(parent);
                if (index.TryPopValue("Name", out string name))
                    result.Name = name;

                if (index.TryPopValue("DisplayName", out string displayName))
                    result.DisplayName = displayName;
            }
            return result;
        }
    }

    /// <inheritdoc/>
    public override bool Equals(object obj)
    {
        return obj is ManagementGroupOption option && Equals(option);
    }

    /// <inheritdoc/>
    public bool Equals(ManagementGroupOption other)
    {
        return other != null &&
            Name == other.Name &&
            Properties == other.Properties;
    }

    /// <summary>
    /// Compares two management group options to determine if they are equal.
    /// </summary>
    public static bool operator ==(ManagementGroupOption o1, ManagementGroupOption o2)
    {
        return Equals(o1, o2);
    }

    /// <summary>
    /// Compares two management group options to determine if they are not equal.
    /// </summary>
    public static bool operator !=(ManagementGroupOption o1, ManagementGroupOption o2)
    {
        return !Equals(o1, o2);
    }

    /// <summary>
    /// Compares two management group options to determine if they are equal.
    /// </summary>
    public static bool Equals(ManagementGroupOption o1, ManagementGroupOption o2)
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
            hash = hash * 23 + (Name != null ? Name.GetHashCode() : 0);
            hash = hash * 23 + (Properties != null ? Properties.GetHashCode() : 0);
            return hash;
        }
    }

    internal static ManagementGroupOption Combine(ManagementGroupOption o1, ManagementGroupOption o2)
    {
        var result = new ManagementGroupOption()
        {
            Name = o1?.Name ?? o2?.Name,
            Properties = o1?.Properties ?? o2?.Properties,
        };
        return result;
    }

    /// <summary>
    /// The Azure resource type.
    /// </summary>
    [YamlIgnore]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Must be instance property for later evaluation.")]
    public string Type => DEFAULT_TYPE;

    /// <summary>
    /// A unique identifier for the management group.
    /// </summary>
    /// <remarks>
    /// This is a calculated property based on Name.
    /// </remarks>
    [YamlIgnore]
    public string Id { get; private set; }

    /// <summary>
    /// The name of the management group.
    /// </summary>
    [DefaultValue(null)]
    public string Name
    {
        get => _Name;
        set
        {
            _Name = value;
            Id = string.Concat(DEFAULT_TYPE, "/", Name);
        }
    }

    /// <summary>
    /// Additional properties of the management group.
    /// </summary>
    public ManagementGroupProperties Properties { get; set; }

    internal static ManagementGroupOption FromHashtable(Hashtable hashtable)
    {
        var option = new ManagementGroupOption();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("Name", out string name))
                option.Name = name;

            if (index.TryPopHashtable("Properties", out var properties))
                option.Properties = ManagementGroupProperties.FromHashtable(properties);
        }
        return option;
    }
}
