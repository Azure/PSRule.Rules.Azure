// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    internal enum ValidationKind
    {
        None = 0,

        Parameter = 1
    }

    internal sealed class ValidationIssue
    {
        private ValidationKind kind;
        private string name;
        private string message;

        public ValidationIssue(ValidationKind kind, string name, string message)
        {
            this.kind = kind;
            this.name = name;
            this.message = message;
        }
    }
}