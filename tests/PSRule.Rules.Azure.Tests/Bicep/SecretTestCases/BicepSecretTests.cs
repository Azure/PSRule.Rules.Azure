// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Bicep.SecretTestCases;

public sealed class BicepSecretTests : TemplateVisitorTestsBase
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2054
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenConditionalSecretParameter_ShouldReturnSecretsPlaceholders()
    {
        var option = PSRuleOption.Default;
        option.DiagnosticBehaviors |= DiagnosticBehaviors.KeepSecretProperties;
        var resources = ProcessTemplate(GetSourcePath("Bicep/SecretTestCases/Tests.Bicep.1.json"), null, out _, option);

        Assert.NotNull(resources);

        var actual = resources.Where(r => r["name"].Value<string>() == "vault1/toSet1").FirstOrDefault();
        Assert.Equal("Microsoft.KeyVault/vaults/secrets", actual["type"].Value<string>());
        Assert.Equal("{{SecretReference:supersecret1}}", actual["properties"]["value"].Value<string>());

        actual = resources.Where(r => r["name"].Value<string>() == "vault1/toSet2").FirstOrDefault();
        Assert.Equal("Microsoft.KeyVault/vaults/secrets", actual["type"].Value<string>());
        Assert.Equal("placeholder", actual["properties"]["value"].Value<string>());
    }

    [Fact]
    public void ProcessTemplate_WhenSecretValue_PropertyShouldBeTrackedAndReplaced()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/SecretTestCases/Tests.Bicep.2.json"), null, out _);

        Assert.NotNull(resources);

        var actual = resources.Where(r => r["name"].Value<string>() == "store/testInsecure").FirstOrDefault();
        Assert.Equal("Microsoft.AppConfiguration/configurationStores/keyValues", actual["type"].Value<string>());
        Assert.Equal("{{Secret}}", actual["properties"]["value"].Value<string>());
    }
}
