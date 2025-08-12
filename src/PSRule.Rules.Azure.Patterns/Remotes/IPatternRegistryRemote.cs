// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns.Remotes;

/// <summary>
/// A collection of patterns that are stored remotely.
/// </summary>
public interface IPatternRegistryRemote
{
    /// <summary>
    /// Fetch patterns from the registry that match the specified prefix.
    /// </summary>
    /// <param name="prefix">The prefix to match against pattern names.</param>
    /// <param name="cancellationToken">A <see cref="CancellationToken"/> to cancel the operation.</param>
    /// <returns>Patterns are returned as a collection of <see cref="PatternDescriptor"/> objects.</returns>
    Task<IEnumerable<PatternDescriptor>> FetchAsync(string? prefix, CancellationToken cancellationToken = default);

    /// <summary>
    /// Push a pattern to the registry.
    /// </summary>
    /// <param name="descriptor">A <see cref="PatternDescriptor"/> that describes the pattern.</param>
    /// <param name="pattern">A <see cref="Pattern"/> to store in the registry.</param>
    /// <param name="cancellationToken">A <see cref="CancellationToken"/> to cancel the operation.</param>
    /// <returns>A <see cref="PatternDescriptor"/> that describes the pushed pattern, or null if the push failed.</returns>
    Task<PatternDescriptor?> PushAsync(PatternDescriptor descriptor, Pattern pattern, CancellationToken cancellationToken = default);

    /// <summary>
    /// Pull a pattern from the registry by its descriptor.
    /// </summary>
    /// <param name="descriptor">A <see cref="PatternDescriptor"/> that describes the pattern.</param>
    /// <param name="cancellationToken">A <see cref="CancellationToken"/> to cancel the operation.</param>
    /// <returns>A <see cref="Pattern"/> that represents the pulled pattern, or null if the pull failed.</returns>
    Task<Pattern?> PullAsync(PatternDescriptor descriptor, CancellationToken cancellationToken = default);
}
