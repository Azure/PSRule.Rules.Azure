// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;

namespace PSRule.Rules.Azure;

/// <summary>
/// Helpers for <see cref="Task"/> instances.
/// </summary>
internal static class TaskExtensions
{
    /// <summary>
    /// Call the <c>Dispose</c> method all the specified tasks.
    /// </summary>
    public static void DisposeAll(this Task[] tasks)
    {
        for (var i = 0; tasks != null && i < tasks.Length; i++)
            tasks[i].Dispose();
    }
}
