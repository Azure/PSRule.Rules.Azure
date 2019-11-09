using Newtonsoft.Json;
using System.Collections.Generic;

namespace PSRule.Rules.Azure.Pipeline
{
    internal delegate void WriteOutput(object o, bool enumerate);

    internal abstract class PipelineWriter
    {
        private readonly WriteOutput _Output;

        protected PipelineWriter(WriteOutput output)
        {
            _Output = output;
        }

        public virtual void Write(object o, bool enumerate)
        {
            _Output(o, enumerate);
        }

        public virtual void End()
        {
            // Do nothing
        }
    }

    internal sealed class PowerShellWriter : PipelineWriter
    {
        internal PowerShellWriter(WriteOutput output)
            : base(output) { }

        public override void Write(object o, bool enumerate)
        {
            base.Write(o, enumerate);
        }
    }

    internal sealed class JsonPipelineWriter : PipelineWriter
    {
        private readonly List<object> _Result;

        internal JsonPipelineWriter(WriteOutput output)
            : base(output)
        {
            _Result = new List<object>();
        }

        public override void Write(object o, bool enumerate)
        {
            if (enumerate && o is IEnumerable<object> items)
            {
                _Result.AddRange(items);
                return;
            }
            _Result.Add(o);
        }

        public override void End()
        {
            WriteObjectJson();
        }

        private void WriteObjectJson()
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            };
            settings.Converters.Add(new PSObjectJsonConverter());
            var json = JsonConvert.SerializeObject(_Result.ToArray(), settings: settings);
            base.Write(json, false);
        }
    }
}
