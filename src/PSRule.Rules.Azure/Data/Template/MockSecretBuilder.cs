// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using static PSRule.Rules.Azure.Data.Template.Mock;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A helper class that builds a mock secret.
    /// </summary>
    internal sealed class MockSecretBuilder
    {
        private readonly SecretTemplateData _Data;

        public MockSecretBuilder()
        {
            _Data = new SecretTemplateData();
        }

        /// <summary>
        /// Return a mock for a resource type secret.
        /// </summary>
        /// <param name="resourceId">The identifier for the resource.</param>
        /// <param name="symbolName">The name of the symbol that was used for the call. e.g. <c>listKeys</c>.</param>
        /// <returns>A mock.</returns>
        public IMock Build(string resourceId, string symbolName)
        {
            return ResourceHelper.TryResourceIdComponents(resourceId, out _, out _, out string resourceType, out _) &&
                _Data.TryGetValue(resourceType, symbolName, out var value)
                ? new MockObject(value, secret: true)
                : new MockSecret(resourceId);
        }
    }
}
