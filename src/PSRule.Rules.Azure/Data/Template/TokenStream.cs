// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace PSRule.Rules.Azure.Data.Template
{
    public enum ExpressionTokenType : byte
    {
        None,

        /// <summary>
        /// A function name.
        /// </summary>
        Element,

        /// <summary>
        /// A property '.property_name'.
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
        /// Start a grouping '('.
        /// </summary>
        GroupStart,

        /// <summary>
        /// End a grouping ')'.
        /// </summary>
        GroupEnd,

        /// <summary>
        /// Start an index '['.
        /// </summary>
        IndexStart,

        /// <summary>
        /// End an index ']'.
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
        internal readonly int Value;
        internal readonly string Content;

        internal ExpressionToken(ExpressionTokenType type, string content)
        {
            Type = type;
            Content = content;
        }

        internal ExpressionToken(int value)
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

        internal static void Numeric(this TokenStream stream, int value)
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
    }

    /// <summary>
    /// A stream of template expression tokens.
    /// </summary>
    [DebuggerDisplay("Current = (Type = {Current.Type}, Content = {Current.Content})")]
    internal sealed class TokenStream
    {
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

        public ExpressionToken Current
        {
            get
            {
                return (_Token.Count <= _Position) ? null : _Token[_Position];
            }
        }

        public int Count
        {
            get { return _Token.Count; }
        }

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
            builder.Append("[");
            var group = 0;
            ExpressionToken last = null;
            for (var i = 0; i < _Token.Count; i++)
            {
                var current = _Token[i];
                if (last != null && !(current.Type == ExpressionTokenType.Property || IsStartOrEndToken(current)) && !(last.Type == ExpressionTokenType.GroupStart || last.Type == ExpressionTokenType.IndexStart))
                    builder.Append(",");

                if (current.Type == ExpressionTokenType.Property)
                    builder.Append(".");
                else if (current.Type == ExpressionTokenType.GroupStart)
                {
                    builder.Append("(");
                    group++;
                }
                else if (current.Type == ExpressionTokenType.GroupEnd)
                {
                    builder.Append(")");
                    group--;
                }
                else if (current.Type == ExpressionTokenType.IndexStart)
                    builder.Append("[");
                else if (current.Type == ExpressionTokenType.IndexEnd)
                    builder.Append("]");
                else if (current.Type == ExpressionTokenType.String)
                    builder.Append("'");
                else if (current.Type == ExpressionTokenType.Numeric)
                    builder.Append(current.Value);

                builder.Append(current.Content);
                if (current.Type == ExpressionTokenType.String)
                    builder.Append("'");

                last = current;
            }
            builder.Append("]");
            return builder.ToString();
        }

        private static bool IsStartOrEndToken(ExpressionToken token)
        {
            return token.Type == ExpressionTokenType.GroupStart || token.Type == ExpressionTokenType.GroupEnd || token.Type == ExpressionTokenType.IndexStart || token.Type == ExpressionTokenType.IndexEnd;
        }
    }
}
