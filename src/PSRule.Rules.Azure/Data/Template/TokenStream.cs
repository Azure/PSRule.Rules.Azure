// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// The available token types used for Azure Resource Manager expressions.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Naming", "CA1720:Identifier contains type name", Justification = "Represents standard type.")]
    public enum ExpressionTokenType : byte
    {
        /// <summary>
        /// Null token.
        /// </summary>
        None,

        /// <summary>
        /// A function name.
        /// </summary>
        Element,

        /// <summary>
        /// A property <c>.property_name</c>.
        /// </summary>
        Property,

        /// <summary>
        /// A string literal.
        /// </summary>
        String,

        /// <summary>
        /// A numeric literal.
        /// </summary>
        Numeric,

        /// <summary>
        /// Start a grouping <c>'('</c>.
        /// </summary>
        GroupStart,

        /// <summary>
        /// End a grouping <c>')'</c>.
        /// </summary>
        GroupEnd,

        /// <summary>
        /// Start an index <c>'['</c>.
        /// </summary>
        IndexStart,

        /// <summary>
        /// End an index <c>']'</c>.
        /// </summary>
        IndexEnd
    }

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

    /// <summary>
    /// Add an expression token to a token stream.
    /// </summary>
    internal static class TokenStreamExtensions
    {
        internal static void Function(this TokenStream stream, string functionName)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.Element, functionName));
        }

        internal static void Numeric(this TokenStream stream, long value)
        {
            stream.Add(new ExpressionToken(value));
        }

        internal static void String(this TokenStream stream, string content)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.String, content));
        }

        internal static void Property(this TokenStream stream, string propertyName)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.Property, propertyName));
        }

        internal static void GroupStart(this TokenStream stream)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.GroupStart, null));
        }

        internal static void GroupEnd(this TokenStream stream)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.GroupEnd, null));
        }

        internal static void IndexStart(this TokenStream stream)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.IndexStart, null));
        }

        internal static void IndexEnd(this TokenStream stream)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.IndexEnd, null));
        }

        internal static bool ConsumeFunction(this TokenStream stream, string name)
        {
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.Element ||
                !string.Equals(stream.Current.Content, name, StringComparison.OrdinalIgnoreCase))
                return false;

            stream.Pop();
            return true;
        }

        internal static bool ConsumePropertyName(this TokenStream stream, string propertyName)
        {
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.Property ||
                !string.Equals(stream.Current.Content, propertyName, StringComparison.OrdinalIgnoreCase))
                return false;

            stream.Pop();
            return true;
        }

        internal static bool ConsumeString(this TokenStream stream, string s)
        {
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.String ||
                !string.Equals(stream.Current.Content, s, StringComparison.OrdinalIgnoreCase))
                return false;

            stream.Pop();
            return true;
        }

        internal static bool ConsumeString(this TokenStream stream, out string s)
        {
            s = null;
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.String)
                return false;

            s = stream.Current.Content;
            stream.Pop();
            return true;
        }

        internal static bool ConsumeInteger(this TokenStream stream, out int? i)
        {
            i = null;
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.Numeric)
                return false;

            i = (int)stream.Current.Value;
            stream.Pop();
            return true;
        }

        internal static bool ConsumeGroup(this TokenStream stream)
        {
            if (stream == null ||
                stream.Count == 0 ||
                stream.Current.Type != ExpressionTokenType.GroupStart)
                return false;

            stream.SkipGroup();
            return true;
        }

        internal static bool HasPolicyRuntimeTokens(this TokenStream stream)
        {
            return stream.ToArray().Any(t =>
                t.Type == ExpressionTokenType.Element &&
                string.Equals("current", t.Content, StringComparison.OrdinalIgnoreCase)
            );
        }
    }

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
            _Token = new List<ExpressionToken>();
        }

        internal TokenStream(IEnumerable<ExpressionToken> tokens)
            : this()
        {
            foreach (var token in tokens)
                Add(token);
        }

        #region Properties

        public ExpressionToken Current => (_Token.Count <= _Position) ? null : _Token[_Position];

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
            return _Token.ToArray();
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
}
