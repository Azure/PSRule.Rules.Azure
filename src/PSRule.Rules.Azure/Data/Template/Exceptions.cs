// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;
using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A template exception.
    /// </summary>
    public abstract class TemplateException : PipelineException
    {
        protected TemplateException()
        {
        }

        protected TemplateException(string message) : base(message)
        {
        }

        protected TemplateException(string message, Exception innerException) : base(message, innerException)
        {
        }

        protected TemplateException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }
    }

    [Serializable]
    public sealed class TemplateParameterException : TemplateException
    {
        public TemplateParameterException()
        {
        }

        public TemplateParameterException(string message)
            : base(message) { }

        public TemplateParameterException(string message, Exception innerException)
            : base(message, innerException) { }

        internal TemplateParameterException(string parameterName, string message)
            : base(message)
        {
            ParameterName = parameterName;
        }

        internal TemplateParameterException(string parameterName, string message, Exception innerException)
            : base(message, innerException)
        {
            ParameterName = parameterName;
        }

        private TemplateParameterException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        public string ParameterName { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    public enum FunctionErrorType
    {
        MismatchingResourceSegments
    }

    [Serializable]
    public sealed class TemplateFunctionException : TemplateException
    {
        public TemplateFunctionException()
        {
        }

        public TemplateFunctionException(string message)
            : base(message) { }

        public TemplateFunctionException(string message, Exception innerException)
            : base(message, innerException) { }

        internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message)
            : base(message)
        {
            FunctionName = functionName;
            ErrorType = errorType;
        }

        internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message, Exception innerException)
            : base(message, innerException)
        {
            FunctionName = functionName;
            ErrorType = errorType;
        }

        private TemplateFunctionException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }

        public string FunctionName { get; }

        public FunctionErrorType ErrorType { get; }
    }

    public abstract class ExpressionException : TemplateException
    {
        protected ExpressionException()
        {
        }

        protected ExpressionException(string message)
            : base(message) { }

        protected ExpressionException(string message, Exception innerException)
            : base(message, innerException) { }

        protected ExpressionException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        protected ExpressionException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        protected ExpressionException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        public string Expression { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    [Serializable]
    public sealed class ExpressionParseException : TemplateException
    {
        public ExpressionParseException()
        {
        }

        public ExpressionParseException(string message)
            : base(message) { }

        public ExpressionParseException(string message, Exception innerException)
            : base(message, innerException) { }

        internal ExpressionParseException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        internal ExpressionParseException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        private ExpressionParseException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        public string Expression { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    [Serializable]
    public sealed class ExpressionReferenceException : TemplateException
    {
        public ExpressionReferenceException()
        {
        }

        public ExpressionReferenceException(string message)
            : base(message) { }

        public ExpressionReferenceException(string message, Exception innerException)
            : base(message, innerException) { }

        internal ExpressionReferenceException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        internal ExpressionReferenceException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        private ExpressionReferenceException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        public string Expression { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    [Serializable]
    public sealed class ExpressionEvaluationException : TemplateException
    {
        public ExpressionEvaluationException()
        {
        }

        public ExpressionEvaluationException(string message)
            : base(message) { }

        public ExpressionEvaluationException(string message, Exception innerException)
            : base(message, innerException) { }

        internal ExpressionEvaluationException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        internal ExpressionEvaluationException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        private ExpressionEvaluationException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        public string Expression { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    [Serializable]
    public sealed class ExpressionArgumentException : ExpressionException
    {
        public ExpressionArgumentException()
        {
        }

        public ExpressionArgumentException(string message)
            : base(message) { }

        public ExpressionArgumentException(string message, Exception innerException)
            : base(message, innerException) { }

        internal ExpressionArgumentException(string expression, string message)
            : base(expression, message) { }

        private ExpressionArgumentException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }
}
