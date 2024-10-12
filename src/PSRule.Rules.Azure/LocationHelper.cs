// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure;

internal sealed class LocationHelper : IEqualityComparer<string>
{
    public static readonly IEqualityComparer<string> Comparer = new LocationHelper();

    /// <summary>
    /// Determines of two Azure locations are equals regardless of spacing or case.
    /// </summary>
    public static bool Equal(string location1, string location2)
    {
        if (string.IsNullOrEmpty(location1) && string.IsNullOrEmpty(location2))
            return true;

        if (string.IsNullOrEmpty(location1) || string.IsNullOrEmpty(location2))
            return false;

        var i = 0;
        var j = 0;
        while (i < location1.Length && j < location2.Length)
        {
            if (char.IsWhiteSpace(location1[i]))
                i++;

            if (char.IsWhiteSpace(location2[j]))
                j++;

            if (i == location1.Length && j == location2.Length)
                return true;

            if (i == location1.Length || j == location2.Length)
                return false;

            if (char.ToLowerInvariant(location1[i++]) != char.ToLowerInvariant(location2[j++]))
                return false;
        }

        if (i < location1.Length && char.IsWhiteSpace(location1[i]))
            i++;

        if (j < location2.Length && char.IsWhiteSpace(location2[j]))
            j++;

        return i == location1.Length && j == location2.Length;
    }

    public static string Normalize(string location)
    {
        if (string.IsNullOrEmpty(location))
            return string.Empty;

        var i = 0;
        var j = 0;
        var buffer = new char[location.Length];
        while (i < location.Length && j < buffer.Length)
        {
            if (!char.IsWhiteSpace(location[i]))
                buffer[j++] = char.IsUpper(location[i]) ? char.ToLowerInvariant(location[i]) : location[i];

            i++;
        }
        return new string(buffer, 0, j);
    }

    #region IEqualityComparer<string>

    public bool Equals(string x, string y)
    {
        return Equal(x, y);
    }

    public int GetHashCode(string obj)
    {
        return Normalize(obj).GetHashCode();
    }

    #endregion IEqualityComparer<string>
}
