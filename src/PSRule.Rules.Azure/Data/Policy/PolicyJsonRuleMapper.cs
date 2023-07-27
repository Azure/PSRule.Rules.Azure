// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
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
        private const string PROPERTY_DISPLAYNAME = "displayName";
        private const string PROPERTY_SPEC = "spec";
        private const string PROPERTY_RECOMMEND = "recommend";
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_WHERE = "where";
        private const string PROPERTY_WITH = "with";
        private const string PROPERTY_TYPE = "type";
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
            if (definition.DisplayName != null)
            {
                writer.WritePropertyName(PROPERTY_DISPLAYNAME);
                writer.WriteValue(definition.DisplayName);
            }
            WriteTags(writer, definition);
            WriteAnnotations(writer, definition);
            writer.WriteEndObject();

            // Spec
            writer.WritePropertyName(PROPERTY_SPEC);
            writer.WriteStartObject();
            writer.WritePropertyName(PROPERTY_RECOMMEND);
            writer.WriteValue(definition.Description);
            WriteType(writer, serializer, definition);
            WriteWith(writer, serializer, definition);
            WriteWhere(writer, serializer, definition);
            WriteCondition(writer, serializer, definition);
            writer.WriteEndObject();

            writer.WriteEndObject();
        }

        /// <summary>
        /// Emit type pre-conditions.
        /// </summary>
        private static void WriteType(JsonWriter writer, JsonSerializer serializer, PolicyDefinition definition)
        {
            if (definition.Types == null || definition.Types.Count == 0)
                return;

            var types = new HashSet<string>(definition.Types, StringComparer.OrdinalIgnoreCase);
            writer.WritePropertyName(PROPERTY_TYPE);
            serializer.Serialize(writer, types);
        }

        /// <summary>
        /// Emit sub-selector pre-condition.
        /// </summary>
        private static void WriteWhere(JsonWriter writer, JsonSerializer serializer, PolicyDefinition definition)
        {
            if (definition.Where == null)
                return;

            writer.WritePropertyName(PROPERTY_WHERE);
            serializer.Serialize(writer, definition.Where);
        }

        /// <summary>
        /// Emit selector pre-condition.
        /// </summary>
        private static void WriteWith(JsonWriter writer, JsonSerializer serializer, PolicyDefinition definition)
        {
            if (definition.With == null)
                return;

            writer.WritePropertyName(PROPERTY_WITH);
            serializer.Serialize(writer, definition.With);
        }

        private static void WriteCondition(JsonWriter writer, JsonSerializer serializer, PolicyDefinition definition)
        {
            writer.WritePropertyName(PROPERTY_CONDITION);
            serializer.Serialize(writer, definition.Condition);
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
