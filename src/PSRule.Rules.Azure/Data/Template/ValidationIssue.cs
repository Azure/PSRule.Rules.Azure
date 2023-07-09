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
        private readonly ValidationKind _Kind;
        private readonly string _Name;
        private readonly string _Message;

        public ValidationIssue(ValidationKind kind, string name, string message)
        {
            _Kind = kind;
            _Name = name;
            _Message = message;
        }
    }
}
