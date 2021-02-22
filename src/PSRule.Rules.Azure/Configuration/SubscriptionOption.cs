// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using System.ComponentModel;
using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Configuration
{
    public sealed class SubscriptionOption
    {
        private const string DEFAULT_SUBSCRIPTIONID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string DEFAULT_TENANTID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string DEFAULT_DISPLAYNAME = "PSRule Test Subscription";
        private const string DEFAULT_STATE = "NotDefined";

        private const string ID_PREFIX = "/subscriptions/";

        internal readonly static SubscriptionOption Default = new SubscriptionOption
        {
            SubscriptionId = DEFAULT_SUBSCRIPTIONID,
            TenantId = DEFAULT_TENANTID,
            DisplayName = DEFAULT_DISPLAYNAME,
            State = DEFAULT_STATE
        };

        private string _SubscriptionId;

        public SubscriptionOption()
        {
            SubscriptionId = null;
            TenantId = null;
            DisplayName = null;
            State = null;
        }

        internal SubscriptionOption(string subscriptionId, string tenantId, string displayName, string state)
        {
            SubscriptionId = subscriptionId ?? DEFAULT_SUBSCRIPTIONID;
            TenantId = tenantId ?? DEFAULT_TENANTID;
            DisplayName = displayName ?? DEFAULT_DISPLAYNAME;
            State = state ?? DEFAULT_STATE;
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
            get { return _SubscriptionId; }
            set
            {
                _SubscriptionId = value;
                Id = string.Concat(ID_PREFIX, SubscriptionId);
            }
        }

        [DefaultValue(null)]
        public string TenantId { get; set; }

        [DefaultValue(null)]
        public string DisplayName { get; set; }

        [DefaultValue(null)]
        public string State { get; set; }
    }

    public sealed class SubscriptionReference
    {
        private SubscriptionReference() { }

        private SubscriptionReference(string displayName)
        {
            DisplayName = displayName;
            FromName = true;
        }

        public string SubscriptionId { get; set; }

        public string TenantId { get; set; }

        public string DisplayName { get; set; }

        public string State { get; set; }

        public bool FromName { get; private set; }

        public static implicit operator SubscriptionReference(Hashtable hashtable)
        {
            return FromHashtable(hashtable);
        }

        public static implicit operator SubscriptionReference(string displayName)
        {
            return FromString(displayName);
        }

        public static SubscriptionReference FromHashtable(Hashtable hashtable)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            var option = new SubscriptionReference();
            if (index.TryPopValue("SubscriptionId", out string svalue))
                option.SubscriptionId = svalue;

            if (index.TryPopValue("TenantId", out svalue))
                option.TenantId = svalue;

            if (index.TryPopValue("DisplayName", out svalue))
                option.DisplayName = svalue;

            if (index.TryPopValue("State", out svalue))
                option.State = svalue;

            return option;
        }

        public static SubscriptionReference FromString(string displayName)
        {
            return new SubscriptionReference(displayName);
        }

        public SubscriptionOption ToSubscriptionOption()
        {
            return new SubscriptionOption(SubscriptionId, TenantId, DisplayName, State);
        }
    }
}
