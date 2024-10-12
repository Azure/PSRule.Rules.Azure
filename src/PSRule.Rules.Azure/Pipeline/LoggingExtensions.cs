// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using System.Net;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// Extensions for logging to the pipeline.
/// </summary>
internal static class LoggingExtensions
{
    internal static void VerboseFindFiles(this ILogger logger, string path)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseFindFiles, path);
    }

    internal static void VerboseFoundFile(this ILogger logger, string path)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseFoundFile, path);
    }

    internal static void VerboseMetadataNotFound(this ILogger logger, string path)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseMetadataNotFound, path);
    }

    internal static void VerboseTemplateLinkNotFound(this ILogger logger, string path)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseTemplateLinkNotFound, path);
    }

    internal static void VerboseTemplateFileNotFound(this ILogger logger, string path)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseTemplateFileNotFound, path);
    }

    /// <summary>
    /// Getting resources from subscription: {0}
    /// </summary>
    internal static void VerboseGetResources(this ILogger logger, string subscriptionId)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseGetResources, subscriptionId);
    }

    /// <summary>
    /// Added {0} resources from subscription '{1}'.
    /// </summary>
    internal static void VerboseGetResourcesResult(this ILogger logger, int count, string subscriptionId)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseGetResourcesResult, count, subscriptionId);
    }

    /// <summary>
    /// Getting resource: {0}
    /// </summary>
    internal static void VerboseGetResource(this ILogger logger, string resourceId)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseGetResource, resourceId);
    }

    /// <summary>
    /// Expanding resource: {0}
    /// </summary>
    internal static void VerboseExpandingResource(this ILogger logger, string resourceId)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseExpandingResource, resourceId);
    }

    /// <summary>
    /// Retrying '{0}' in {1}, attept {2}.
    /// </summary>
    internal static void VerboseRetryIn(this ILogger logger, string uri, TimeSpan retry, int attempt)
    {
        if (logger == null)
            return;

        logger.WriteVerbose(Diagnostics.VerboseRetryIn, uri, retry, attempt);
    }

    /// <summary>
    /// Failed to get '{0}': status={1}, correlation-id={2}, {3}
    /// </summary>
    internal static void WarnFailedToGet(this ILogger logger, string uri, HttpStatusCode statusCode, string correlationId, string body)
    {
        if (logger == null)
            return;

        logger.WriteWarning(Diagnostics.WarnFailedToGet, uri, (int)statusCode, correlationId, body);
    }

    internal static void Error(this ILogger logger, Exception exception, string errorId, ErrorCategory errorCategory = ErrorCategory.NotSpecified, object targetObject = null)
    {
        if (logger == null)
            return;

        logger.WriteError(exception, errorId, errorCategory, targetObject);
    }
}
