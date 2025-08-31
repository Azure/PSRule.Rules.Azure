// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Patterns.Remotes;

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Test implementation of <see cref="IPatternRegistryRemote"/> for unit testing.
/// </summary>
internal sealed class TestRemote : IPatternRegistryRemote
{
    public Task<IEnumerable<PatternDescriptor>> FetchAsync(string? prefix, CancellationToken cancellationToken = default)
    {
        throw new NotImplementedException();
    }

    public Task<Pattern?> PullAsync(PatternDescriptor descriptor, CancellationToken cancellationToken = default)
    {
        throw new NotImplementedException();
    }

    public Task<PatternDescriptor?> PushAsync(PatternDescriptor descriptor, Pattern pattern, CancellationToken cancellationToken = default)
    {
        throw new NotImplementedException();
    }
}
