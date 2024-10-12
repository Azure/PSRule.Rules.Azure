// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Bicep;

#nullable enable

namespace PSRule.Rules.Azure.Runtime;

/// <summary>
/// A singleton context when running is PSRule.
/// </summary>
internal sealed class RuntimeService : IRuntimeService
{
    private const int BICEP_TIMEOUT_MIN = 1;
    private const int BICEP_TIMEOUT_MAX = 120;

    private bool _Disposed;
    private HashSet<string>? _AllowedLocations;
    private DeploymentOption? _AzureDeployment;
    private ResourceGroupOption? _AzureResourceGroup;
    private SubscriptionOption? _AzureSubscription;
    private TenantOption? _AzureTenant;
    private ManagementGroupOption? _AzureManagementGroup;
    private ParameterDefaultsOption? _ParameterDefaults;

    /// <summary>
    /// Create a runtime service.
    /// </summary>
    /// <param name="minimum">The minimum version of Bicep.</param>
    /// <param name="timeout">The timeout in seconds for expansion.</param>
    public RuntimeService(string minimum, int timeout)
    {
        Minimum = minimum;
        Timeout = timeout < BICEP_TIMEOUT_MIN ? BICEP_TIMEOUT_MIN : timeout;
        if (Timeout > BICEP_TIMEOUT_MAX)
            Timeout = BICEP_TIMEOUT_MAX;
    }

    /// <inheritdoc/>
    public int Timeout { get; }

    /// <inheritdoc/>
    public string Minimum { get; }

    /// <inheritdoc/>
    public BicepHelper.BicepInfo? Bicep { get; internal set; }

    /// <inheritdoc/>
    public void WithAllowedLocations(string[] locations)
    {
        if (locations == null || locations.Length == 0)
            return;

        _AllowedLocations = new HashSet<string>(LocationHelper.Comparer);
        for (var i = 0; i < locations.Length; i++)
        {
            if (!string.IsNullOrEmpty(locations[i]))
                _AllowedLocations.Add(locations[i]);
        }
    }

    /// <inheritdoc/>
    public bool IsAllowedLocation(string location)
    {
        return location == null ||
            _AllowedLocations == null ||
            _AllowedLocations.Count == 0 ||
            _AllowedLocations.Contains(location);
    }

    /// <inheritdoc/>
    public void WithAzureDeployment(PSObject? pso)
    {
        if (pso == null)
            return;

        _AzureDeployment = DeploymentOption.FromHashtable(pso.ToHashtable());
    }

    /// <inheritdoc/>
    public void WithAzureResourceGroup(PSObject? pso)
    {
        if (pso == null)
            return;

        _AzureResourceGroup = ResourceGroupOption.FromHashtable(pso.ToHashtable());
    }

    /// <inheritdoc/>
    public void WithAzureSubscription(PSObject? pso)
    {
        if (pso == null)
            return;

        _AzureSubscription = SubscriptionOption.FromHashtable(pso.ToHashtable());
    }

    /// <inheritdoc/>
    public void WithAzureTenant(PSObject? pso)
    {
        if (pso == null)
            return;

        _AzureTenant = TenantOption.FromHashtable(pso.ToHashtable());
    }

    /// <inheritdoc/>
    public void WithAzureManagementGroup(PSObject? pso)
    {
        if (pso == null)
            return;

        _AzureManagementGroup = ManagementGroupOption.FromHashtable(pso.ToHashtable());
    }

    /// <inheritdoc/>
    public void WithParameterDefaults(PSObject? pso)
    {
        if (pso == null)
            return;

        _ParameterDefaults = ParameterDefaultsOption.FromHashtable(pso.ToHashtable());
    }

    /// <summary>
    /// Get options for the current runtime state.
    /// </summary>
    internal PSRuleOption ToPSRuleOption()
    {
        var option = PSRuleOption.FromFileOrDefault(PSRuleOption.GetWorkingPath());

        option.Configuration.Deployment = DeploymentOption.Combine(_AzureDeployment, option.Configuration.Deployment);
        option.Configuration.ResourceGroup = ResourceGroupOption.Combine(_AzureResourceGroup, option.Configuration.ResourceGroup);
        option.Configuration.Subscription = SubscriptionOption.Combine(_AzureSubscription, option.Configuration.Subscription);
        option.Configuration.Tenant = TenantOption.Combine(_AzureTenant, option.Configuration.Tenant);
        option.Configuration.ManagementGroup = ManagementGroupOption.Combine(_AzureManagementGroup, option.Configuration.ManagementGroup);
        option.Configuration.ParameterDefaults = ParameterDefaultsOption.Combine(_ParameterDefaults, option.Configuration.ParameterDefaults);
        option.Configuration.BicepFileExpansionTimeout = Timeout;
        option.Configuration.BicepMinimumVersion = Minimum;

        return option;
    }

    #region IDisposable

    private void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                Bicep = null;
            }
            _Disposed = true;
        }
    }

    public void Dispose()
    {
        // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        Dispose(disposing: true);
        System.GC.SuppressFinalize(this);
    }

    #endregion IDisposable
}

#nullable restore
