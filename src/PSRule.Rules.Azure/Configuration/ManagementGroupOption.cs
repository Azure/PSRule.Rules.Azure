// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration
{
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

        internal readonly static ManagementGroupOption Default = new ManagementGroupOption
        {
            Name = DEFAULT_NAME,
            Properties = new ManagementGroupProperties(DEFAULT_DISPLAYNAME, DEFAULT_TENANTID),
        };

        private string _Name;

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

        public sealed class ManagementGroupProperties
        {
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

            [DefaultValue(null)]
            public string DisplayName { get; set; }

            [YamlIgnore]
            public string TenantId { get; internal set; }

            public ManagementGroupDetails Details { get; internal set; }
        }

        public sealed class ManagementGroupDetails
        {
            public ManagementGroupDetails()
            {
                Parent = new ManagementGroupParent();
                UpdatedBy = DEFAULT_UPDATEDBY;
                UpdatedTime = DEFAULT_UPDATEDTIME;
                Version = DEFAULT_VERSION;
            }

            [YamlIgnore]
            public ManagementGroupParent Parent { get; private set; }

            [DefaultValue(null)]
            public string UpdatedBy { get; set; }

            [DefaultValue(null)]
            public string UpdatedTime { get; set; }

            [DefaultValue(null)]
            public string Version { get; set; }
        }

        public sealed class ManagementGroupParent
        {
            private string _Name;

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

            [YamlIgnore]
            public string Id { get; private set; }

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

            [DefaultValue(null)]
            public string DisplayName { get; set; }
        }

        public override bool Equals(object obj)
        {
            return obj is ManagementGroupOption option && Equals(option);
        }

        public bool Equals(ManagementGroupOption other)
        {
            return other != null &&
                Name == other.Name &&
                Properties == other.Properties;
        }

        public static bool operator ==(ManagementGroupOption o1, ManagementGroupOption o2)
        {
            return Equals(o1, o2);
        }

        public static bool operator !=(ManagementGroupOption o1, ManagementGroupOption o2)
        {
            return !Equals(o1, o2);
        }

        public static bool Equals(ManagementGroupOption o1, ManagementGroupOption o2)
        {
            return (object.Equals(null, o1) && object.Equals(null, o2)) ||
                (!object.Equals(null, o1) && o1.Equals(o2));
        }

        public override int GetHashCode()
        {
            unchecked // Overflow is fine
            {
                int hash = 17;
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

        [YamlIgnore]
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

        public ManagementGroupProperties Properties { get; set; }
    }
}
