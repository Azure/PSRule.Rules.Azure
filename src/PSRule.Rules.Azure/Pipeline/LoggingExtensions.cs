// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Pipeline
{
    /// <summary>
    /// Extensions for logging to the pipeline.
    /// </summary>
    internal static class LoggingExtensions
    {
        internal static void VerboseFindFiles(this ILogger logger, string path)
        {
            logger.WriteVerbose(Diagnostics.VerboseFindFiles, path);
        }

        internal static void VerboseFoundFile(this ILogger logger, string path)
        {
            logger.WriteVerbose(Diagnostics.VerboseFoundFile, path);
        }

        internal static void VerboseMetadataNotFound(this ILogger logger, string path)
        {
            logger.WriteVerbose(Diagnostics.VerboseMetadataNotFound, path);
        }

        internal static void VerboseTemplateLinkNotFound(this ILogger logger, string path)
        {
            logger.WriteVerbose(Diagnostics.VerboseTemplateLinkNotFound, path);
        }

        internal static void VerboseTemplateFileNotFound(this ILogger logger, string path)
        {
            logger.WriteVerbose(Diagnostics.VerboseTemplateFileNotFound, path);
        }
    }
}
