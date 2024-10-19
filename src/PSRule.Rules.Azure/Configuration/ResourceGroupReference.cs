// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// A reference to a resource group.
/// </summary>
public sealed class ResourceGroupReference
{
    private ResourceGroupReference() { }

    private ResourceGroupReference(string name)
    {
        Name = name;
        FromName = true;
    }

    /// <summary>
    /// The name of the resource group.
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// The location of the resource group.
    /// </summary>
    public string Location { get; set; }

    /// <summary>
    /// The value of the managed by property.
    /// </summary>
    public string ManagedBy { get; set; }

    /// <summary>
    /// Any tags assigned to the resource group.
    /// </summary>
    public Hashtable Tags { get; set; }

    /// <summary>
    /// The provisioning state for the resource group.
    /// </summary>
    public string ProvisioningState { get; set; }

    /// <summary>
    /// Determines if the reference is created from a resource group name.
    /// </summary>
    public bool FromName { get; private set; }

    /// <summary>
    /// Create a resource group reference from a hashtable.
    /// </summary>
    public static implicit operator ResourceGroupReference(Hashtable hashtable)
    {
        return FromHashtable(hashtable);
    }

    /// <summary>
    /// Create a resource group reference from a resource group name.
    /// </summary>
    public static implicit operator ResourceGroupReference(string resourceGroupName)
    {
        return FromString(resourceGroupName);
    }

    /// <summary>
    /// Create a resource group reference from a hashtable.
    /// </summary>
    public static ResourceGroupReference FromHashtable(Hashtable hashtable)
    {
        var option = new ResourceGroupReference();
        if (hashtable != null)
        {
            var index = PSRuleOption.BuildIndex(hashtable);
            if (index.TryPopValue("Name", out string svalue))
                option.Name = svalue;

            if (index.TryPopValue("Location", out svalue))
                option.Location = svalue;

            if (index.TryPopValue("ManagedBy", out svalue))
                option.ManagedBy = svalue;

            if (index.TryPopValue("ProvisioningState", out svalue))
                option.ProvisioningState = svalue;

            if (index.TryPopValue("Tags", out Hashtable tags))
                option.Tags = tags;
        }
        return option;
    }

    /// <summary>
    /// Create a resource group reference from a resource group name.
    /// </summary>
    public static ResourceGroupReference FromString(string resourceGroupName)
    {
        return new ResourceGroupReference(resourceGroupName);
    }

    /// <summary>
    /// Convert the reference to an option.
    /// </summary>
    public ResourceGroupOption ToResourceGroupOption()
    {
        return new ResourceGroupOption(Name, Location, ManagedBy, Tags, ProvisioningState);
    }
}
