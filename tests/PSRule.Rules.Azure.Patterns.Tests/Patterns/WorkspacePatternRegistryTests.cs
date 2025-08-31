// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using Microsoft.Extensions.Logging.Abstractions;
using PSRule.Rules.Azure.Patterns.Remotes;
using PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Unit tests for <see cref="WorkspacePatternRegistry"/>.
/// </summary>
public sealed class WorkspacePatternRegistryTests : BaseTests
{
    [Fact]
    public async Task ListAsync_WhenStoreIsEmpty_ShouldReturnNoPatterns()
    {
        var remotes = new Dictionary<string, IPatternRegistryRemote>
        {
            { typeof(ContainerRegistryPatternRemote).Name, new TestRemote() }
        }.ToImmutableDictionary();

        var registry = new WorkspacePatternRegistry(NullLogger.Instance, GetSourcePath("store-empty"), remotes);

        var actual = await registry.ListAsync();
        Assert.NotNull(actual);
        Assert.Empty(actual);
    }
}
