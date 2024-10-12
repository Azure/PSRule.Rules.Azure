// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

internal sealed class HashSetConverter(IEqualityComparer<string> comparer) : JsonConverter<HashSet<string>>
{
    private readonly IEqualityComparer<string> _Comparer = comparer;

    public override HashSet<string> ReadJson(JsonReader reader, Type objectType, HashSet<string> existingValue, bool hasExistingValue, JsonSerializer serializer)
    {
        if (reader == null || serializer == null || reader.TokenType != JsonToken.StartArray)
            return null;

        var d = new HashSet<string>(_Comparer);
        serializer.Populate(reader, d);
        return d;
    }

    public override void WriteJson(JsonWriter writer, HashSet<string> value, JsonSerializer serializer)
    {
        throw new NotImplementedException();
    }
}
