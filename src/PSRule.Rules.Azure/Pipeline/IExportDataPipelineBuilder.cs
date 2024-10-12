// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A builder to configure the pipeline to export data.
/// </summary>
public interface IExportDataPipelineBuilder : IPipelineBuilder
{
    /// <summary>
    /// Configures a method to request an Access Token.
    /// </summary>
    void AccessToken(GetAccessTokenFn fn);
}
