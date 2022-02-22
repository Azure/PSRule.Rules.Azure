// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class TemplateValidator
    {
        private const string PROPERTY_METADATA = "metadata";
        private const string PROPERTY_STRONGTYPE = "strongType";
        private const string STRONGTYPE_LOCATION = "location";

        private const string ISSUE_PARAMETER_STRONGTYPE = "PSRule.Rules.Azure.Template.ParameterStrongType";

        private const string PROVIDERNAMESPACE_RESOURCES = "Microsoft.Resources";
        private const string RESOURCETYPE_RESOURCEGROUPS = "resourceGroups";

        private const string SLASH = "/";

        private ISet<string> _Locations;

        internal void ValidateParameter(ITemplateContext context, string parameterName, JObject parameter, object value)
        {
            ParameterStrongType(context, parameterName, parameter, value);
        }

        private void ParameterStrongType(ITemplateContext context, string parameterName, JObject parameter, object value)
        {
            if (!TryStrongType(parameter, out var strongType))
                return;

            if (StringComparer.OrdinalIgnoreCase.Equals(STRONGTYPE_LOCATION, strongType))
                IsValidLocation(context, parameterName, value);

            if (strongType.Contains(SLASH))
                IsResourceType(context, parameterName, strongType, value);
        }

        private static bool TryStrongType(JObject parameter, out string strongType)
        {
            strongType = null;
            if (parameter.TryGetProperty(PROPERTY_METADATA, out JObject metadata) &&
                metadata.TryGetProperty(PROPERTY_STRONGTYPE, out JValue st) &&
                st.Value<string>() is string value)
                strongType = value;

            return strongType != null;
        }

        private void IsValidLocation(ITemplateContext context, string parameterName, object value)
        {
            if (!ExpressionHelpers.TryString(value, out var location))
            {
                context.AddValidationIssue(ISSUE_PARAMETER_STRONGTYPE, parameterName, ReasonStrings.NotString, value.ToString(), parameterName);
                return;
            }

            var validLocations = GetLocations(context);
            if (validLocations == null)
                return;

            if (!validLocations.Contains(location))
                context.AddValidationIssue(ISSUE_PARAMETER_STRONGTYPE, parameterName, ReasonStrings.InvalidLocation, location, parameterName);
        }

        private ISet<string> GetLocations(ITemplateContext context)
        {
            if (_Locations == null)
            {
                var resourceType = context.GetResourceType(PROVIDERNAMESPACE_RESOURCES, RESOURCETYPE_RESOURCEGROUPS);
                if (resourceType == null || resourceType.Length == 0)
                    return null;

                _Locations = new HashSet<string>(resourceType[0].Locations, LocationHelper.Comparer);
            }
            return _Locations;
        }

        private static void IsResourceType(ITemplateContext context, string parameterName, string resourceType, object value)
        {
            if (!ExpressionHelpers.TryString(value, out var resourceId))
            {
                context.AddValidationIssue(ISSUE_PARAMETER_STRONGTYPE, parameterName, ReasonStrings.NotString, value.ToString(), parameterName);
                return;
            }

            if (!ResourceHelper.IsResourceType(resourceId, resourceType))
                context.AddValidationIssue(ISSUE_PARAMETER_STRONGTYPE, parameterName, ReasonStrings.NotResourceType, resourceId, parameterName, resourceType);
        }
    }
}
