// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Bicep.UserDefinedFunctionTestCases;

public sealed class BicepUserDefinedFunctionTests : TemplateVisitorTestsBase
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3120
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenUserDefinedFunctionReferencesExportedVariables_ShouldFindVariable()
    {
        _ = ProcessTemplate(GetSourcePath("Bicep/UserDefinedFunctionTestCases/Tests.Bicep.1.json"), null, out var templateContext);

        Assert.True(templateContext.RootDeployment.TryOutput("o1", out JObject o1));
        Assert.Equal([2], o1["value"].Values<int>());

        Assert.True(templateContext.RootDeployment.TryOutput("o2", out JObject o2));
        Assert.Equal([1], o2["value"].Values<int>());

        Assert.True(templateContext.RootDeployment.TryOutput("o3", out JObject o3));
        Assert.Equal([1], o3["value"].Values<int>());

        Assert.True(templateContext.RootDeployment.TryOutput("o4", out JObject o4));
        Assert.Equal([2, 1], o4["value"].Values<int>());

        Assert.True(templateContext.RootDeployment.TryOutput("o5", out JObject o5));
        Assert.Equal([3], o5["value"].Values<int>());
    }
}
