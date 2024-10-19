// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;

namespace PSRule.Rules.Azure.Configuration;

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
            if (index.TryPopValue("SubscriptionId", out string s))
                option.SubscriptionId = s;

            if (index.TryPopValue("TenantId", out s))
                option.TenantId = s;

            if (index.TryPopValue("DisplayName", out s))
                option.DisplayName = s;

            if (index.TryPopValue("State", out s))
                option.State = s;
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
