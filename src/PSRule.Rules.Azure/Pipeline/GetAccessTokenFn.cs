// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A delegate that returns an Access Token.
/// </summary>
public delegate AccessToken GetAccessTokenFn(string tenantId);
