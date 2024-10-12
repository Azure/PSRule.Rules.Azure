// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;

namespace PSRule.Rules.Azure.Pipeline;

internal abstract class PipelineBase : IDisposable, IPipeline
{
    protected readonly PipelineContext Context;

    // Track whether Dispose has been called.
    private bool _Disposed;


    protected PipelineBase(PipelineContext context)
    {
        Context = context;
    }

    #region IPipeline

    /// <inheritdoc/>
    public virtual void Begin()
    {
        // Do nothing
    }

    /// <inheritdoc/>
    public virtual void Process(PSObject sourceObject)
    {
        // Do nothing
    }

    /// <inheritdoc/>
    public virtual void End()
    {
        Context.Writer.End();
    }

    #endregion IPipeline

    #region IDisposable

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                //Context.Dispose();
            }
            _Disposed = true;
        }
    }

    #endregion IDisposable
}
