// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Data.Bicep;

namespace PSRule.Rules.Azure.Runtime
{
    /// <summary>
    /// A singleton context when running is PSRule.
    /// </summary>
    internal sealed class RuntimeService : IService
    {
        private const int BICEP_TIMEOUT_MIN = 1;
        private const int BICEP_TIMEOUT_MAX = 120;

        private bool _Disposed;

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

        /// <summary>
        /// Configures the timeout for Bicep expansion.
        /// </summary>
        public int Timeout { get; }

        /// <summary>
        /// The minimum version of Bicep.
        /// </summary>
        public string Minimum { get; }

        public BicepHelper.BicepInfo Bicep { get; internal set; }

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
