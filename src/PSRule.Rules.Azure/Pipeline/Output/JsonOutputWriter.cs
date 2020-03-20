// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            };
            settings.Converters.Add(new PSObjectJsonConverter());
            return JsonConvert.SerializeObject(o, settings: settings);
        }
    }
}
