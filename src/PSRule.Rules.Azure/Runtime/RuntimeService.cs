// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Data.Bicep;

namespace PSRule.Rules.Azure.Runtime
{
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
    }

    /// <summary>
    /// A singleton context when running is PSRule.
    /// </summary>
    internal sealed class RuntimeService : IRuntimeService
    {
        private const int BICEP_TIMEOUT_MIN = 1;
        private const int BICEP_TIMEOUT_MAX = 120;

        private bool _Disposed;
        private HashSet<string> _AllowedLocations;

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
        public BicepHelper.BicepInfo Bicep { get; internal set; }

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
}
