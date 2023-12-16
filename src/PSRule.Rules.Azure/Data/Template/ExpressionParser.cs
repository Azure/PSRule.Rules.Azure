// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A helper class used to parse template expressions.
    /// </summary>
    internal static class ExpressionParser
    {
        /// <summary>
        /// Tokenize an expression.
        /// </summary>
        /// <param name="expression">The expression.</param>
        /// <returns>A stream of tokens representing the expression.</returns>
        /// <example>
        /// [parameters('vnetName')]
        /// [concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]
        /// [concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]
        /// </example>
        internal static TokenStream Parse(string expression)
        {
            var output = new TokenStream();
            if (string.IsNullOrEmpty(expression))
                return output;

            var stream = new ExpressionStream(expression);
            stream.Start();
            while (!stream.End())
            {
                var processed = TryElement(stream, output) || TryIndex(stream, output) || TryProperty(stream, output) || TryString(stream, output);
                if (!processed)
                    throw new ExpressionParseException(expression, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionInvalid, expression));
            }
            output.MoveTo(0);
            return output;
        }

        internal static bool IsExpression(string expression)
        {
            if (string.IsNullOrEmpty(expression))
                return false;

            var stream = new ExpressionStream(expression);
            return stream.Start() && !stream.Start() && stream.SkipToEnd();
        }

        private static bool TryProperty(ExpressionStream stream, TokenStream output)
        {
            if (!stream.CaptureProperty(out var propertyName))
                return false;

            output.Property(propertyName);
            stream.Separator();
            return true;
        }

        private static bool TryIndex(ExpressionStream stream, TokenStream output)
        {
            if (!Index(stream, output))
                return false;

            stream.Separator();
            return true;
        }

        private static bool TryString(ExpressionStream stream, TokenStream output)
        {
            if (!stream.CaptureString(out var literal))
                return false;

            output.String(literal);
            stream.Separator();
            return true;
        }

        private static bool TryElement(ExpressionStream stream, TokenStream output)
        {
            if (!stream.TryElement(out var element))
                return false;

            stream.Separator();
            if (int.TryParse(element, out var numeric))
                output.Numeric(numeric);
            else
            {
                output.Function(element);
                Function(stream, output);
            }
            return true;
        }

        /// <summary>
        /// Enter a function.
        /// </summary>
        /// <example>
        /// function()
        /// </example>
        private static void Function(ExpressionStream stream, TokenStream output)
        {
            // Look for '('
            if (!stream.IsGroupStart())
                return;

            output.GroupStart();
            stream.Separator();
            while (!stream.IsGroupEnd())
                Inner(stream, output);

            output.GroupEnd();
            stream.Separator();
        }

        /// <summary>
        /// Enter an index.
        /// </summary>
        /// <example>
        /// function()[0]
        /// </example>
        private static bool Index(ExpressionStream stream, TokenStream output)
        {
            // Look for '['
            if (!stream.IsIndexStart())
                return false;

            output.IndexStart();
            while (!stream.IsIndexEnd())
                Inner(stream, output);

            output.IndexEnd();
            return true;
        }

        /// <summary>
        /// Parse inner tokens.
        /// </summary>
        private static void Inner(ExpressionStream stream, TokenStream output)
        {
            stream.SkipWhitespace();
            if (!(TryString(stream, output) || TryIndex(stream, output) || TryProperty(stream, output) || TryElement(stream, output)))
                throw new ExpressionParseException(stream.Expression, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionInvalid, stream.Expression));
        }
    }
}
