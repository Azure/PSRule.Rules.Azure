// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Policy
{
    internal sealed class PolicyAssignmentHelper
    {
        private readonly PipelineContext _pipelineContext;

        public PolicyAssignmentHelper(PipelineContext pipelineContext)
        {
            _pipelineContext = pipelineContext;
        }

        internal PolicyDefinition[] ProcessAssignment(string assignmentFile, out PolicyAssignmentVisitor.PolicyAssignmentContext assignmentContext)
        {
            var rootedAssignmentFile = PSRuleOption.GetRootedPath(assignmentFile);
            if (!File.Exists(rootedAssignmentFile))
                throw new FileNotFoundException(
                    string.Format(
                        Thread.CurrentThread.CurrentCulture,
                        PSRuleResources.AssignmentFileNotFound,
                        rootedAssignmentFile),
                    rootedAssignmentFile);

            var visitor = new PolicyAssignmentDataExportVisitor();
            assignmentContext = new PolicyAssignmentVisitor.PolicyAssignmentContext(_pipelineContext);
            assignmentContext.SetSource(assignmentFile);

            try
            {
                var assignmentArray = ReadFileArray(rootedAssignmentFile);

                foreach (var assignment in assignmentArray)
                    visitor.Visit(assignmentContext, assignment.ToObject<JObject>());
            }
            catch (Exception inner)
            {
                throw new AssignmentReadException(
                    string.Format(
                        Thread.CurrentThread.CurrentCulture,
                        PSRuleResources.AssignmentFileExpandFailed,
                        rootedAssignmentFile,
                        inner.Message),
                    inner,
                    rootedAssignmentFile);
            }

            return assignmentContext.GetDefinitions();
        }

        private static JArray ReadFileArray(string path)
        {
            using var stream = new StreamReader(path);
            using var reader = new CamelCasePropertyNameJsonTextReader(stream);
            return JArray.Load(reader);
        }

        private sealed class CamelCasePropertyNameJsonTextReader : JsonTextReader
        {
            public CamelCasePropertyNameJsonTextReader(TextReader textReader)
                : base(textReader)
            {
            }

            public override object Value
            {
                get
                {
                    return TokenType == JsonToken.PropertyName
                        ? base.Value.ToString().ToCamelCase()
                        : base.Value;
                }
            }
        }
    }
}