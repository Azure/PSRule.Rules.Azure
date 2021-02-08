// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Runtime
{
    /// <summary>
    /// Helper methods exposed to PowerShell.
    /// </summary>
    public static class Helper
    {
        public static string CompressExpression(string expression)
        {
            if (!IsTemplateExpression(expression))
                return expression;

            return ExpressionParser.Parse(expression).AsString();
        }

        public static bool IsTemplateExpression(string expression)
        {
            return ExpressionParser.IsExpression(expression);
        }
    }
}
