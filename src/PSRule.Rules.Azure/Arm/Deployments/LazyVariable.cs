// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal abstract partial class DeploymentVisitor
{
    private sealed class LazyVariable : ILazyValue
    {
        private readonly TemplateContext _Context;
        private readonly JToken _Value;

        public LazyVariable(TemplateContext context, JToken value)
        {
            _Context = context;
            _Value = value;
        }

        public object GetValue()
        {
            return ResolveVariable(_Context, _Value);
        }
    }
}
