// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

internal abstract class SerializationOutputWriter<T>(PipelineWriter inner, PSRuleOption option) : PipelineWriter(inner, option)
{
    private readonly List<T> _Result = [];

    public override void WriteObject(object sendToPipeline, bool enumerateCollection)
    {
        Add(sendToPipeline);
    }

    protected void Add(object o)
    {
        if (o is T[] collection)
            _Result.AddRange(collection);
        else if (o is T item)
            _Result.Add(item);
    }

    public sealed override void End()
    {
        var results = _Result.ToArray();
        base.WriteObject(Serialize(results), false);
    }

    protected abstract string Serialize(T[] o);
}
