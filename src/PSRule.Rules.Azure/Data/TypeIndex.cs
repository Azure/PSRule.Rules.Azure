// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    /// <summary>
    /// An index location.
    /// </summary>
    internal sealed class TypeIndexEntry
    {
        public TypeIndexEntry(string relativePath, int index)
        {
            RelativePath = relativePath;
            Index = index;
        }

        [JsonProperty(PropertyName = "r")]
        public string RelativePath { get; set; }

        [JsonProperty(PropertyName = "i")]
        public int Index { get; set; }
    }

    /// <summary>
    /// Defines an index of Azure resource provider types.
    /// </summary>
    internal sealed class TypeIndex
    {
        public TypeIndex(IReadOnlyDictionary<string, TypeIndexEntry> resources)
        {
            Resources = resources;
        }

        /// <summary>
        /// Available resource types, indexed by resource type name.
        /// </summary>
        public IReadOnlyDictionary<string, TypeIndexEntry> Resources { get; }

        public static string GetRelativePath(string provider)
        {
            return string.Concat("providers/", provider, "/types.min.json.deflated");
        }
    }

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

    internal sealed class ReadOnlyDictionaryConverter<TValue> : JsonConverter<IReadOnlyDictionary<string, TValue>>
    {
        private readonly IEqualityComparer<string> _Comparer;

        public ReadOnlyDictionaryConverter(IEqualityComparer<string> comparer)
        {
            _Comparer = comparer;
        }

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
}
