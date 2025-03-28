// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// A function that can be invoked at runtime to resolve the value of an expression.
/// </summary>
internal delegate object ExpressionFnOuter(ITemplateContext context);

internal delegate object ExpressionFn(ITemplateContext context, object[] args);

/// <summary>
/// Based on an expression string, build a delegate that will resolve the expression at runtime to a value.
/// This builder first parses the expression into tokens, then walks the tokens to build a delegate that can be invoked at sometime in the future.
/// </summary>
internal sealed class ExpressionBuilder
{
    private readonly ExpressionFactory _Functions;

    internal ExpressionBuilder() : this(new ExpressionFactory()) { }

    internal ExpressionBuilder(ExpressionFactory expressionFactory)
    {
        _Functions = expressionFactory;
    }

    /// <summary>
    /// Convert the expression string into a delegate that can be invoked at runtime.
    /// </summary>
    internal ExpressionFnOuter Build(string s)
    {
        return Lexer(Parse(s));
    }

    /// <summary>
    /// Break up the expression into tokens.
    /// </summary>
    private static TokenStream Parse(string s)
    {
        return ExpressionParser.Parse(s);
    }

    /// <summary>
    /// Walk through the tokens and return a callable function delegate.
    /// </summary>
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

    /// <summary>
    /// An element is most likely a function, but could be a numeric literal.
    /// </summary>
    private ExpressionFnOuter Element(TokenStream stream, ExpressionToken element)
    {
        ExpressionFnOuter result = null;

        // function
        if (stream.Skip(ExpressionTokenType.GroupStart))
        {
            // Try to find a known ARM function.
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

    /// <summary>
    /// Handle the token as a string literal.
    /// </summary>
    private static ExpressionFnOuter String(ExpressionToken token)
    {
        return (context) => token.Content;
    }

    /// <summary>
    /// Handle the token as a numeric literal.
    /// </summary>
    private static ExpressionFnOuter Numeric(ExpressionToken token)
    {
        return (context) => token.Value;
    }

    private static ExpressionFnOuter AddIndex(ExpressionFnOuter leftSideExpression, ExpressionFnOuter index)
    {
        return (context) => EvaluateIndex(context, leftSideExpression, index);
    }

    private static ExpressionFnOuter AddProperty(ExpressionFnOuter leftSideExpression, string propertyName)
    {
        return (context) => EvaluateProperty(context, leftSideExpression, propertyName);
    }

    /// <summary>
    /// Evaluate an index expression and get the result.
    /// </summary>
    private static object EvaluateIndex(ITemplateContext context, ExpressionFnOuter leftSideExpression, ExpressionFnOuter index)
    {
        // Get the value of the expression to the left side of the index.
        var leftValue = leftSideExpression(context);

        // Get the number or string that was used as the index value. i.e. [0], ["name"]
        var indexValue = index(context);

        if (leftValue is IMock mock)
            return mock.GetValue(indexValue);

        // If the left side is an array, get that element number.
        if (ExpressionHelpers.TryArray(leftValue, out var array) && ExpressionHelpers.TryConvertInt(indexValue, out var arrayIndex))
            return array.GetValue(arrayIndex);

        // If the left side is an object, then get the property.
        if (leftValue is JObject jObject && ExpressionHelpers.TryString(indexValue, out var propertyName))
        {
            if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var property))
                throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

            return property;
        }

        if (leftValue is ILazyObject lazy && ExpressionHelpers.TryConvertString(indexValue, out var memberName) && lazy.TryProperty(memberName, out var value))
            return value;

        if (ExpressionHelpers.TryString(indexValue, out propertyName) && ExpressionHelpers.TryPropertyOrField(leftValue, propertyName, out value))
            return value;

        throw new InvalidOperationException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.IndexInvalid, indexValue));
    }

    /// <summary>
    /// Evaluate a property expression and get the result.
    /// </summary>
    private static object EvaluateProperty(ITemplateContext context, ExpressionFnOuter leftSideExpression, string propertyName)
    {
        // Get the value of expression on the left side of the dot. i.e. some.property
        var result = leftSideExpression(context);

        // Try to get the property.
        if (ExpressionHelpers.TryPropertyOrField(result, propertyName, out var value))
            return value;

        if (!context.ShouldThrowMissingProperty)
            return null;

        throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));
    }
}
