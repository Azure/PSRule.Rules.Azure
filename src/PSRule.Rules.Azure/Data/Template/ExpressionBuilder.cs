using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    internal delegate object ExpressionFnOuter(TemplateContext context);
    internal delegate object ExpressionFn(TemplateContext context, object[] args);

    internal sealed class ExpressionBuilder
    {
        private readonly ExpressionFactory _Functions;

        internal ExpressionBuilder()
        {
            _Functions = new ExpressionFactory();
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
            return stream.TryTokenType(ExpressionTokenType.Element, out ExpressionToken element) ? Element(stream, element) : null;
        }

        private ExpressionFnOuter Element(TokenStream stream, ExpressionToken element)
        {
            ExpressionFnOuter result = null;

            // function
            if (stream.Skip(ExpressionTokenType.GroupStart))
            {
                if (!_Functions.TryDescriptor(element.Content, out IFunctionDescriptor descriptor))
                    throw new NotImplementedException(string.Format(PSRuleResources.FunctionNotFound, element.Content));

                var fnParams = new List<ExpressionFnOuter>();
                while (!stream.Skip(ExpressionTokenType.GroupEnd))
                {
                    fnParams.Add(Inner(stream));
                }
                var aParams = fnParams.ToArray();

                result = (context) => descriptor.Invoke(context, aParams);

                while (stream.TryTokenType(ExpressionTokenType.IndexStart, out ExpressionToken token) || stream.TryTokenType(ExpressionTokenType.Property, out token))
                {
                    if (token.Type == ExpressionTokenType.IndexStart)
                    {
                        // Invert: index(fn1(p1, p2), 0)
                        var inner = Inner(stream);
                        ExpressionFnOuter outer = AddIndex(result, inner);
                        result = outer;

                        stream.Skip(ExpressionTokenType.IndexEnd);
                    }
                    else if (token.Type == ExpressionTokenType.Property)
                    {
                        // Invert: property(fn1(p1, p2), "name")
                        ExpressionFnOuter outer = AddProperty(result, token.Content);
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
            if (stream.TryTokenType(ExpressionTokenType.String, out ExpressionToken token))
            {
               result = (context) => token.Content;
            }
            else if (stream.TryTokenType(ExpressionTokenType.Element, out token))
            {
                result = Element(stream, token);
            }
            return result;
        }

        private static ExpressionFnOuter AddIndex(ExpressionFnOuter inner, ExpressionFnOuter innerInner)
        {
            return (context) => Index(context, inner, innerInner);
        }

        private static object Index(TemplateContext context, ExpressionFnOuter inner, ExpressionFnOuter index)
        {
            var array = inner(context);
            var indexResult = index(context);
            if (indexResult is string ixs)
                return Index(array, int.Parse(ixs));
            else
                return Index(array, (int)indexResult);
        }

        private static object Index(object value, int index)
        {
            if (value is JArray jArray)
                return jArray[index];

            else if (value is Array array)
                return array.GetValue(index);

            return null;
        }

        private static ExpressionFnOuter AddProperty(ExpressionFnOuter inner, string propertyName)
        {
            return (context) => Property(context, inner, propertyName);
        }

        private static object Property(TemplateContext context, ExpressionFnOuter inner, string propertyName)
        {
            var result = inner(context);
            if (result is JToken jt)
                return jt[propertyName].Value<object>();

            if (result is JObject jobj)
                return jobj[propertyName].Value<object>();

            if (result is MockResource mockResource)
                return JToken.FromObject(string.Concat("{{Resource.", propertyName, "}}"));

            if (result is MockResourceList mockResourceList)
                return JToken.FromObject(string.Concat("{{List.", propertyName, "}}"));

            return PropertyOrField(result, propertyName);
        }

        private static object PropertyOrField(object obj, string propertyName)
        {
            // Try property
            var resultType = obj.GetType();
            var property = resultType.GetProperty(propertyName, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetProperty | BindingFlags.Public);
            if (property != null)
                return property.GetValue(obj);

            // Try field
            var field = resultType.GetField(propertyName, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.GetField | BindingFlags.Public);
            if (field == null)
                throw new ArgumentException();

            return field.GetValue(obj);
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

        private void With(IFunctionDescriptor descriptor)
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

        public FunctionDescriptor(string name, ExpressionFn fn)
        {
            Name = name;
            Fn = fn;
        }

        public string Name { get; }

        public object Invoke(TemplateContext context, ExpressionFnOuter[] args)
        {
            var parameters = new object[args.Length];
            for (var i = 0; i < args.Length; i++)
                parameters[i] = args[i](context);

            return Fn(context, parameters);
        }
    }

    internal interface IFunctionDescriptor
    {
        string Name { get; }

        object Invoke(TemplateContext context, ExpressionFnOuter[] args);
    }
}
