// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure
{
    public sealed class CidrParsingTests
    {
        [Fact]
        public void IPv4()
        {
            Assert.True(CidrParsing.TryParse("10.0.0.0/8", out var actual));
            Assert.Equal(8, actual.Cidr);
            Assert.Equal("10.0.0.0", actual.Network);
            Assert.Equal("10.0.0.1", actual.FirstUsable);
            Assert.Equal("10.255.255.254", actual.LastUsable);
            Assert.Equal("10.255.255.255", actual.Broadcast);
            Assert.Equal("255.0.0.0", actual.Netmask);

            Assert.True(CidrParsing.TryParse("192.168.0.0/16", out actual));
            Assert.Equal(16, actual.Cidr);
            Assert.Equal("192.168.0.0", actual.Network);
            Assert.Equal("192.168.0.1", actual.FirstUsable);
            Assert.Equal("192.168.255.254", actual.LastUsable);
            Assert.Equal("192.168.255.255", actual.Broadcast);
            Assert.Equal("255.255.0.0", actual.Netmask);

            Assert.True(CidrParsing.TryParse("10.144.0.0/20", out actual));
            Assert.Equal(20, actual.Cidr);
            Assert.Equal("10.144.0.0", actual.Network);
            Assert.Equal("10.144.0.1", actual.FirstUsable);
            Assert.Equal("10.144.15.255", actual.Broadcast);
            Assert.Equal("10.144.15.254", actual.LastUsable);
            Assert.Equal("255.255.240.0", actual.Netmask);
        }

        [Fact]
        public void IPv6()
        {
            Assert.True(CidrParsing.TryParse("fdad:3236:5555::/48", out var actual));
            Assert.Equal(48, actual.Cidr);
            Assert.Equal("fdad:3236:5555::", actual.Network);
            Assert.Equal("fdad:3236:5555::", actual.FirstUsable);
            Assert.Equal("fdad:3236:5555:ffff:ffff:ffff:ffff:ffff", actual.LastUsable);
            Assert.Null(actual.Broadcast);
            Assert.Equal("ffff:ffff:ffff::", actual.Netmask);

            Assert.True(CidrParsing.TryParse("3FFE:FFFF:0:CD30:0:0:0:0/64", out actual));
            Assert.Equal(64, actual.Cidr);
            Assert.Equal("3ffe:ffff:0:cd30::", actual.Network);
            Assert.Equal("3ffe:ffff:0:cd30::", actual.FirstUsable);
            Assert.Equal("3ffe:ffff::cd30:ffff:ffff:ffff:ffff", actual.LastUsable);
            Assert.Null(actual.Broadcast);
            Assert.Equal("ffff:ffff:ffff:ffff::", actual.Netmask);

            Assert.True(CidrParsing.TryParse("3FFE:FFFF:0:CD30::/64", out actual));
            Assert.Equal(64, actual.Cidr);
            Assert.Equal("3ffe:ffff:0:cd30::", actual.Network);
            Assert.Equal("3ffe:ffff:0:cd30::", actual.FirstUsable);
            Assert.Equal("3ffe:ffff::cd30:ffff:ffff:ffff:ffff", actual.LastUsable);
            Assert.Null(actual.Broadcast);
            Assert.Equal("ffff:ffff:ffff:ffff::", actual.Netmask);
        }
    }
}
