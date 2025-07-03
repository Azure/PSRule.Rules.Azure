// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A pipeline that exports data from Azure Policy assignments based on a hash of the scope.
/// </summary>
internal sealed class PolicyAssignmentDataOutputPathGenerator : IOutputPathGenerator, IDisposable
{
    private static readonly CultureInfo AzureCulture = new("en-US");
    private readonly SHA512 _HashAlgorithm = SHA512.Create();
    private bool _Disposed;

    /// <inheritdoc/>
    public string GenerateOutputPath(string outputPath, string key)
    {
        return Path.Combine(outputPath, $"policy-{GetKeyHash(key)}.assignment.json");
    }

    private string GetKeyHash(string key)
    {
        var hash = _HashAlgorithm.ComputeHash(Encoding.UTF8.GetBytes(key));
        var builder = new StringBuilder();
        for (var i = 0; i < hash.Length && i < 7; i++)
            builder.Append(hash[i].ToString("x2", AzureCulture));

        return builder.ToString();
    }

    private void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                _HashAlgorithm.Dispose();
            }
            _Disposed = true;
        }
    }

    public void Dispose()
    {
        // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        Dispose(disposing: true);
        GC.SuppressFinalize(this);
    }
}
