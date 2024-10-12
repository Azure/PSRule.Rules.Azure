// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

internal sealed class ReadOnlyDictionaryConverter<TValue>(IEqualityComparer<string> comparer) : JsonConverter<IReadOnlyDictionary<string, TValue>>
{
    private readonly IEqualityComparer<string> _Comparer = comparer;

    public override IReadOnlyDictionary<string, TValue> ReadJson(JsonReader reader, Type objectType, IReadOnlyDictionary<string, TValue> existingValue, bool hasExistingValue, JsonSerializer serializer)
    {
        if (reader == null || serializer == null || reader.TokenType != JsonToken.StartObject)
            return null;

        var d = new Dictionary<string, TValue>(_Comparer);
        serializer.Populate(reader, d);
        return new ReadOnlyDictionary<string, TValue>(d);
    }

    public override void WriteJson(JsonWriter writer, IReadOnlyDictionary<string, TValue> value, JsonSerializer serializer)
    {
        throw new NotImplementedException();
    }
}
