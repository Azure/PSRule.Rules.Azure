// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template;

internal delegate object ExpressionFnOuter(ITemplateContext context);
internal delegate object ExpressionFn(ITemplateContext context, object[] args);

internal sealed class ExpressionBuilder
{
    private readonly ExpressionFactory _Functions;

    internal ExpressionBuilder() : this(new ExpressionFactory()) { }

    internal ExpressionBuilder(ExpressionFactory expressionFactory)
    {
        _Functions = expressionFactory;
    }

    internal ExpressionFnOuter Build(string s)
    {
        return Lexer(Parse(s));
    }

    private static TokenStream Parse(string s)
    {
        return ExpressionParser.Parse(s);
    }

    private ExpressionFnOuter Lexer(TokenStream stream)
    {
        if (stream.TryTokenType(ExpressionTokenType.Element, out var token))
            return Element(stream, token);

        if (stream.TryTokenType(ExpressionTokenType.String, out token))
            return String(token);

        if (stream.TryTokenType(ExpressionTokenType.Numeric, out token))
            return Numeric(token);

        return null;
    }

    private ExpressionFnOuter Element(TokenStream stream, ExpressionToken element)
    {
        ExpressionFnOuter result = null;

        // function
        if (stream.Skip(ExpressionTokenType.GroupStart))
        {
            if (!_Functions.TryDescriptor(element.Content, out var descriptor))
                throw new NotImplementedException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.FunctionNotFound, element.Content));

            var fnParams = new List<ExpressionFnOuter>();
            while (!stream.Skip(ExpressionTokenType.GroupEnd))
            {
                fnParams.Add(Inner(stream));
            }
            var aParams = fnParams.ToArray();
            var symbolName = element.Content;
            var symbol = new DebugSymbol(descriptor.Name, symbolName);
            result = (context) => descriptor.Invoke(context, symbol, aParams);

            while (stream.TryTokenType(ExpressionTokenType.IndexStart, out var token) || stream.TryTokenType(ExpressionTokenType.Property, out token))
            {
                if (token.Type == ExpressionTokenType.IndexStart)
                {
                    // Invert: index(fn1(p1, p2), 0)
                    var inner = Inner(stream);
                    var outer = AddIndex(result, inner);
                    result = outer;

                    stream.Skip(ExpressionTokenType.IndexEnd);
                }
                else if (token.Type == ExpressionTokenType.Property)
                {
                    // Invert: property(fn1(p1, p2), "name")
                    var outer = AddProperty(result, token.Content);
                    result = outer;
                }
            }
        }
        // integer
        else
        {
            result = (context) => element.Content;
        }
        return result;
    }

    private ExpressionFnOuter Inner(TokenStream stream)
    {
        ExpressionFnOuter result = null;
        if (stream.TryTokenType(ExpressionTokenType.String, out var token))
            return String(token);

        if (stream.TryTokenType(ExpressionTokenType.Numeric, out token))
            return Numeric(token);

        if (stream.TryTokenType(ExpressionTokenType.Element, out token))
            result = Element(stream, token);

        return result;
    }

    private static ExpressionFnOuter String(ExpressionToken token)
    {
        return (context) => token.Content;
    }

    private static ExpressionFnOuter Numeric(ExpressionToken token)
    {
        return (context) => token.Value;
    }

    private static ExpressionFnOuter AddIndex(ExpressionFnOuter inner, ExpressionFnOuter innerInner)
    {
        return (context) => Index(context, inner, innerInner);
    }

    private static object Index(ITemplateContext context, ExpressionFnOuter inner, ExpressionFnOuter index)
    {
        var source = inner(context);
        var indexResult = index(context);

        if (source is IMock mock)
            return mock.GetValue(indexResult);

        if (ExpressionHelpers.TryArray(source, out var array) && ExpressionHelpers.TryConvertInt(indexResult, out var arrayIndex))
            return array.GetValue(arrayIndex);

        if (source is JObject jObject && ExpressionHelpers.TryString(indexResult, out var propertyName))
        {
            if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var property))
                throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

            return property;
        }

        if (source is ILazyObject lazy && ExpressionHelpers.TryConvertString(indexResult, out var memberName) && lazy.TryProperty(memberName, out var value))
            return value;

        if (ExpressionHelpers.TryString(indexResult, out propertyName) && ExpressionHelpers.TryPropertyOrField(source, propertyName, out value))
            return value;

        throw new InvalidOperationException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.IndexInvalid, indexResult));
    }

    private static ExpressionFnOuter AddProperty(ExpressionFnOuter inner, string propertyName)
    {
        return (context) => Property(context, inner, propertyName);
    }

    private static object Property(ITemplateContext context, ExpressionFnOuter inner, string propertyName)
    {
        var result = inner(context);
        if (ExpressionHelpers.TryPropertyOrField(result, propertyName, out var value))
            return value;

        if (!context.ShouldThrowMissingProperty)
            return null;

        throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));
    }
}
