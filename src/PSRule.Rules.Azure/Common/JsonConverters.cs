// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Data.Policy;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure
{
    /// <summary>
    /// A custom serializer to correctly convert PSObject properties to JSON instead of CLIXML.
    /// </summary>
    internal sealed class PSObjectJsonConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(PSObject);
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            if (value is not PSObject obj)
                throw new ArgumentException(message: PSRuleResources.SerializeNullPSObject, paramName: nameof(value));

            if (value is FileSystemInfo fileSystemInfo)
            {
                WriteFileSystemInfo(writer, fileSystemInfo, serializer);
                return;
            }
            writer.WriteStartObject();
            foreach (var property in obj.Properties)
            {
                // Ignore properties that are not readable or can cause race condition
                if (!property.IsGettable || property.Value is PSDriveInfo || property.Value is ProviderInfo || property.Value is DirectoryInfo)
                    continue;

                writer.WritePropertyName(property.Name);
                serializer.Serialize(writer, property.Value);
            }
            writer.WriteEndObject();
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            // Create target object based on JObject
            var result = existingValue as PSObject ?? new PSObject();

            // Read tokens
            ReadObject(value: result, reader: reader);
            return result;
        }

        private static void ReadObject(PSObject value, JsonReader reader)
        {
            if (reader.TokenType != JsonToken.StartObject)
                throw new PipelineSerializationException(PSRuleResources.ReadJsonFailed);

            reader.Read();
            string name = null;

            // Read each token
            while (reader.TokenType != JsonToken.EndObject)
            {
                switch (reader.TokenType)
                {
                    case JsonToken.PropertyName:
                        name = reader.Value.ToString();
                        break;

                    case JsonToken.StartObject:
                        var child = new PSObject();
                        ReadObject(value: child, reader: reader);
                        value.Properties.Add(new PSNoteProperty(name: name, value: child));
                        break;

                    case JsonToken.StartArray:
                        var items = new List<object>();
                        reader.Read();

                        while (reader.TokenType != JsonToken.EndArray)
                        {
                            items.Add(ReadValue(reader));
                            reader.Read();
                        }

                        value.Properties.Add(new PSNoteProperty(name: name, value: items.ToArray()));
                        break;

                    default:
                        value.Properties.Add(new PSNoteProperty(name: name, value: reader.Value));
                        break;
                }
                reader.Read();
            }
        }

        private static object ReadValue(JsonReader reader)
        {
            if (reader.TokenType != JsonToken.StartObject)
                return reader.Value;

            var value = new PSObject();
            ReadObject(value, reader);
            return value;
        }

        private static void WriteFileSystemInfo(JsonWriter writer, FileSystemInfo value, JsonSerializer serializer)
        {
            serializer.Serialize(writer, value.FullName);
        }
    }

    /// <summary>
    /// A custom serializer to convert PSObjects that may or maynot be in a JSON array to an a PSObject array.
    /// </summary>
    internal sealed class PSObjectArrayJsonConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(PSObject[]);
        }

        public override bool CanWrite => false;

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType is not JsonToken.StartObject and not JsonToken.StartArray)
                throw new PipelineSerializationException(PSRuleResources.ReadJsonFailed);

            var result = new List<PSObject>();
            var isArray = reader.TokenType == JsonToken.StartArray;

            if (isArray)
                reader.Read();

            while (!isArray || (isArray && reader.TokenType != JsonToken.EndArray))
            {
                var value = ReadObject(reader: reader);
                result.Add(value);

                // Consume the EndObject token
                if (isArray)
                {
                    reader.Read();
                }
            }
            return result.ToArray();
        }

        private static PSObject ReadObject(JsonReader reader)
        {
            if (reader.TokenType != JsonToken.StartObject)
                throw new PipelineSerializationException(PSRuleResources.ReadJsonFailed);

            reader.Read();
            var result = new PSObject();
            string name = null;

            // Read each token
            while (reader.TokenType != JsonToken.EndObject)
            {
                switch (reader.TokenType)
                {
                    case JsonToken.PropertyName:
                        name = reader.Value.ToString();
                        break;

                    case JsonToken.StartObject:
                        var value = ReadObject(reader: reader);
                        result.Properties.Add(new PSNoteProperty(name: name, value: value));
                        break;

                    case JsonToken.StartArray:
                        var items = ReadArray(reader: reader);
                        result.Properties.Add(new PSNoteProperty(name: name, value: items));

                        break;

                    default:
                        result.Properties.Add(new PSNoteProperty(name: name, value: reader.Value));
                        break;
                }
                reader.Read();
            }
            return result;
        }

        private static PSObject[] ReadArray(JsonReader reader)
        {
            if (reader.TokenType != JsonToken.StartArray)
                throw new PipelineSerializationException(PSRuleResources.ReadJsonFailed);

            reader.Read();
            var result = new List<PSObject>();

            while (reader.TokenType != JsonToken.EndArray)
            {
                if (reader.TokenType == JsonToken.StartObject)
                {
                    result.Add(ReadObject(reader: reader));
                }
                else if (reader.TokenType == JsonToken.StartArray)
                {
                    result.Add(PSObject.AsPSObject(ReadArray(reader)));
                }
                else
                {
                    result.Add(PSObject.AsPSObject(reader.Value));
                }
                reader.Read();
            }
            return result.ToArray();
        }
    }

    internal sealed class PolicyDefinitionConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(PolicyDefinition);
        }

        public override bool CanWrite => true;

        public override bool CanRead => false;

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            PolicyJsonRuleMapper.MapRule(writer, serializer, value as PolicyDefinition);
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }
    }
}
