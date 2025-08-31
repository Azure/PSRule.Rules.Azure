// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using Azure.Core;
using Microsoft.Extensions.Logging;
using PSRule.Rules.Azure.Patterns.Remotes;
using PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

namespace PSRule.Rules.Azure.Patterns;

public sealed class PatternRegistryBuilder(ILogger logger)
{
    private readonly List<IPatternRegistryRemote> _Remotes = [];
    private readonly ILogger _Logger = logger;

    public PatternRegistryBuilder WithAzureRemote(Uri uri, TokenCredential tokenCredential)
    {
        _Remotes.Add(new ContainerRegistryPatternRemote(_Logger, uri, tokenCredential));
        return this;
    }

    public IPatternRegistry Build(string storePath)
    {
        var remotes = _Remotes.ToImmutableDictionary(
            r => r.GetType().Name,
            r => r,
            StringComparer.OrdinalIgnoreCase);

        return new WorkspacePatternRegistry(_Logger, storePath, remotes);
    }
}
