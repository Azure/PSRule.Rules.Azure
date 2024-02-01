// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using PSRule.Rules.Azure.Data.Policy;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class PolicyBaselineConverterTests
    {
        [Fact]
        public void WriteJson()
        {
            var baseline = new PolicyBaseline("Baseline1", "Generated automatically when exporting Azure Policy rules.", new string[] { "Policy1" }, new string[] { "Rule1" });
            var json = JsonConvert.SerializeObject(baseline);
            Assert.Equal(@"{/*Synopsis: Generated automatically when exporting Azure Policy rules.*/""apiVersion"":""github.com/microsoft/PSRule/v1"",""kind"":""Baseline"",""metadata"":{""name"":""Baseline1""},""spec"":{""rule"":{""include"":[""Policy1"",""Rule1""]}}}", json);
        }
    }
}
