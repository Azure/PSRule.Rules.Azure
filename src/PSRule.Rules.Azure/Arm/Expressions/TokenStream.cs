// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// A stream of template expression tokens.
/// </summary>
[DebuggerDisplay("Current = (Type = {Current.Type}, Content = {Current.Content})")]
internal sealed class TokenStream
{
    private const char Comma = ',';
    private const char Dot = '.';
    private const char BackSlash = '\'';
    private const char FunctionOpen = '(';
    private const char FunctionClose = ')';
    private const char IndexOpen = '[';
    private const char IndexClose = ']';

    private readonly List<ExpressionToken> _Token;

    private int _Position;

    internal TokenStream()
    {
        _Token = [];
    }

    internal TokenStream(IEnumerable<ExpressionToken> tokens)
        : this()
    {
        foreach (var token in tokens)
            Add(token);
    }

    #region Properties

    public ExpressionToken Current => _Token.Count <= _Position ? null : _Token[_Position];

    public int Count => _Token.Count;

    #endregion Properties

    public bool TryTokenType(ExpressionTokenType tokenType, out ExpressionToken token)
    {
        token = null;
        if (Current == null || Current.Type != tokenType)
            return false;

        token = Pop();
        return true;
    }

    /// <summary>
    /// Check if the current token is of the specified type and move to the next token.
    /// </summary>
    public bool Skip(ExpressionTokenType tokenType)
    {
        if (Current == null || Current.Type != tokenType)
            return false;

        Pop();
        return true;
    }

    public void SkipGroup()
    {
        if (!TryTokenType(ExpressionTokenType.GroupStart, out _))
            return;

        var inner = 0;
        while (inner >= 0 && Count > 0)
        {
            if (Current.Type == ExpressionTokenType.GroupStart)
                inner++;

            if (Current.Type == ExpressionTokenType.GroupEnd)
                inner--;

            Pop();
        }
    }

    public void Add(ExpressionToken token)
    {
        _Token.Add(token);
        _Position = _Token.Count - 1;
    }

    public ExpressionToken Pop()
    {
        if (Count == 0)
            return null;

        var token = _Token[_Position];
        _Token.RemoveAt(_Position);
        return token;
    }

    public void MoveTo(int position)
    {
        _Position = position;
    }

    internal ExpressionToken[] ToArray()
    {
        return [.. _Token];
    }

    internal string AsString()
    {
        var builder = new StringBuilder();
        builder.Append(IndexOpen);
        var group = 0;
        ExpressionToken last = null;
        for (var i = 0; i < _Token.Count; i++)
        {
            var current = _Token[i];
            if (last != null && !(current.Type == ExpressionTokenType.Property || IsStartOrEndToken(current)) && !(last.Type == ExpressionTokenType.GroupStart || last.Type == ExpressionTokenType.IndexStart))
                builder.Append(Comma);

            if (current.Type == ExpressionTokenType.Property)
                builder.Append(Dot);
            else if (current.Type == ExpressionTokenType.GroupStart)
            {
                builder.Append(FunctionOpen);
                group++;
            }
            else if (current.Type == ExpressionTokenType.GroupEnd)
            {
                builder.Append(FunctionClose);
                group--;
            }
            else if (current.Type == ExpressionTokenType.IndexStart)
                builder.Append(IndexOpen);
            else if (current.Type == ExpressionTokenType.IndexEnd)
                builder.Append(IndexClose);
            else if (current.Type == ExpressionTokenType.String)
                builder.Append(BackSlash);
            else if (current.Type == ExpressionTokenType.Numeric)
                builder.Append(current.Value);

            builder.Append(current.Content);
            if (current.Type == ExpressionTokenType.String)
                builder.Append(BackSlash);

            last = current;
        }
        builder.Append(IndexClose);
        return builder.ToString();
    }

    private static bool IsStartOrEndToken(ExpressionToken token)
    {
        return token.Type is ExpressionTokenType.GroupStart or ExpressionTokenType.GroupEnd or ExpressionTokenType.IndexStart or ExpressionTokenType.IndexEnd;
    }
}
