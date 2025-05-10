// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Threading;
using PSRule.Rules.Azure.Arm.Symbols;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// A wrapper for the ARM function definition that can be invoked.
/// </summary>
/// <param name="name">The name of the function, as it is defined by ARM.</param>
/// <param name="fn">The function delegate to invoke.</param>
/// <param name="delayBinding"><c>true</c> if the value of arguments should not be resolved before the function is called.</param>
[DebuggerDisplay("Function: {Name}")]
internal sealed class FunctionDescriptor(string name, ExpressionFn fn, bool delayBinding = false) : IFunctionDescriptor
{
    private readonly ExpressionFn _Fn = fn;
    private readonly bool _DelayBinding = delayBinding;

    /// <inheritdoc/>
    public string Name { get; } = name;

    /// <inheritdoc/>
    public object Invoke(ITemplateContext context, DebugSymbol debugSymbol, ExpressionFnOuter[] args)
    {
        var parameters = new object[args.Length];
        for (var i = 0; i < args.Length; i++)
        {
            // Wait to resolve the argument or calculate the value now.
            parameters[i] = _DelayBinding ? args[i] : ExpressionHelpers.UnwrapLiteralString(args[i](context));
        }

        context.DebugSymbol = debugSymbol;
        try
        {
            return ExpressionHelpers.WrapLiteralString(_Fn(context, parameters));
        }
        catch (TemplateFunctionException ex)
        {
            throw new TemplateFunctionException(Name, ex.ErrorType, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.FunctionGenericError, Name, ex.Message), ex);
        }
        catch (Exception ex)
        {
            throw new TemplateFunctionException(Name, FunctionErrorType.Unknown, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.FunctionGenericError, Name, ex.Message), ex);
        }
    }
}
