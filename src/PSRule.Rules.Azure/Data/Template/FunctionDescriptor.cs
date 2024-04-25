// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A wrapper for the function definition that can be invoked.
    /// </summary>
    [DebuggerDisplay("Function: {Name}")]
    internal sealed class FunctionDescriptor : IFunctionDescriptor
    {
        private readonly ExpressionFn _Fn;
        private readonly bool _DelayBinding;

        public FunctionDescriptor(string name, ExpressionFn fn, bool delayBinding = false)
        {
            Name = name;
            _Fn = fn;
            _DelayBinding = delayBinding;
        }

        /// <inheritdoc/>
        public string Name { get; }

        /// <inheritdoc/>
        public object Invoke(ITemplateContext context, DebugSymbol debugSymbol, ExpressionFnOuter[] args)
        {
            var parameters = new object[args.Length];
            for (var i = 0; i < args.Length; i++)
                parameters[i] = _DelayBinding ? args[i] : args[i](context);

            context.DebugSymbol = debugSymbol;
            return _Fn(context, parameters);
        }
    }
}
