// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// Defines information for a CIDR.
    /// </summary>
    /// <remarks>
    /// See <seealso href="https://learn.microsoft.com/dotnet/fundamentals/networking/ipv6-overview"/>.
    /// </remarks>
    internal interface ICidrInfo
    {
        public string Broadcast { get; }
        public int Cidr { get; }
        public string FirstUsable { get; }
        public string LastUsable { get; }
        public string Netmask { get; }
        public string Network { get; }
    }
}
