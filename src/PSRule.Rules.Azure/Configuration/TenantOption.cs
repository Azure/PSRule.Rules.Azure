// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration
{
    /// <summary>
    /// Options that affect the properties of the <c>tenant()</c> object during expansion.
    /// </summary>
    public sealed class TenantOption : IEquatable<TenantOption>
    {
        private const string DEFAULT_COUNTRYCODE = "US";
        private const string DEFAULT_TENANTID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string DEFAULT_DISPLAYNAME = "PSRule";

        private const string ID_PREFIX = "/tenants/";

        internal static readonly TenantOption Default = new()
        {
            CountryCode = DEFAULT_COUNTRYCODE,
            TenantId = DEFAULT_TENANTID,
            DisplayName = DEFAULT_DISPLAYNAME
        };

        private string _TenantId;

        /// <summary>
        /// Creates an empty tenant option.
        /// </summary>
        public TenantOption()
        {
            CountryCode = null;
            TenantId = null;
            DisplayName = null;
        }

        internal TenantOption(TenantOption option)
        {
            if (option == null)
                return;

            CountryCode = option.CountryCode;
            TenantId = option.TenantId;
            DisplayName = option.DisplayName;
        }

        internal TenantOption(string countryCode, string tenantId, string displayName)
        {
            CountryCode = countryCode ?? DEFAULT_COUNTRYCODE;
            TenantId = tenantId ?? DEFAULT_TENANTID;
            DisplayName = displayName ?? DEFAULT_DISPLAYNAME;
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            return obj is TenantOption option && Equals(option);
        }

        /// <inheritdoc/>
        public bool Equals(TenantOption other)
        {
            return other != null &&
                CountryCode == other.CountryCode &&
                TenantId == other.TenantId &&
                DisplayName == other.DisplayName;
        }

        /// <summary>
        /// Compares two tenant options to determine if they are equal.
        /// </summary>
        public static bool operator ==(TenantOption o1, TenantOption o2)
        {
            return Equals(o1, o2);
        }

        /// <summary>
        /// Compares two tenant options to determine if they are not equal.
        /// </summary>
        public static bool operator !=(TenantOption o1, TenantOption o2)
        {
            return !Equals(o1, o2);
        }

        /// <summary>
        /// Compares two tenant options to determine if they are equal.
        /// </summary>
        public static bool Equals(TenantOption o1, TenantOption o2)
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
                hash = hash * 23 + (CountryCode != null ? CountryCode.GetHashCode() : 0);
                hash = hash * 23 + (TenantId != null ? TenantId.GetHashCode() : 0);
                hash = hash * 23 + (DisplayName != null ? DisplayName.GetHashCode() : 0);
                return hash;
            }
        }

        internal static TenantOption Combine(TenantOption o1, TenantOption o2)
        {
            var result = new TenantOption()
            {
                CountryCode = o1?.CountryCode ?? o2?.CountryCode,
                TenantId = o1?.TenantId ?? o2?.TenantId,
                DisplayName = o1?.DisplayName ?? o2?.DisplayName,
            };
            return result;
        }

        /// <summary>
        /// A country code identifier for the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string CountryCode { get; set; }

        /// <summary>
        /// A unique identifier for the tenant.
        /// </summary>
        /// <remarks>
        /// This is a calculated property based on TenantId.
        /// </remarks>
        [YamlIgnore]
        public string Id { get; private set; }

        /// <summary>
        /// The unique GUID associated with the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string TenantId
        {
            get => _TenantId;
            set
            {
                _TenantId = value;
                Id = string.Concat(ID_PREFIX, TenantId);
            }
        }

        /// <summary>
        /// The display name of the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string DisplayName { get; set; }
    }
}
