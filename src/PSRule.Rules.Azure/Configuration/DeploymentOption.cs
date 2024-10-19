// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// Options that affect the properties of the <c>deployment()</c> object during expansion.
/// </summary>
public sealed class DeploymentOption : IEquatable<DeploymentOption>
{
    private const string DEFAULT_NAME = "ps-rule-test-deployment";

    internal static readonly DeploymentOption Default = new()
    {
        Name = DEFAULT_NAME
    };

    /// <summary>
    /// Creates an empty deployment option.
    /// </summary>
    public DeploymentOption()
    {
        Name = null;
    }

    internal DeploymentOption(DeploymentOption option)
    {
        if (option == null)
            return;

        Name = option.Name;
    }

    internal DeploymentOption(string name)
    {
        Name = name ?? DEFAULT_NAME;
    }

    /// <inheritdoc/>
    public override bool Equals(object obj)
    {
        return obj is DeploymentOption option && Equals(option);
    }

    /// <inheritdoc/>
    public bool Equals(DeploymentOption other)
    {
        return other != null &&
            Name == other.Name;
    }

    /// <summary>
    /// Compares two deployment options to determine if they are equal.
    /// </summary>
    public static bool operator ==(DeploymentOption o1, DeploymentOption o2)
    {
        return Equals(o1, o2);
    }

    /// <summary>
    /// Compares two deployment options to determine if they are not equal.
    /// </summary>
    public static bool operator !=(DeploymentOption o1, DeploymentOption o2)
    {
        return !Equals(o1, o2);
    }

    /// <summary>
    /// Compares two deployment options to determine if they are equal.
    /// </summary>
    public static bool Equals(DeploymentOption o1, DeploymentOption o2)
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
            return hash;
        }
    }

    internal static DeploymentOption Combine(DeploymentOption o1, DeploymentOption o2)
    {
        var result = new DeploymentOption()
        {
            Name = o1?.Name ?? o2?.Name,
        };
        return result;
    }

    /// <summary>
    /// The name of the deployment.
    /// </summary>
    [DefaultValue(null)]
    public string Name { get; set; }

    internal static DeploymentOption FromHashtable(Hashtable hashtable)
    {
        var option = new DeploymentOption();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("Name", out string s))
                option.Name = s;
        }
        return option;
    }
}

/// <summary>
/// A reference to a deployment.
/// </summary>
public sealed class DeploymentReference
{
    private DeploymentReference() { }

    private DeploymentReference(string name)
    {
        Name = name;
        FromName = true;
    }

    /// <summary>
    /// The name of the deployment.
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// Determines if the reference is created from a display name.
    /// </summary>
    public bool FromName { get; private set; }

    /// <summary>
    /// Create a deployment reference from a hashtable.
    /// </summary>
    public static implicit operator DeploymentReference(Hashtable hashtable)
    {
        return FromHashtable(hashtable);
    }

    /// <summary>
    /// Create a deployment reference from a name.
    /// </summary>
    public static implicit operator DeploymentReference(string deploymentName)
    {
        return FromString(deploymentName);
    }

    /// <summary>
    /// Create a deployment reference from a hashtable.
    /// </summary>
    public static DeploymentReference FromHashtable(Hashtable hashtable)
    {
        var option = new DeploymentReference();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("Name", out string s))
                option.Name = s;
        }
        return option;
    }

    /// <summary>
    /// Create a deployment reference from a name.
    /// </summary>
    public static DeploymentReference FromString(string deploymentName)
    {
        return new DeploymentReference(deploymentName);
    }

    /// <summary>
    /// Convert the reference to an option.
    /// </summary>
    public DeploymentOption ToDeploymentOption()
    {
        return new DeploymentOption(Name);
    }
}
