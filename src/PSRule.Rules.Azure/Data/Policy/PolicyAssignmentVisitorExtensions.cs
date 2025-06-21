// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Policy;

/// <summary>
/// Extension methods for working with <see cref="PolicyAssignmentVisitor"/>.
/// </summary>
internal static class PolicyAssignmentVisitorExtensions
{
    private const string PROPERTY_ALLOF = "allOf";
    private const string PROPERTY_ANYOF = "anyOf";

    /// <summary>
    /// Try to read the <c>allOf</c> property.
    /// </summary>
    internal static bool TryAllOf(this JObject obj, out JArray allOf)
    {
        return obj.TryArrayProperty(PROPERTY_ALLOF, out allOf);
    }

    /// <summary>
    /// Try to read the <c>anyOf</c> property.
    /// </summary>
    internal static bool TryAnyOf(this JObject obj, out JArray anyOf)
    {
        return obj.TryArrayProperty(PROPERTY_ANYOF, out anyOf);
    }

    /// <summary>
    /// Merge two <c>allOf</c> objects into a consolidated object to optimize condition evaluation.
    /// </summary>
    internal static void MergeAllOf(this JArray allOf, JObject other, bool insertBefore = false)
    {
        if (!other.TryAllOf(out var otherAllOf))
        {
            if (insertBefore)
            {
                allOf.Insert(0, other);
            }
            else
            {
                allOf.Add(other);
            }

            return;
        }

        var toAdd = otherAllOf.OfType<JObject>();
        if (insertBefore)
        {
            toAdd = toAdd.Reverse();
        }

        foreach (var item in toAdd)
        {
            if (insertBefore)
            {
                allOf.Insert(0, item);
            }
            else
            {
                allOf.Add(item);
            }
        }
    }

    /// <summary>
    /// Merge two <c>anyOf</c> objects into a consolidated object to optimize condition evaluation.
    /// </summary>
    internal static void MergeAnyOf(this JArray anyOf, JObject other, bool insertBefore = false)
    {
        if (!other.TryAnyOf(out var otherAnyOf))
        {
            if (insertBefore)
            {
                anyOf.Insert(0, other);
            }
            else
            {
                anyOf.Add(other);
            }

            return;
        }

        var toAdd = otherAnyOf.OfType<JObject>();
        if (insertBefore)
        {
            toAdd = toAdd.Reverse();
        }

        foreach (var item in toAdd)
        {
            if (insertBefore)
            {
                anyOf.Insert(0, item);
            }
            else
            {
                anyOf.Add(item);
            }
        }
    }
}
