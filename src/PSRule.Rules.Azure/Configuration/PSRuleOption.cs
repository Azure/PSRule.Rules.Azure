// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Management.Automation;

namespace PSRule.Rules.Azure.Configuration
{
    /// <summary>
    /// A delgate to allow callback to PowerShell to get current working path.
    /// </summary>
    internal delegate string PathDelegate();

    public sealed class PSRuleOption
    {
        /// <summary>
        /// A callback that is overridden by PowerShell so that the current working path can be retrieved.
        /// </summary>
        private static PathDelegate _GetWorkingPath = () => Directory.GetCurrentDirectory();

        /// <summary>
        /// Set working path from PowerShell host environment.
        /// </summary>
        /// <param name="executionContext">An $ExecutionContext object.</param>
        /// <remarks>
        /// Called from PowerShell.
        /// </remarks>
        public static void UseExecutionContext(EngineIntrinsics executionContext)
        {
            if (executionContext == null)
            {
                _GetWorkingPath = () => Directory.GetCurrentDirectory();

                return;
            }

            _GetWorkingPath = () => executionContext.SessionState.Path.CurrentFileSystemLocation.Path;
        }

        public static string GetWorkingPath()
        {
            return _GetWorkingPath();
        }

        /// <summary>
        /// Get a full path instead of a relative path that may be passed from PowerShell.
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        internal static string GetRootedPath(string path)
        {
            return Path.IsPathRooted(path) ? path : Path.GetFullPath(Path.Combine(GetWorkingPath(), path));
        }

    }
}
