// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// Options that affect the properties of the <c>deployer()</c> object during expansion.
/// </summary>
public sealed class DeployerOption : IEquatable<DeployerOption>
{
    private const string DEFAULT_TENANT_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
    private const string DEFAULT_OBJECT_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
    private const string DEFAULT_USER_PRINCIPAL_NAME = "psrule-test@contoso.com";

    internal static readonly DeployerOption Default = new()
    {
        ObjectId = DEFAULT_OBJECT_ID,
        TenantId = DEFAULT_TENANT_ID,
        UserPrincipalName = DEFAULT_USER_PRINCIPAL_NAME
    };

    /// <summary>
    /// Creates an empty tenant option.
    /// </summary>
    public DeployerOption()
    {
        ObjectId = null;
        TenantId = null;
        UserPrincipalName = null;
    }

    internal DeployerOption(DeployerOption option)
    {
        if (option == null)
            return;

        ObjectId = option.ObjectId;
        TenantId = option.TenantId;
        UserPrincipalName = option.UserPrincipalName;
    }

    internal DeployerOption(string objectId, string tenantId, string userPrincipalName)
    {
        ObjectId = objectId ?? DEFAULT_OBJECT_ID;
        TenantId = tenantId ?? DEFAULT_TENANT_ID;
        UserPrincipalName = userPrincipalName ?? DEFAULT_USER_PRINCIPAL_NAME;
    }

    /// <inheritdoc/>
    public override bool Equals(object obj)
    {
        return obj is DeployerOption option && Equals(option);
    }

    /// <inheritdoc/>
    public bool Equals(DeployerOption other)
    {
        return other != null &&
            ObjectId == other.ObjectId &&
            TenantId == other.TenantId &&
            UserPrincipalName == other.UserPrincipalName;
    }

    /// <summary>
    /// Compares two deployer options to determine if they are equal.
    /// </summary>
    public static bool operator ==(DeployerOption o1, DeployerOption o2)
    {
        return Equals(o1, o2);
    }

    /// <summary>
    /// Compares two deployer options to determine if they are not equal.
    /// </summary>
    public static bool operator !=(DeployerOption o1, DeployerOption o2)
    {
        return !Equals(o1, o2);
    }

    /// <summary>
    /// Compares two deployer options to determine if they are equal.
    /// </summary>
    public static bool Equals(DeployerOption o1, DeployerOption o2)
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
            hash = hash * 23 + (ObjectId != null ? ObjectId.GetHashCode() : 0);
            hash = hash * 23 + (TenantId != null ? TenantId.GetHashCode() : 0);
            hash = hash * 23 + (UserPrincipalName != null ? UserPrincipalName.GetHashCode() : 0);
            return hash;
        }
    }

    internal static DeployerOption Combine(DeployerOption o1, DeployerOption o2)
    {
        var result = new DeployerOption()
        {
            ObjectId = o1?.ObjectId ?? o2?.ObjectId,
            TenantId = o1?.TenantId ?? o2?.TenantId,
            UserPrincipalName = o1?.UserPrincipalName ?? o2?.UserPrincipalName,
        };
        return result;
    }

    internal static DeployerOption FromHashtable(Hashtable hashtable)
    {
        var result = new DeployerOption();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("ObjectId", out string objectId))
                result.ObjectId = objectId;

            if (index.TryPopValue("TenantId", out string tenantId))
                result.TenantId = tenantId;

            if (index.TryPopValue("UserPrincipalName", out string userPrincipalName))
                result.UserPrincipalName = userPrincipalName;
        }
        return result;
    }

    /// <summary>
    /// The unique GUID for the object.
    /// </summary>
    [DefaultValue(null)]
    public string ObjectId { get; set; }

    /// <summary>
    /// The unique GUID associated with the tenant.
    /// </summary>
    [DefaultValue(null)]
    public string TenantId { get; set; }

    /// <summary>
    /// The user principal name (UPN) for the object.
    /// </summary>
    [DefaultValue(null)]
    public string UserPrincipalName { get; set; }
}
