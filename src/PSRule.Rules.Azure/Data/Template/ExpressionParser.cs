using PSRule.Rules.Azure.Resources;
using System.Threading;

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
            var stream = new ExpressionStream(expression);
            var output = new TokenStream();
            var processed = false;
            stream.Start();
            while (!stream.End())
            {
                processed = false;
                if (stream.TryElement(out string element))
                {
                    stream.Separator();
                    output.Function(element);
                    Function(stream, output, element);
                    processed = true;
                }
                if (Index(stream, output))
                {
                    stream.Separator();
                    processed = true;
                }
                if (stream.CaptureProperty(out string propertyName))
                {
                    output.Property(propertyName);
                    stream.Separator();
                    processed = true;
                }
                if (stream.CaptureString(out string literal))
                {
                    output.String(literal);
                    stream.Separator();
                    processed = true;
                }
                if (!processed)
                    throw new ExpressionParseException(expression, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionInvalid, expression));
            }
            output.MoveTo(0);
            return output;
        }

        /// <summary>
        /// Enter a function.
        /// </summary>
        /// <example>
        /// function()
        /// </example>
        private static bool Function(ExpressionStream stream, TokenStream output, string element)
        {
            // Look for '('
            if (!stream.IsGroupStart())
                return false;

            output.GroupStart();
            while (!stream.IsGroupEnd())
                Inner(stream, output);

            output.GroupEnd();
            return true;
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
            if (stream.CaptureString(out string s))
            {
                output.String(s);
                stream.Separator();
            }
            else if (Index(stream, output))
            {
                stream.Separator();
            }
            else if (stream.CaptureProperty(out string propertyName))
            {
                output.Property(propertyName);
                stream.Separator();
            }
            else if (stream.TryElement(out string element))
            {
                stream.Separator();
                output.Function(element);
                Function(stream, output, element);
                stream.Separator();
            }
            else
                throw new ExpressionParseException(stream.Expression, string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ExpressionInvalid, stream.Expression));
        }
    }
}
