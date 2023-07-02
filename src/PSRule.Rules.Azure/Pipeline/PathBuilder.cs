// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline
{
    /// <summary>
    /// A helper to build a list of rule sources for discovery.
    /// </summary>
    internal sealed class PathBuilder
    {
        // Path separators
        private const char Slash = '/';
        private const char BackSlash = '\\';

        private const char Dot = '.';

        private static readonly char[] PathLiteralStopCharacters = new char[] { '*', '[', '?' };
        private static readonly char[] PathSeparatorCharacters = new char[] { '\\', '/' };

        private readonly ILogger _Logger;
        private readonly List<FileInfo> _Source;
        private readonly string _BasePath;
        private readonly string _DefaultSearchPattern;
        private readonly HashSet<string> _Existing;

        internal PathBuilder(ILogger logger, string basePath, string searchPattern)
        {
            _Logger = logger;
            _Source = new List<FileInfo>();
            _BasePath = PSRuleOption.GetRootedBasePath(basePath);
            _DefaultSearchPattern = searchPattern;
            _Existing = new HashSet<string>(StringComparer.Ordinal);
        }

        public void Add(string[] path)
        {
            if (path == null || path.Length == 0)
                return;

            for (var i = 0; i < path.Length; i++)
                Add(path[i]);
        }

        public void Add(string path)
        {
            if (string.IsNullOrEmpty(path))
                return;

            FindFiles(path);
        }

        public FileInfo[] Build()
        {
            try
            {
                return _Source.ToArray();
            }
            finally
            {
                _Source.Clear();
                _Existing.Clear();
            }
        }

        private void FindFiles(string path)
        {
            _Logger.VerboseFindFiles(path);
            if (TryAddFile(path))
                return;

            var pathLiteral = GetSearchParameters(path, out var searchPattern, out var searchOption);
            if (TryAddFile(pathLiteral))
                return;

            var files = Directory.EnumerateFiles(pathLiteral, searchPattern, searchOption);
            foreach (var file in files)
                AddFile(file);
        }

        private bool TryAddFile(string path)
        {
            if (path.IndexOfAny(PathLiteralStopCharacters) > -1)
                return false;

            var rootedPath = GetRootedPath(path);
            if (!File.Exists(rootedPath))
                return false;

            AddFile(rootedPath);
            return true;
        }

        private void AddFile(string path)
        {
            // Avoid adding duplicates.
            if (_Existing.Contains(path))
                return;

            _Logger.VerboseFoundFile(path);
            _Source.Add(new FileInfo(path));
            _Existing.Add(path);
        }

        private string GetRootedPath(string path)
        {
            return Path.IsPathRooted(path) ? path : Path.GetFullPath(Path.Combine(_BasePath, path));
        }

        /// <summary>
        /// Split a search path into components based on wildcards.
        /// </summary>
        private string GetSearchParameters(string path, out string searchPattern, out SearchOption searchOption)
        {
            searchOption = SearchOption.AllDirectories;
            var pathLiteral = SplitSearchPath(TrimPath(path, out var relativeAnchor), out searchPattern);
            if (string.IsNullOrEmpty(searchPattern))
                searchPattern = _DefaultSearchPattern;

            // If a path separator is within the pattern use a resursive search
            if (relativeAnchor || !string.IsNullOrEmpty(pathLiteral))
                searchOption = SearchOption.TopDirectoryOnly;

            return GetRootedPath(pathLiteral);
        }

        private static string SplitSearchPath(string path, out string searchPattern)
        {
            // Find the index of the first expression character i.e. out/modules/**/file
            var stopIndex = path.IndexOfAny(PathLiteralStopCharacters);

            // Track back to the separator before any expression characters
            var literalSeparator = stopIndex > -1 ? path.LastIndexOfAny(PathSeparatorCharacters, stopIndex) + 1 : path.LastIndexOfAny(PathSeparatorCharacters) + 1;
            searchPattern = path.Substring(literalSeparator, path.Length - literalSeparator);
            return path.Substring(0, literalSeparator);
        }

        /// <summary>
        /// Remove leading ./ or .\ characters indicating a relative path anchor.
        /// </summary>
        /// <param name="path">The path to trim.</param>
        /// <param name="relativeAnchor">Returns true when a relative path anchor was present.</param>
        /// <returns>Return a clean path without the relative path anchor.</returns>
        private static string TrimPath(string path, out bool relativeAnchor)
        {
            relativeAnchor = false;
            if (path.Length >= 2 && path[0] == Dot && IsSeparator(path[1]))
            {
                relativeAnchor = true;
                return path.Remove(0, 2);
            }
            return path;
        }

        [DebuggerStepThrough]
        private static bool IsSeparator(char c)
        {
            return c is Slash or BackSlash;
        }
    }
}
