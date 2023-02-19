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
        private bool _Disposed;

        public RuntimeService()
        {

        }

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
