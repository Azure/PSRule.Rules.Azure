// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.IO.Compression;
using System.Threading;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data
{
    /// <summary>
    /// A base class for a helper that loads resources from the assembly.
    /// </summary>
    public abstract class ResourceLoader
    {
        /// <summary>
        /// Create an instance of the resource loader.
        /// </summary>
        protected internal ResourceLoader() { }

        /// <summary>
        /// Get the content of a resource stream by name.
        /// </summary>
        /// <param name="name">The name of the resource stream.</param>
        /// <returns>The string content of the resource stream.</returns>
        /// <exception cref="ArgumentNullException">Returns if the name of the resource stream is null or empty.</exception>
        /// <exception cref="ArgumentException">Returned when the specified name does not exist as a resource stream.</exception>
        protected static string GetContent(string name)
        {
            if (string.IsNullOrEmpty(name))
                throw new ArgumentNullException(nameof(name));

            var fileStream = typeof(ResourceLoader).Assembly.GetManifestResourceStream(name);
            if (fileStream is null)
                throw new ArgumentException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ManifestResourceNotFound, name), nameof(name));

            using (fileStream)
            using (var decompressStream = new DeflateStream(fileStream, CompressionMode.Decompress))
            using (var streamReader = new StreamReader(decompressStream))
                return streamReader.ReadToEnd();
        }
    }
}
