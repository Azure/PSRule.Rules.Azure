// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.IO.Compression;
using System.Threading;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data
{
    public abstract class ResourceLoader
    {
        internal protected ResourceLoader() { }

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
