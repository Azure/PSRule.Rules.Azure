// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Arm.Mocks;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template;

internal static class ITemplateContextExtensions
{
    internal static T ExpandProperty<T>(this ITemplateContext context, JObject value, string propertyName)
    {
        if (!value.ContainsKey(propertyName))
            return default;

        var propertyValue = value[propertyName].Value<JValue>();
        return (propertyValue.Type == JTokenType.String) ? ExpandToken<T>(context, propertyValue) : propertyValue.Value<T>();
    }

    internal static T ExpandToken<T>(this ITemplateContext context, JToken value)
    {
        if (typeof(T) == typeof(string) && (value.Type == JTokenType.Object || value.Type == JTokenType.Array))
            return default;

        if (value.Type == JTokenType.Null)
            return default;

        if (value is IMock mock)
            return mock.GetValue<T>();

        return value.IsExpressionString() ? EvaluateExpression<T>(context, value) : value.Value<T>();
    }

    internal static T EvaluateExpression<T>(this ITemplateContext context, ExpressionFnOuter fn)
    {
        var result = fn(context);
        return result is JToken token && !typeof(JToken).IsAssignableFrom(typeof(T)) ? token.Value<T>() : Convert<T>(result);
    }

    private static T Convert<T>(object o)
    {
        if (o is T value)
            return value;

        return typeof(JToken).IsAssignableFrom(typeof(T)) && ExpressionHelpers.GetJToken(o) is T token ? token : (T)o;
    }

    internal static T EvaluateExpression<T>(this ITemplateContext context, JToken value)
    {
        if (value.Type != JTokenType.String)
            return default;

        var s = value.Value<string>();
        var lineInfo = value.TryLineInfo();
        return EvaluateExpression<T>(context, s, lineInfo, value.Path);
    }

#nullable enable

    internal static T? EvaluateExpression<T>(this ITemplateContext context, string? value, IJsonLineInfo? lineInfo, string? path)
    {
        if (string.IsNullOrEmpty(value) || value == null)
            return default;

        var exp = Expression<T>(context, value);
        try
        {
            return exp();
        }
        catch (Exception inner)
        {
            throw new ExpressionEvaluationException(
                value,
                lineInfo?.LineNumber,
                path ?? string.Empty,
                string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionEvaluateError, value, lineInfo?.LineNumber, path ?? string.Empty, inner.Message),
                inner
            );
        }
    }

#nullable restore

    internal static StringExpression<T> Expression<T>(this ITemplateContext context, string s)
    {
        context.WriteDebug(s);
        return () => EvaluateExpression<T>(context, context.BuildExpression(s));
    }
}
