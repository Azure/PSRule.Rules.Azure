// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using PSRule.Rules.Azure.Patterns.Remotes;
using PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

namespace PSRule.Rules.Azure.Patterns;

internal sealed class WorkspacePatternRegistry(Microsoft.Extensions.Logging.ILogger logger, string storePath, IImmutableDictionary<string, IPatternRegistryRemote> remotes) : IPatternRegistry
{
    private readonly string _StorePath = storePath;
    private readonly IImmutableDictionary<string, IPatternRegistryRemote> _Remotes = remotes;

    public async Task<IEnumerable<PatternDescriptor>> FetchAsync(string? prefix, CancellationToken cancellationToken = default)
    {
        if (!_Remotes.TryGetValue(typeof(ContainerRegistryPatternRemote).Name, out var remote))
            return [];

        return await remote.FetchAsync(prefix, cancellationToken);
    }

    public async Task<Pattern?> PullAsync(PatternDescriptor descriptor, CancellationToken cancellationToken = default)
    {
        if (!_Remotes.TryGetValue(typeof(ContainerRegistryPatternRemote).Name, out var remote))
            return default;

        return await remote.PullAsync(descriptor, cancellationToken);
    }

    public async Task<PatternDescriptor?> PushAsync(PatternDescriptor descriptor, Pattern pattern, CancellationToken cancellationToken = default)
    {
        if (!_Remotes.TryGetValue(typeof(ContainerRegistryPatternRemote).Name, out var remote))
            return default;

        return await remote.PushAsync(descriptor, pattern, cancellationToken);
    }

    public async Task<IEnumerable<PatternInfo>> ListAsync(CancellationToken cancellationToken = default)
    {
        if (!Directory.Exists(_StorePath)) return [];

        var patternFiles = Directory.GetFiles(_StorePath, "*.md");
        var patternInfos = new List<PatternInfo>();

        foreach (var file in patternFiles)
        {
            var pattern = LoadPatternFromFile(file);
            if (pattern != null)
            {
                patternInfos.Add(new PatternInfo
                {
                    Name = pattern.Name,
                    Description = pattern.Description
                });
            }
        }

        return patternInfos;
    }

    public async Task<Pattern?> GetAsync(string patternName, CancellationToken cancellationToken = default)
    {
        var pattern = LoadPatternFromFile(Path.Combine(_StorePath, $"{patternName}.md"));
        return pattern;
    }

    /// <summary>
    /// Add a pattern from the registry to the workspace.
    /// </summary>
    public async Task AddAsync(string name, string version, CancellationToken cancellationToken = default)
    {
        if (!_Remotes.TryGetValue(typeof(ContainerRegistryPatternRemote).Name, out var remote))
            return;

        // Create a descriptor for the target in the registry.
        var descriptor = new PatternDescriptor(name, version);

        var pattern = await remote.PullAsync(descriptor, cancellationToken);
        if (pattern == null)
        {
            throw new InvalidOperationException($"Pattern '{name}' version '{version}' not found in the registry.");
        }

        // Write the pattern to the workspace cache.
        var filePath = Path.Combine(_StorePath, $"{pattern.Name}.md");
        EnsurePath(filePath);

        File.WriteAllText(filePath, pattern.Body);
    }

    private static Pattern? LoadPatternFromFile(string filePath)
    {
        if (!File.Exists(filePath)) throw new FileNotFoundException($"Pattern file not found: {filePath}");

        var name = Path.GetFileNameWithoutExtension(filePath);
        var content = File.ReadAllText(filePath);
        var metadata = MarkdownHelpers.GetFrontmatter<PatternDocumentMetadata>(content);

        if (metadata == null)
        {
            throw new InvalidOperationException($"Pattern metadata not found in file: {filePath}");
        }

        var body = MarkdownHelpers.GetMarkdownContent(content);

        return new Pattern
        {
            Name = name,
            Description = metadata.Description,
            Body = body,
        };
    }

    private static void EnsurePath(string filePath)
    {
        var parent = Path.GetDirectoryName(filePath);
        if (parent != null && !Directory.Exists(parent))
        {
            Directory.CreateDirectory(parent);
        }
    }
}
