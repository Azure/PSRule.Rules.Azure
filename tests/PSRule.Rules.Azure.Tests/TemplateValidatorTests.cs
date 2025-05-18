// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Deployments;
using PSRule.Rules.Azure.Data;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure;

public sealed class TemplateValidatorTests
{
    [Fact]
    public void SecureParameter()
    {
        var context = GetContext();
        var o1 = new JObject();
        var validator = new TemplateValidator();
        validator.ValidateParameter(context, ParameterType.String, "param1", o1, "value123");
        validator.ValidateParameter(context, ParameterType.String, "param2", o1, "{{SecretReference 123}}");
        validator.ValidateParameter(context, ParameterType.SecureString, "param3", o1, "{{SecretReference 123}}");
        validator.ValidateParameter(context, ParameterType.SecureString, "param4", o1, "value123");

        var issues = context.Value["_PSRule"]["issue"].Value<JArray>();
        Assert.NotNull(issues);
        Assert.Equal(2, issues.Count);

        var actual = issues[0];
        Assert.Equal("PSRule.Rules.Azure.Template.ParameterSecureAssignment", actual["type"]);
        Assert.Equal("param2", actual["name"]);

        actual = issues[1];
        Assert.Equal("PSRule.Rules.Azure.Template.ParameterUnsecureValue", actual["type"]);
        Assert.Equal("param4", actual["name"]);
    }

    [Fact]
    public void OutputSecret()
    {
        var context = GetContext();
        var o1 = new JObject();
        var validator = new TemplateValidator();
        validator.ValidateOutput(context, ParameterType.String, "output1", o1, "{{SecretReference 123}}");
        validator.ValidateOutput(context, ParameterType.SecureString, "output2", o1, "{{SecretReference 123}}");

        var issues = context.Value["_PSRule"]["issue"].Value<JArray>();
        Assert.NotNull(issues);
        Assert.Single(issues);

        var actual = issues[0];
        Assert.Equal("PSRule.Rules.Azure.Template.OutputSecretValue", actual["type"]);
        Assert.Equal("output1", actual["name"]);
    }

    #region Helper methods

    private static TestValidationContext GetContext()
    {
        return new TestValidationContext();
    }

    #endregion Helper methods

    #region TestValidationContext

    internal sealed class TestValidationContext : IValidationContext
    {
        public TestValidationContext()
        {
            Value = new JObject();
        }

        public JObject Value { get; }

        public void AddValidationIssue(string issueId, string name, string path, string message, params object[] args)
        {
            Value.SetValidationIssue(issueId, name, path, message, args);
        }

        public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
        {
            throw new NotImplementedException();
        }

        public bool IsSecureValue(object value)
        {
            return false;
        }
    }

    #endregion TestValidationContext
}
