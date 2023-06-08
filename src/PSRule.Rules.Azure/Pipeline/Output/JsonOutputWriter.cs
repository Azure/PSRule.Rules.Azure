// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline.Output
{
    internal sealed class JsonOutputWriter : SerializationOutputWriter<object>
    {
        internal JsonOutputWriter(PipelineWriter inner, PSRuleOption option)
            : base(inner, option) { }

        protected override string Serialize(object[] o)
        {
            using var stringWriter = new StringWriter();
            using var jsonTextWriter = new JsonCommentWriter(stringWriter);
            var jsonSerializer = new JsonSerializer
            {
                NullValueHandling = NullValueHandling.Ignore
            };

            jsonSerializer.Converters.Add(new PSObjectJsonConverter());
            jsonSerializer.Converters.Add(new PolicyDefinitionConverter());

            jsonSerializer.Serialize(jsonTextWriter, o);

            return stringWriter.ToString();
        }
    }
}
