// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using Azure.Core;
using Microsoft.Extensions.Logging;
using PSRule.Rules.Azure.Patterns.Remotes;
using PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Provides methods to build a pattern registry with remote sources.
/// </summary>
/// <param name="logger">The logger to use for registry operations.</param>
public sealed class PatternRegistryBuilder(ILogger logger)
{
    private readonly List<IPatternRegistryRemote> _Remotes = [];
    private readonly ILogger _Logger = logger;

    /// <summary>
    /// Adds an Azure remote pattern registry source.
    /// </summary>
    /// <param name="uri">The URI of the Azure remote.</param>
    /// <param name="tokenCredential">The token credential for authentication.</param>
    /// <returns>The <see cref="PatternRegistryBuilder"/> instance.</returns>
    public PatternRegistryBuilder WithAzureRemote(Uri uri, TokenCredential tokenCredential)
    {
        _Remotes.Add(new ContainerRegistryPatternRemote(_Logger, uri, tokenCredential));
        return this;
    }

    /// <summary>
    /// Builds the pattern registry with the specified store path.
    /// </summary>
    /// <param name="storePath">The path to the pattern store.</param>
    /// <returns>An <see cref="IPatternRegistry"/> instance.</returns>
    public IPatternRegistry Build(string storePath)
    {
        var remotes = _Remotes.ToImmutableDictionary(
            r => r.GetType().Name,
            r => r,
            StringComparer.OrdinalIgnoreCase);

        return new WorkspacePatternRegistry(_Logger, storePath, remotes);
    }
}
