// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;

namespace PSRule.Rules.Azure
{
    internal static class TaskExtensions
    {
        public static void Dispose(this Task[] tasks)
        {
            for (var i = 0; tasks != null && i < tasks.Length; i++)
                tasks[i].Dispose();
        }
    }
}
