// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Net;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure;

internal sealed class TestResourceExportContext : ResourceExportContext
{
    public TestResourceExportContext()
        : base(null, null, new AccessTokenCache(GetAccessToken), retryCount: 3, retryInterval: 10, securityAlerts: false)
    {
        RefreshToken("ffffffff-ffff-ffff-ffff-ffffffffffff");
    }

    private static AccessToken GetAccessToken(string tenantId)
    {
        return new AccessToken(new NetworkCredential("na", "$CREDENTIAL_PLACEHOLDER$").SecurePassword, DateTime.UtcNow.AddMinutes(15), tenantId);
    }
}
