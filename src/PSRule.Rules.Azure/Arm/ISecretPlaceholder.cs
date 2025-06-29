// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm;

internal interface ISecretPlaceholder
{
    string Path { get; }
}
