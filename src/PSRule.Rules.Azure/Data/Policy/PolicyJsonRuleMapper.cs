// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data.Policy
{
    /// <summary>
    /// Serializes a policy definition to a rule.
    /// </summary>
    internal static class PolicyJsonRuleMapper
    {
        private const string SYNOPSIS_COMMENT = "Synopsis: ";
        private const string PROPERTY_APIVERSION = "apiVersion";
        private const string APIVERSION_VALUE = "github.com/microsoft/PSRule/v1";
        private const string PROPERTY_KIND = "kind";
        private const string KIND_VALUE = "Rule";
        private const string PROPERTY_METADATA = "metadata";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_SPEC = "spec";
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_TAGS = "tags";
        private const string PROPERTY_ANNOTATIONS = "annotations";
        private const string PROPERTY_CATEGORY = "Azure.Policy/category";
        private const string PROPERTY_VERSION = "Azure.Policy/version";
        private const string PROPERTY_ID = "Azure.Policy/id";

        internal static void MapRule(JsonWriter writer, JsonSerializer serializer, PolicyDefinition definition)
        {
            writer.WriteStartObject();

            // Synopsis
            writer.WriteComment(string.Concat(SYNOPSIS_COMMENT, definition.Description));

            // Api Version
            writer.WritePropertyName(PROPERTY_APIVERSION);
            writer.WriteValue(APIVERSION_VALUE);

            // Kind
            writer.WritePropertyName(PROPERTY_KIND);
            writer.WriteValue(KIND_VALUE);

            // Metadata
            writer.WritePropertyName(PROPERTY_METADATA);
            writer.WriteStartObject();
            writer.WritePropertyName(PROPERTY_NAME);
            writer.WriteValue(definition.Name);
            WriteTags(writer, definition);
            WriteAnnotations(writer, definition);
            writer.WriteEndObject();

            // Spec
            writer.WritePropertyName(PROPERTY_SPEC);
            writer.WriteStartObject();
            writer.WritePropertyName(PROPERTY_CONDITION);
            serializer.Serialize(writer, definition.Condition);
            writer.WriteEndObject();

            writer.WriteEndObject();
        }

        private static void WriteTags(JsonWriter writer, PolicyDefinition definition)
        {
            if (string.IsNullOrEmpty(definition.Category))
                return;

            writer.WritePropertyName(PROPERTY_TAGS);
            writer.WriteStartObject();
            writer.WritePropertyName(PROPERTY_CATEGORY);
            writer.WriteValue(definition.Category);
            writer.WriteEndObject();
        }

        private static void WriteAnnotations(JsonWriter writer, PolicyDefinition definition)
        {
            if (string.IsNullOrEmpty(definition.Version) &&
                string.IsNullOrEmpty(definition.DefinitionId))
                return;

            writer.WritePropertyName(PROPERTY_ANNOTATIONS);
            writer.WriteStartObject();
            if (!string.IsNullOrEmpty(definition.DefinitionId))
            {
                writer.WritePropertyName(PROPERTY_ID);
                writer.WriteValue(definition.DefinitionId);
            }
            if (!string.IsNullOrEmpty(definition.Version))
            {
                writer.WritePropertyName(PROPERTY_VERSION);
                writer.WriteValue(definition.Version);
            }
            writer.WriteEndObject();
        }
    }
}
