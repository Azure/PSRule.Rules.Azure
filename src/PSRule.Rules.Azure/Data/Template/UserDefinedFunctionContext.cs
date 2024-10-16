// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

#nullable enable

/// <summary>
/// A nested context for user-defined functions.
/// </summary>
/// <param name="context">The parent <see cref="ITemplateContext"/> context.</param>
internal sealed class UserDefinedFunctionContext(ITemplateContext context) : NestedTemplateContext(context)
{
    private const string PROPERTY_NAME = "name";

    private readonly Dictionary<string, object> _Parameters = new(StringComparer.OrdinalIgnoreCase);

    public override bool TryParameter(string parameterName, out object? value)
    {
        return _Parameters.TryGetValue(parameterName, out value);
    }

    public override bool TryVariable(string variableName, out object? value)
    {
        return base.TryVariable(variableName, out value);
    }

    internal void SetParameters(JObject[] parameters, object[]? args)
    {
        if (parameters == null || parameters.Length == 0 || args == null || args.Length == 0)
            return;

        for (var i = 0; i < parameters.Length; i++)
        {
            var name = parameters[i][PROPERTY_NAME]?.Value<string>();
            if (!string.IsNullOrEmpty(name))
            {
                _Parameters.Add(name!, args[i]);
            }
        }
    }
}

#nullable restore
