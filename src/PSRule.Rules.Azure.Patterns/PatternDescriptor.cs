// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

public sealed class PatternDescriptor
{
    public PatternDescriptor() { }

    public PatternDescriptor(string name, string version)
    {
        Name = name;
        Version = version;
    }

    public string? Digest { get; set; }
    public string? Version { get; set; }

    public string Name { get; set; }
}
