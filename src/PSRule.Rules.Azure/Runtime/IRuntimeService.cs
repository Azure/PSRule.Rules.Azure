// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

#nullable enable

namespace PSRule.Rules.Azure.Runtime;

/// <summary>
/// A context when running within PSRule.
/// </summary>
public interface IRuntimeService : IService
{
    /// <summary>
    /// Configures the timeout for Bicep expansion.
    /// </summary>
    int Timeout { get; }

    /// <summary>
    /// The minimum version of Bicep.
    /// </summary>
    string Minimum { get; }

    /// <summary>
    /// Specified the allowed locations for the organization.
    /// </summary>
    /// <param name="locations">Configures the allowed list of locations.</param>
    void WithAllowedLocations(string[] locations);

    /// <summary>
    /// Determines if the specified location is within the allowed set.
    /// </summary>
    /// <param name="location">The location to check.</param>
    /// <returns>Returns <c>true</c> when the location is allowed. Otherwise <c>false</c> is returned.</returns>
    bool IsAllowedLocation(string location);

    /// <summary>
    /// Configure the Azure deployment context.
    /// </summary>
    void WithAzureDeployment(PSObject? pso);

    /// <summary>
    /// Configure the Azure resource group context.
    /// </summary>
    void WithAzureResourceGroup(PSObject? pso);

    /// <summary>
    /// Configure the Azure subscription context.
    /// </summary>
    void WithAzureSubscription(PSObject? pso);

    /// <summary>
    /// Configure the Azure tenant context.
    /// </summary>
    void WithAzureTenant(PSObject? pso);

    /// <summary>
    /// Configure the Azure management group context.
    /// </summary>
    void WithAzureManagementGroup(PSObject? pso);

    /// <summary>
    /// Configure the parameter defaults.
    /// </summary>
    void WithParameterDefaults(PSObject? pso);
}

#nullable restore
