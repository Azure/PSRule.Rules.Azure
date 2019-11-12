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
}
