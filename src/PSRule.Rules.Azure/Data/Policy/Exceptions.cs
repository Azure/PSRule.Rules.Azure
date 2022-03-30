// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Policy
{
    [Serializable]
    public sealed class AssignmentReadException : PipelineException
    {
        /// <summary>
        /// Creates an assignment read exception.
        /// </summary>
        public AssignmentReadException()
        {
        }

        /// <summary>
        /// Creates an assignment read exception.
        /// </summary>
        /// <param name="message">The detail of the exception.</param>
        public AssignmentReadException(string message)
            : base(message) { }

        /// <summary>
        /// Creates an assignment read exception.
        /// </summary>
        /// <param name="message">The detail of the exception.</param>
        /// <param name="innerException">A nested exception that caused the issue.</param>
        public AssignmentReadException(string message, Exception innerException)
            : base(message, innerException) { }

        public AssignmentReadException(string message, Exception innerException, string assignmentFile)
            : this(message, innerException)
        {
            AssignmentFile = assignmentFile;
        }

        private AssignmentReadException(SerializationInfo info, StreamingContext context)
            : base(info, context) { }

        /// <summary>
        /// The file path to an Assignment file.
        /// </summary>
        public string AssignmentFile { get; }

        [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            if (info == null)
                throw new ArgumentNullException(nameof(info));

            base.GetObjectData(info, context);
        }
    }
}