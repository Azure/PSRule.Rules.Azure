// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// A string stream for reading tokenizing template expressions.
/// </summary>
[DebuggerDisplay("Position = {Position}, Current = {Current}")]
internal sealed class ExpressionStream
{
    private readonly string _Source;
    private readonly int _Length;

    /// <summary>
    /// The current character position in the expression string. Call Next() to change the position.
    /// </summary>
    private int _Position;
    private char _Current;
    private int _EscapeLength;

    // The maximum length of a template expression
    private const int MaxLength = 100000;

    private const char Backslash = '\\';
    private const char Apostrophe = '\'';
    private const char Comma = ',';
    private const char Period = '.';
    private const char ParenthesesOpen = '(';
    private const char ParenthesesClose = ')';
    private const char BracketOpen = '[';
    private const char BracketClose = ']';
    private static readonly char[] FunctionNameStopCharacter = new char[] { '(', ']', '[', ')', '\'', ' ', ',' };
    private static readonly char[] PropertyStopCharacters = new char[] { '(', ']', '[', ',', ')', ' ', '\'', '.', '\r', '\n' };

    internal ExpressionStream(string expression)
    {
        _Source = expression;
        _Length = _Source.Length;
        _Position = 0;
        _EscapeLength = 0;

        if (_Length is < 0 or > MaxLength)
            throw new ArgumentOutOfRangeException(nameof(expression), string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpressionTooLong, expression));

        UpdateCurrent();
    }

    #region Properties

    public bool EOF => _Position >= _Length;

    /// <summary>
    /// The character at the current position in the stream.
    /// </summary>
    public char Current => _Current;

    public string Expression => _Source;

#if DEBUG

    /// <summary>
    /// Used for interactive debugging of current position and next characters in the stream.
    /// </summary>
    public string Preview => _Source.Substring(_Position);

#endif

    public int Position => _Position;

    public bool IsEscaped => _EscapeLength > 0;

    #endregion Properties

    public bool Start()
    {
        return Skip(BracketOpen);
    }

    public bool End()
    {
        return Skip(BracketClose);
    }

    public bool SkipToEnd()
    {
        while (Position < _Length - 1)
            Next();

        return Current == BracketClose;
    }

    public bool TryElement(out string element)
    {
        SkipWhitespace();
        if (Current == Period)
        {
            element = string.Empty;
            return false;
        }
        element = CaptureUntil(FunctionNameStopCharacter);
        return !string.IsNullOrEmpty(element);
    }

    public bool IsGroupStart()
    {
        return Skip(ParenthesesOpen);
    }

    public bool IsGroupEnd()
    {
        return Skip(ParenthesesClose);
    }

    public bool IsString()
    {
        return Skip(Apostrophe);
    }

    public bool CaptureString(out string s)
    {
        s = null;
        if (!IsString())
            return false;

        var start = Position;
        var length = 0;
        while (!EOF)
        {
            if (!IsEscaped && Apostrophe == Current)
                break;

            length++;
            Next();
            SkipQuotePairs(ref length);
        }
        s = Substring(start, length, ignoreDoubleQuotes: false);
        IsString();
        return true;
    }

    public void Separator()
    {
        SkipWhitespace();
        Skip(Comma);
        SkipWhitespace();
    }

    public bool IsIndexStart()
    {
        return Skip(BracketOpen);
    }

    public bool IsIndexEnd()
    {
        return Skip(BracketClose);
    }

    public bool IsProperty()
    {
        return Skip(Period);
    }

    public bool CaptureProperty(out string propertyName)
    {
        propertyName = null;
        if (!IsProperty())
            return false;

        propertyName = CaptureUntil(PropertyStopCharacters);
        return true;
    }

    /// <summary>
    /// Skip if the current character is whitespace.
    /// </summary>
    public void SkipWhitespace()
    {
        while (char.IsWhiteSpace(Current))
            Next();
    }

    public bool Skip(char c)
    {
        if (_Current != c)
            return false;

        Next();
        return true;
    }

    /// <summary>
    /// Move to the next character in the stream.
    /// </summary>
    /// <returns>Is True when more characters exist in the stream.</returns>
    public bool Next(bool ignoreEscaping = false)
    {
        _Position += _EscapeLength > 0 ? _EscapeLength + 1 : 1;
        if (_Position >= _Length)
        {
            _Current = char.MinValue;
            return false;
        }
        UpdateCurrent(ignoreEscaping);
        return true;
    }

    private void SkipQuotePairs(ref int length)
    {
        while (!IsEscaped && Apostrophe == Current && Offset(1, out var offset) && offset == Apostrophe)
        {
            length += 1;
            Next();
            Next();
        }
    }

    private bool Offset(int offset, out char c)
    {
        c = char.MinValue;
        var pos = _Position + offset;
        pos += GetEscapeCount(pos);
        if (pos >= _Length)
            return false;

        c = _Source[pos];
        return true;
    }

    private void UpdateCurrent(bool ignoreEscaping = false)
    {
        // Handle escape sequences
        _EscapeLength = ignoreEscaping ? 0 : GetEscapeCount(_Position);
        _Current = _Source[_Position + _EscapeLength];
    }

    /// <summary>
    /// Count escape is used to offset a position if an escape sequence exists.
    /// </summary>
    private int GetEscapeCount(int position)
    {
        // Check for escape sequences.
        if (position < _Length && _Source[position] == Backslash)
        {
            var next = _Source[position + 1];

            // Check against list of escapable characters.
            if (next is Backslash or BracketOpen or ParenthesesOpen or BracketClose or ParenthesesClose)
                return 1;
        }
        return 0;
    }

    /// <summary>
    /// Count double quote is used to offset a position if double quoting exists with an apostrophe.
    /// </summary>
    private int GetDoubleQuoteCount(int position)
    {
        // Check for apostrophe quote character.
        if (position < _Length && _Source[position] == Apostrophe)
        {
            var next = _Source[position + 1];

            // Check for secondary apostrophe quote character.
            if (next is Apostrophe)
                return 1;
        }
        return 0;
    }

    public string CaptureUntil(char[] c, bool ignoreEscaping = false)
    {
        var start = Position;
        var length = 0;
        while (!EOF)
        {
            if (!IsEscaped && c.Contains(Current))
                break;

            length++;
            Next(ignoreEscaping);
        }
        return Substring(start, length, ignoreEscaping);
    }

    private string Substring(int start, int length, bool ignoreEscaping = false, bool ignoreDoubleQuotes = true)
    {
        if (ignoreEscaping)
            return _Source.Substring(start, length);

        var position = start;
        var i = 0;
        var buffer = new char[length];
        while (i < length)
        {
            var offset = GetEscapeCount(position);
            if (!ignoreDoubleQuotes && offset == 0)
                offset = GetDoubleQuoteCount(position);

            buffer[i] = _Source[position + offset];
            position += offset + 1;
            i++;
        }
        return new string(buffer);
    }
}
