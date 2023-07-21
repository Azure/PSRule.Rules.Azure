// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Text;
using System.Threading;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

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

    internal static class CidrParsing
    {
        // Parsing and formatting constants
        private const char SLASH = '/';
        private const char COLON = ':';
        private const char DOT = '.';
        private const char ZERO = '0';
        private const string COLON_STRING = ":";

        // Format strings
        private const string FORMAT_HEX = "x";
        private const string FORMAT_2HEX = "x2";

        internal struct CidrIP
        {
            public CidrIP(byte[] value)
            {
                Value = FormatIPAddress(value);
                Bytes = value;
                Lo = 0;
                Hi = 0;

                // IPv4
                if (value.Length == 4)
                {
                    for (var i = 0; i < 4; i++)
                    {
                        Lo |= (ulong)value[i] << (8 * i);
                    }
                }
                // IPv6
                else
                {
                    for (var i = 0; i < 8; i++)
                    {
                        Hi |= (ulong)value[i] << (8 * i);
                        Lo |= (ulong)value[i + 8] << (8 * i);
                    }
                }
            }

            public byte[] Bytes { get; }

            public string Value { get; }

            public ulong Hi { get; }
            public ulong Lo { get; }
        }

        internal sealed class CidrInfo : ICidrInfo
        {
            [JsonIgnore]
            public int Version { get; internal set; }

            [JsonIgnore]
            public CidrIP Network { get; internal set; }

            [JsonIgnore]
            public CidrIP Netmask { get; internal set; }

            [JsonIgnore]
            public CidrIP Broadcast { get; internal set; }

            [JsonIgnore]
            public CidrIP FirstUsable { get; internal set; }

            [JsonIgnore]
            public CidrIP LastUsable { get; internal set; }

            [JsonProperty("cidr", Order = 1)]
            public int Cidr { get; internal set; }

            [JsonProperty("broadcast", Order = 0, NullValueHandling = NullValueHandling.Ignore)]
            string ICidrInfo.Broadcast => Version == 4 ? Broadcast.Value : null;

            [JsonProperty("firstUsable", Order = 2)]
            string ICidrInfo.FirstUsable => FirstUsable.Value;

            [JsonProperty("lastUsable", Order = 3)]
            string ICidrInfo.LastUsable => LastUsable.Value;

            [JsonProperty("netmask", Order = 4)]
            string ICidrInfo.Netmask => Netmask.Value;

            [JsonProperty("network", Order = 5)]
            string ICidrInfo.Network => Network.Value;
        }

        public static bool TryParse(string value, out ICidrInfo info)
        {
            var cidrParts = value.Split(SLASH);
            var addressBytes = GetAddressBytes(cidrParts[0]);
            var length = int.Parse(cidrParts[1]);
            return TryGetInfo(addressBytes, length, 0, 0, out info);
        }

        public static bool TryGetSubnet(string value, int prefixLength, int subnetOffset, out string subnet)
        {
            if (prefixLength < 0 || prefixLength > 128)
                throw new ExpressionArgumentException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidCIDRLength, prefixLength, value));

            subnet = null;
            var cidrParts = value.Split(SLASH);
            var addressBytes = GetAddressBytes(cidrParts[0]);
            if (!TryGetInfo(addressBytes, prefixLength, subnetOffset, 0, out var info))
                return false;

            if (prefixLength < info.Cidr)
                throw new ExpressionArgumentException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ArgumentInvalidCIDRLength, prefixLength, value));

            subnet = string.Concat(info.Network, SLASH, prefixLength);
            return true;
        }

        public static bool TryGetHost(string value, int hostOffset, out string host)
        {
            host = null;
            var cidrParts = value.Split(SLASH);
            var addressBytes = GetAddressBytes(cidrParts[0]);
            var length = int.Parse(cidrParts[1]);
            if (!TryGetInfo(addressBytes, length, 0, addressBytes.Length == 4 ? hostOffset : hostOffset + 1, out var info))
                return false;

            host = info.FirstUsable;
            return true;
        }

        private static bool TryGetInfo(byte[] address, int prefixLength, int subnetOffset, int hostOffset, out ICidrInfo info)
        {
            var numBytes = address.Length;
            var offset = (byte)(numBytes == 4 && prefixLength < 32 ? 1 : 0);

            // Fill in the mask
            var netmask = new byte[numBytes];
            for (var i = 0; i < prefixLength; i++)
            {
                netmask[i / 8] |= (byte)(1 << (7 - (i % 8)));
            }

            // Mask the address to get the address
            var network = new byte[numBytes];
            for (var i = 0; i < numBytes; i++)
            {
                network[i] = (byte)(address[i] & netmask[i]);
            }

            // Calculate the network based on the netmask and offset by subnetOffset
            var networkAddress = new byte[numBytes];
            var carry = subnetOffset << (8 - (prefixLength % 8));
            for (var i = numBytes - (numBytes - prefixLength / 8); i >= 0; i--)
            {
                if (i == numBytes)
                    i--;

                networkAddress[i] = (byte)((address[i] & network[i]) + carry);
                carry = (byte)(((address[i] & network[i]) + carry) >> 8);
            }

            // Calculate the first address based on netmask
            var firstAddress = new byte[numBytes];
            for (var i = 0; i < numBytes; i++)
            {
                firstAddress[i] = (byte)(network[i] + ((i == numBytes - 1) ? (offset + hostOffset) : 0));
            }

            // Calculate the broadcast
            var broadcastAddress = new byte[numBytes];
            for (var i = 0; i < numBytes; i++)
            {
                broadcastAddress[i] = (byte)(networkAddress[i] + ((i >= prefixLength / 8) ? 255 - netmask[i] : 0));
            }

            // Calculate the last usable address based on broadcast
            var lastUsableAddress = new byte[numBytes];
            for (var i = 0; i < numBytes; i++)
            {
                lastUsableAddress[i] = (byte)(broadcastAddress[i] - ((i == numBytes - 1) ? offset : 0));
            }

            info = new CidrInfo
            {
                Version = numBytes == 4 ? 4 : 6,
                Network = new CidrIP(networkAddress),
                Netmask = new CidrIP(netmask),
                Broadcast = new CidrIP(broadcastAddress),
                FirstUsable = new CidrIP(firstAddress),
                LastUsable = new CidrIP(lastUsableAddress),
                Cidr = prefixLength,
            };
            return true;
        }

        static byte[] GetAddressBytes(string value)
        {
            if (value.Contains(COLON_STRING))
            {
                // IPv6
                var ip = new byte[16];
                var index = 0;
                var currentByte = 0;
                var currentByteIndex = 0;
                var doubleColonIndex = -1;
                for (var i = 0; i < value.Length; i++)
                {
                    if (value[i] == COLON)
                    {
                        if (i == 0 || value[i - 1] == COLON)
                        {
                            doubleColonIndex = index;
                        }
                        else
                        {
                            ip[currentByteIndex++] = (byte)(currentByte >> 8);
                            ip[currentByteIndex++] = (byte)(currentByte & 0xFF);
                            currentByte = 0;
                        }
                    }
                    else
                    {
                        currentByte = (currentByte << 4) + ParseHexDigit(value[i]);
                    }
                    index++;
                }
                if (currentByteIndex < 16)
                {
                    ip[currentByteIndex++] = (byte)(currentByte >> 8);
                    ip[currentByteIndex++] = (byte)(currentByte & 0xFF);
                }
                if (doubleColonIndex != -1)
                {
                    var numMissingBytes = 16 - currentByteIndex;
                    for (var i = currentByteIndex - 1; i >= doubleColonIndex; i--)
                    {
                        ip[i + numMissingBytes] = ip[i];
                        ip[i] = 0;
                    }
                }
                return ip;
            }
            else
            {
                // IPv4
                var ip = new byte[4];
                var parts = value.Split(DOT);
                for (var i = 0; i < 4; i++)
                {
                    ip[i] = byte.Parse(parts[i]);
                }
                return ip;
            }
        }

        static int ParseHexDigit(char c)
        {
            if (c >= ZERO && c <= '9')
            {
                return c - ZERO;
            }
            else if (c >= 'a' && c <= 'f')
            {
                return c - 'a' + 10;
            }
            else if (c >= 'A' && c <= 'F')
            {
                return c - 'A' + 10;
            }
            throw new ArgumentException($"Invalid hex digit: {c}");
        }

        static string FormatIPAddress(byte[] ip)
        {
            if (ip.Length == 4)
            {
                // IPv4
                return $"{ip[0]}.{ip[1]}.{ip[2]}.{ip[3]}";
            }

            // IPv6

            // Find the longest sequence of consecutive zero bytes
            var longestZeroStart = -1;
            var longestZeroLength = 0;
            var currentZeroStart = -1;
            var currentZeroLength = 0;
            for (var i = 0; i < ip.Length; i += 2)
            {
                if (ip[i] == 0 && ip[i + 1] == 0)
                {
                    if (currentZeroStart == -1)
                    {
                        currentZeroStart = i;
                    }
                    currentZeroLength += 2;
                }
                else
                {
                    if (currentZeroLength > longestZeroLength)
                    {
                        longestZeroStart = currentZeroStart;
                        longestZeroLength = currentZeroLength;
                    }
                    currentZeroStart = -1;
                    currentZeroLength = 0;
                }
            }
            if (currentZeroLength > longestZeroLength)
            {
                longestZeroStart = currentZeroStart;
                longestZeroLength = currentZeroLength;
            }

            // Build the compressed IPv6 address string
            var sb = new StringBuilder(ip.Length);
            for (var i = 0; i < ip.Length; i += 2)
            {
                if (i == longestZeroStart)
                {
                    sb.Append(COLON);
                    i += longestZeroLength - 2;
                }
                else
                {
                    if (ip[i] == 0 && ip[i + 1] == 0)
                    {
                        sb.Append(ZERO);
                    }
                    else if (ip[i] == 0)
                    {
                        sb.Append(ip[i + 1].ToString(FORMAT_HEX));
                    }
                    else
                    {
                        sb.Append(ip[i].ToString(FORMAT_HEX));
                        sb.Append(ip[i + 1].ToString(FORMAT_2HEX));
                    }

                    if (i < ip.Length - 2)
                        sb.Append(COLON);
                }
            }
            return sb.ToString();
        }
    }
}
