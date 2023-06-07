// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration
{
    /// <summary>
    /// Options that affect the properties of the <c>subscription()</c> object during expansion.
    /// </summary>
    public sealed class SubscriptionOption : IEquatable<SubscriptionOption>
    {
        private const string DEFAULT_SUBSCRIPTIONID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string DEFAULT_TENANTID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string DEFAULT_DISPLAYNAME = "PSRule Test Subscription";
        private const string DEFAULT_STATE = "NotDefined";

        private const string ID_PREFIX = "/subscriptions/";

        internal static readonly SubscriptionOption Default = new()
        {
            SubscriptionId = DEFAULT_SUBSCRIPTIONID,
            TenantId = DEFAULT_TENANTID,
            DisplayName = DEFAULT_DISPLAYNAME,
            State = DEFAULT_STATE
        };

        private string _SubscriptionId;

        /// <summary>
        /// Creates an empty subscription option.
        /// </summary>
        public SubscriptionOption()
        {
            SubscriptionId = null;
            TenantId = null;
            DisplayName = null;
            State = null;
        }

        internal SubscriptionOption(SubscriptionOption option)
        {
            if (option == null)
                return;

            SubscriptionId = option.SubscriptionId;
            TenantId = option.TenantId;
            DisplayName = option.DisplayName;
            State = option.State;
        }

        internal SubscriptionOption(string subscriptionId, string tenantId, string displayName, string state)
        {
            SubscriptionId = subscriptionId ?? DEFAULT_SUBSCRIPTIONID;
            TenantId = tenantId ?? DEFAULT_TENANTID;
            DisplayName = displayName ?? DEFAULT_DISPLAYNAME;
            State = state ?? DEFAULT_STATE;
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            return obj is SubscriptionOption option && Equals(option);
        }

        /// <inheritdoc/>
        public bool Equals(SubscriptionOption other)
        {
            return other != null &&
                SubscriptionId == other.SubscriptionId &&
               TenantId == other.TenantId &&
                DisplayName == other.DisplayName &&
                State == other.State;
        }

        /// <summary>
        /// Compares two subscription options to determine if they are equal.
        /// </summary>
        public static bool operator ==(SubscriptionOption o1, SubscriptionOption o2)
        {
            return Equals(o1, o2);
        }

        /// <summary>
        /// Compares two subscription options to determine if they are not equal.
        /// </summary>
        public static bool operator !=(SubscriptionOption o1, SubscriptionOption o2)
        {
            return !Equals(o1, o2);
        }

        /// <summary>
        /// Compares two subscription options to determine if they are equal.
        /// </summary>
        public static bool Equals(SubscriptionOption o1, SubscriptionOption o2)
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
                hash = hash * 23 + (TenantId != null ? TenantId.GetHashCode() : 0);
                hash = hash * 23 + (DisplayName != null ? DisplayName.GetHashCode() : 0);
                hash = hash * 23 + (State != null ? State.GetHashCode() : 0);
                return hash;
            }
        }

        internal static SubscriptionOption Combine(SubscriptionOption o1, SubscriptionOption o2)
        {
            var result = new SubscriptionOption()
            {
                SubscriptionId = o1?.SubscriptionId ?? o2?.SubscriptionId,
                TenantId = o1?.TenantId ?? o2?.TenantId,
                DisplayName = o1?.DisplayName ?? o2?.DisplayName,
                State = o1?.State ?? o2?.State,
            };
            return result;
        }

        /// <summary>
        /// A unique identifier for the subscription.
        /// </summary>
        /// <remarks>
        /// This is a calculated property based on SubscriptionId.
        /// </remarks>
        [YamlIgnore]
        public string Id { get; private set; }

        /// <summary>
        /// The unique GUID associated with the subscription.
        /// </summary>
        [DefaultValue(null)]
        public string SubscriptionId
        {
            get => _SubscriptionId;
            set
            {
                _SubscriptionId = value;
                Id = string.Concat(ID_PREFIX, SubscriptionId);
            }
        }

        /// <summary>
        /// A GUID identifier for the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string TenantId { get; set; }

        /// <summary>
        /// The display name of the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string DisplayName { get; set; }

        /// <summary>
        /// The current state of the tenant.
        /// </summary>
        [DefaultValue(null)]
        public string State { get; set; }
    }

    /// <summary>
    /// A reference to a subscription.
    /// </summary>
    public sealed class SubscriptionReference
    {
        private SubscriptionReference() { }

        private SubscriptionReference(string displayName)
        {
            DisplayName = displayName;
            FromName = true;
        }

        /// <summary>
        /// A unique identifier for the subscription.
        /// </summary>
        public string SubscriptionId { get; set; }

        /// <summary>
        /// A GUID identifier for the tenant.
        /// </summary>
        public string TenantId { get; set; }

        /// <summary>
        /// The display name of the tenant.
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// The current state of the tenant.
        /// </summary>
        public string State { get; set; }

        /// <summary>
        /// Determines if the reference is created from a display name.
        /// </summary>
        public bool FromName { get; private set; }

        /// <summary>
        /// Create a subscription reference from a hashtable.
        /// </summary>
        public static implicit operator SubscriptionReference(Hashtable hashtable)
        {
            return FromHashtable(hashtable);
        }

        /// <summary>
        /// Create a subscription reference from a display name.
        /// </summary>
        public static implicit operator SubscriptionReference(string displayName)
        {
            return FromString(displayName);
        }

        /// <summary>
        /// Create a subscription reference from a hashtable.
        /// </summary>
        public static SubscriptionReference FromHashtable(Hashtable hashtable)
        {
            var option = new SubscriptionReference();
            if (hashtable != null)
            {
                var index = PSRuleOption.BuildIndex(hashtable);
                if (index.TryPopValue("SubscriptionId", out string svalue))
                    option.SubscriptionId = svalue;

                if (index.TryPopValue("TenantId", out svalue))
                    option.TenantId = svalue;

                if (index.TryPopValue("DisplayName", out svalue))
                    option.DisplayName = svalue;

                if (index.TryPopValue("State", out svalue))
                    option.State = svalue;
            }
            return option;
        }

        /// <summary>
        /// Create a subscription reference from a display name.
        /// </summary>
        public static SubscriptionReference FromString(string displayName)
        {
            return new SubscriptionReference(displayName);
        }

        /// <summary>
        /// Convert the reference to an option.
        /// </summary>
        public SubscriptionOption ToSubscriptionOption()
        {
            return new SubscriptionOption(SubscriptionId, TenantId, DisplayName, State);
        }
    }
}
