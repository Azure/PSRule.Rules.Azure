// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// An interface for a validation context.
/// </summary>
internal interface IValidationContext
{
    /// <summary>
    /// Track a validation issue.
    /// </summary>
    void AddValidationIssue(string issueId, string name, string path, string message, params object[] args);

    /// <summary>
    /// Lookup a resource type.
    /// </summary>
    ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType);

    /// <summary>
    /// Determines if the value is a previously identified secure value.
    /// </summary>
    bool IsSecureValue(object value);
}
