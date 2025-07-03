// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// An interface to generate output file paths for data pipelines.
/// </summary>
internal interface IOutputPathGenerator
{
    /// <summary>
    /// Generate a file path for an output written to disk.
    /// </summary>
    /// <param name="outputPath">The base output path where the file will be written.</param>
    /// <param name="key">A unique key to identify the output file.</param>
    /// <returns>A string representing the output file name.</returns>
    string GenerateOutputPath(string outputPath, string key);
}
