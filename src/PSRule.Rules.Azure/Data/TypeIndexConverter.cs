// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    internal sealed class TypeIndexConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(TypeIndex);
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType != JsonToken.StartObject)
                return null;

            reader.Read();
            var index = new Dictionary<string, TypeIndexEntry>(StringComparer.OrdinalIgnoreCase);
            while (reader.TokenType != JsonToken.EndObject)
            {
                if (TryReadEntry(reader, out var typeName, out var entry))
                    index.Add(typeName, entry);
                else if (reader.TokenType != JsonToken.EndObject)
                    reader.Skip();
            }
            return new TypeIndex(new ReadOnlyDictionary<string, TypeIndexEntry>(index));
        }

        private static bool TryReadEntry(JsonReader reader, out string typeName, out TypeIndexEntry entry)
        {
            typeName = null;
            entry = null;
            if (reader.TokenType != JsonToken.PropertyName)
                return false;

            typeName = reader.Value as string;
            reader.Read();
            var provider = ReadProvider(reader);
            var relativePath = TypeIndex.GetRelativePath(provider);
            var index = ReadIndex(reader);
            reader.Read();
            reader.Read();
            entry = new TypeIndexEntry(relativePath, (int)index);
            return true;
        }

        private static int ReadIndex(JsonReader reader)
        {
            return reader.Read() &&
                reader.TokenType == JsonToken.PropertyName &&
                reader.Read() &&
                reader.TokenType == JsonToken.Integer ? (int)(long)reader.Value : 0;
        }

        private static string ReadProvider(JsonReader reader)
        {
            return reader.Read() &&
                reader.TokenType == JsonToken.PropertyName &&
                reader.Read() &&
                reader.TokenType == JsonToken.String ? reader.Value as string : null;
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }
    }
}
