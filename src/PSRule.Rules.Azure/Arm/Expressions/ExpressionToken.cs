// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// An individual expression token.
/// </summary>
[DebuggerDisplay("Type = {Type}, Content = {Content}")]
internal sealed class ExpressionToken
{
    internal readonly ExpressionTokenType Type;
    internal readonly long Value;
    internal readonly string Content;

    internal ExpressionToken(ExpressionTokenType type, string content)
    {
        Type = type;
        Content = content;
    }

    internal ExpressionToken(long value)
    {
        Type = ExpressionTokenType.Numeric;
        Value = value;
    }
}
