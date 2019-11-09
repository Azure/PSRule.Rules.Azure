using System.Collections.Generic;
using System.Diagnostics;

namespace PSRule.Rules.Azure.Data.Template
{
    public enum ExpressionTokenType : byte
    {
        None,

        /// <summary>
        /// A function name.
        /// </summary>
        Element,

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
        internal readonly string Content;

        internal ExpressionToken(ExpressionTokenType type, string content)
        {
            Type = type;
            Content = content;
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

        internal static void String(this TokenStream stream, string s)
        {
            stream.Add(new ExpressionToken(ExpressionTokenType.String, s));
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
    }
}
