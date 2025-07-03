// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Net;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure;

internal sealed class TestResourceExportContext : ResourceExpandContext
{
    private const string TENANT_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff";

    public TestResourceExportContext()
        : base(null, null, new AccessTokenCache(GetAccessToken), retryCount: 3, retryInterval: 10, tenantId: TENANT_ID, securityAlerts: false)
    {
        RefreshToken(TENANT_ID);
    }

    private static AccessToken GetAccessToken(string tenantId)
    {
        return new AccessToken(new NetworkCredential("na", "$CREDENTIAL_PLACEHOLDER$").SecurePassword, DateTime.UtcNow.AddMinutes(15), tenantId);
    }
}
