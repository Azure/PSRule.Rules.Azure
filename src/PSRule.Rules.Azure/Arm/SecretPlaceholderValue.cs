// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Arm;

/// <summary>
/// A placeholder value used to represent a secret.
/// </summary>
/// <remarks>
/// Initializes a new instance of the <see cref="SecretPlaceholderValue"/> class.
/// </remarks>
/// <param name="value">A placeholder value of the secret.</param>
public sealed class SecretPlaceholderValue(string value) : JValue(value), ISecretPlaceholder
{
}
