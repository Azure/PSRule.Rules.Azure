// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
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
        private readonly PipelineContext _PipelineContext;
        private readonly bool _KeepDuplicates;

        public PolicyAssignmentHelper(PipelineContext pipelineContext, bool keepDuplicates)
        {
            _PipelineContext = pipelineContext;
            _KeepDuplicates = keepDuplicates;
        }

        internal PolicyDefinition[] ProcessAssignment(string assignmentFile, out PolicyAssignmentVisitor.PolicyAssignmentContext context)
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
            context = new PolicyAssignmentVisitor.PolicyAssignmentContext(_PipelineContext, _KeepDuplicates);
            context.SetSource(assignmentFile);

            try
            {
                var assignments = ReadFileArray(rootedAssignmentFile);

                // Process each assignment object
                foreach (var assignment in assignments)
                {
                    try
                    {
                        visitor.Visit(context, assignment);
                    }
                    catch (Exception inner)
                    {
                        _PipelineContext.Writer.WriteError(inner, inner.GetBaseException().GetType().FullName, errorCategory: ErrorCategory.NotSpecified, targetObject: assignment);
                    }
                }
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
            var definitions = context.GetDefinitions();
            var baseline = context.GenerateBaseline();
            return definitions;
        }

        private static JObject[] ReadFileArray(string path)
        {
            using var stream = new StreamReader(path);
            using var reader = new CamelCasePropertyNameJsonTextReader(stream);
            return JArray.Load(reader).Values<JObject>().ToArray();
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
