﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template
{
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
                result = (context) => descriptor.Invoke(context, aParams);

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

            if (source is JArray jArray && ExpressionHelpers.TryConvertInt(indexResult, out var arrayIndex))
                return jArray[arrayIndex];

            if (source is JObject jObject && ExpressionHelpers.TryString(indexResult, out var propertyName))
            {
                if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var property))
                    throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

                return property;
            }

            if (source is MockNode mockNode && ExpressionHelpers.TryConvertString(indexResult, out var memberName))
                return mockNode.GetMember(memberName);

            if (ExpressionHelpers.TryString(indexResult, out propertyName) && TryPropertyOrField(source, propertyName, out var value))
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
            if (result == null)
                throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

            if (result is JObject jObject)
            {
                if (!jObject.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var property))
                    throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

                return property;
            }

            if (result is JToken jToken)
            {
                var property = jToken[propertyName];
                if (property == null)
                    throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));

                return property.Value<object>();
            }

            if (result is ILazyObject lazy && lazy.TryProperty(propertyName, out var value))
                return value;

            if (TryPropertyOrField(result, propertyName, out value))
                return value;

            throw new ExpressionReferenceException(propertyName, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.PropertyNotFound, propertyName));
        }

        private static bool TryPropertyOrField(object obj, string propertyName, out object value)
        {
            value = null;
            var resultType = obj.GetType();

            // Try dictionary
            if (obj is IDictionary dictionary && dictionary.Contains(propertyName))
            {
                value = dictionary[propertyName];
                return true;
            }

            // Try property
            var property = resultType.GetProperty(propertyName, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetProperty | BindingFlags.Public);
            if (property != null)
            {
                value = property.GetValue(obj);
                return true;
            }

            // Try field
            var field = resultType.GetField(propertyName, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetField | BindingFlags.Public);
            if (field != null)
            {
                value = field.GetValue(obj);
                return true;
            }
            return false;
        }
    }

    internal sealed class ExpressionFactory
    {
        private readonly Dictionary<string, IFunctionDescriptor> _Descriptors;

        public ExpressionFactory()
        {
            _Descriptors = new Dictionary<string, IFunctionDescriptor>(StringComparer.OrdinalIgnoreCase);
            foreach (var d in Functions.Builtin)
                With(d);
        }

        public bool TryDescriptor(string name, out IFunctionDescriptor descriptor)
        {
            return IsList(name) ? _Descriptors.TryGetValue("list", out descriptor) : _Descriptors.TryGetValue(name, out descriptor);
        }

        public void With(IFunctionDescriptor descriptor)
        {
            _Descriptors.Add(descriptor.Name, descriptor);
        }

        private static bool IsList(string name)
        {
            return name.StartsWith("list", StringComparison.OrdinalIgnoreCase);
        }
    }

    [DebuggerDisplay("Function: {Name}")]
    internal sealed class FunctionDescriptor : IFunctionDescriptor
    {
        private readonly ExpressionFn Fn;
        private readonly bool DelayBinding;

        public FunctionDescriptor(string name, ExpressionFn fn, bool delayBinding = false)
        {
            Name = name;
            Fn = fn;
            DelayBinding = delayBinding;
        }

        public string Name { get; }

        public object Invoke(ITemplateContext context, ExpressionFnOuter[] args)
        {
            var parameters = new object[args.Length];
            for (var i = 0; i < args.Length; i++)
                parameters[i] = DelayBinding ? args[i] : args[i](context);

            return Fn(context, parameters);
        }
    }

    internal interface IFunctionDescriptor
    {
        string Name { get; }

        object Invoke(ITemplateContext context, ExpressionFnOuter[] args);
    }
}
