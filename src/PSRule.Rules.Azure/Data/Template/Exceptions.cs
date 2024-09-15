// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// The type of function error.
    /// </summary>
    public enum FunctionErrorType
    {
        /// <summary>
        /// An error cause by mismatching resource segments.
        /// </summary>
        MismatchingResourceSegments
    }

    /// <summary>
    /// A base class for an exception relating to a template.
    /// </summary>
    public abstract class TemplateException : PipelineException
    {
        /// <summary>
        /// Create an instance of a template exception.
        /// </summary>
        protected TemplateException() { }

        /// <summary>
        /// Create an instance of a template exception.
        /// </summary>
        protected TemplateException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of a template exception.
        /// </summary>
        protected TemplateException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of a template exception.
        /// </summary>
        protected TemplateException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }
    }

    /// <summary>
    /// An exception relating to a template parameter.
    /// </summary>
    [Serializable]
    public sealed class TemplateParameterException : TemplateException
    {
        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        public TemplateParameterException() { }

        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        public TemplateParameterException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        public TemplateParameterException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        internal TemplateParameterException(string parameterName, string message)
            : base(message)
        {
            ParameterName = parameterName;
        }

        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        internal TemplateParameterException(string parameterName, string message, Exception innerException)
            : base(message, innerException)
        {
            ParameterName = parameterName;
        }

        /// <summary>
        /// Create an instance of a template parameter exception.
        /// </summary>
        private TemplateParameterException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The name of the parameter.
        /// </summary>
        public string ParameterName { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to a template output.
    /// </summary>
    [Serializable]
    public sealed class TemplateOutputException : TemplateException
    {
        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        public TemplateOutputException() { }

        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        public TemplateOutputException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        public TemplateOutputException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        internal TemplateOutputException(string outputName, string message)
            : base(message)
        {
            OutputName = outputName;
        }

        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        internal TemplateOutputException(string outputName, string message, Exception innerException)
            : base(message, innerException)
        {
            OutputName = outputName;
        }

        /// <summary>
        /// Create an instance of a template output exception.
        /// </summary>
        private TemplateOutputException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The name of the output.
        /// </summary>
        public string OutputName { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to a template function.
    /// </summary>
    [Serializable]
    public sealed class TemplateFunctionException : TemplateException
    {
        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        public TemplateFunctionException() { }

        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        public TemplateFunctionException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        public TemplateFunctionException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message)
            : base(message)
        {
            FunctionName = functionName;
            ErrorType = errorType;
        }

        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message, Exception innerException)
            : base(message, innerException)
        {
            FunctionName = functionName;
            ErrorType = errorType;
        }

        /// <summary>
        /// Create an instance of a template function exception.
        /// </summary>
        private TemplateFunctionException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }

        /// <summary>
        /// The name of the function.
        /// </summary>
        public string FunctionName { get; }

        /// <summary>
        /// The type of error raised.
        /// </summary>
        public FunctionErrorType ErrorType { get; }
    }

    /// <summary>
    /// A base class for an exception relating to an expression.
    /// </summary>
    public abstract class ExpressionException : TemplateException
    {
        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException() { }

        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression exception.
        /// </summary>
        protected ExpressionException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The expression that caused the exception.
        /// </summary>
        public string Expression { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to expression parsing.
    /// </summary>
    [Serializable]
    public sealed class ExpressionParseException : TemplateException
    {
        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        public ExpressionParseException() { }

        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        public ExpressionParseException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        public ExpressionParseException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        internal ExpressionParseException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        internal ExpressionParseException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression parsing exception.
        /// </summary>
        private ExpressionParseException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The expression that caused the exception.
        /// </summary>
        public string Expression { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to an expression reference.
    /// </summary>
    [Serializable]
    public sealed class ExpressionReferenceException : TemplateException
    {
        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        public ExpressionReferenceException() { }

        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        public ExpressionReferenceException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        public ExpressionReferenceException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        internal ExpressionReferenceException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        internal ExpressionReferenceException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression reference exception.
        /// </summary>
        private ExpressionReferenceException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The expression that caused the exception.
        /// </summary>
        public string Expression { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to expression evaluation.
    /// </summary>
    [Serializable]
    public sealed class ExpressionEvaluationException : TemplateException
    {
        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        public ExpressionEvaluationException() { }

        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        public ExpressionEvaluationException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        public ExpressionEvaluationException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        internal ExpressionEvaluationException(string expression, string message)
            : base(message)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        internal ExpressionEvaluationException(string expression, string message, Exception innerException)
            : base(message, innerException)
        {
            Expression = expression;
        }

        /// <summary>
        /// Create an instance of an expression evaluation exception.
        /// </summary>
        private ExpressionEvaluationException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The expression that caused the exception.
        /// </summary>
        public string Expression { get; }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }

    /// <summary>
    /// An exception relating to expression arguments.
    /// </summary>
    [Serializable]
    public sealed class ExpressionArgumentException : ExpressionException
    {
        /// <summary>
        /// Create an instance of an expression argument exception.
        /// </summary>
        public ExpressionArgumentException() { }

        /// <summary>
        /// Create an instance of an expression argument exception.
        /// </summary>
        public ExpressionArgumentException(string message)
            : base(message) { }

        /// <summary>
        /// Create an instance of an expression argument exception.
        /// </summary>
        public ExpressionArgumentException(string message, Exception innerException)
            : base(message, innerException) { }

        /// <summary>
        /// Create an instance of an expression argument exception.
        /// </summary>
        internal ExpressionArgumentException(string expression, string message)
            : base(expression, message) { }

        /// <summary>
        /// Create an instance of an expression argument exception.
        /// </summary>
        private ExpressionArgumentException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <inheritdoc/>
        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null) throw new ArgumentNullException(nameof(info));
            base.GetObjectData(info, context);
        }
    }
}
