// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm;
using PSRule.Rules.Azure.Arm.Deployments;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template;

internal sealed class TemplateValidator
{
    private const string PROPERTY_METADATA = "metadata";
    private const string PROPERTY_STRONG_TYPE = "strongType";
    private const string STRONG_TYPE_LOCATION = "location";

    private const string ISSUE_PARAMETER_STRONG_TYPE = "PSRule.Rules.Azure.Template.ParameterStrongType";
    private const string ISSUE_PARAMETER_UNSECURE_VALUE = "PSRule.Rules.Azure.Template.ParameterUnsecureValue";
    private const string ISSUE_PARAMETER_SECURE_ASSIGNMENT = "PSRule.Rules.Azure.Template.ParameterSecureAssignment";
    private const string ISSUE_OUTPUT_SECRET_VALUE = "PSRule.Rules.Azure.Template.OutputSecretValue";

    private const string PROVIDER_NAMESPACE_RESOURCES = "Microsoft.Resources";
    private const string RESOURCE_TYPE_RESOURCE_GROUPS = "resourceGroups";

    private const string SLASH = "/";

    private ISet<string> _Locations;

    internal void ValidateParameter(IValidationContext context, ParameterType type, string parameterName, JObject parameter, object value)
    {
        ParameterSecureValue(context, type, parameterName, parameter, value);
        ParameterStrongType(context, parameterName, parameter, value);
    }

    internal void ValidateParameter(IValidationContext context, Policy.ParameterType type, string parameterName, JObject parameter, object value)
    {
        ParameterStrongType(context, parameterName, parameter, value);
    }

    internal void ValidateOutput(IValidationContext context, ParameterType type, string outputName, JObject output, object value)
    {
        OutputSecretValue(context, type, outputName, output, value);
    }

    private static void OutputSecretValue(IValidationContext context, ParameterType type, string outputName, JObject output, object value)
    {
        if (IsSecureValue(context, value) ||
            (TryStringValue(value, out var s) && IsSecretReferenceOrKey(s)))
            context.AddValidationIssue(ISSUE_OUTPUT_SECRET_VALUE, outputName, output.Path, ReasonStrings.OutputSecureAssignment, outputName);
    }

    private static void ParameterSecureValue(IValidationContext context, ParameterType type, string parameterName, JObject parameter, object value)
    {
        if (!TryStringValue(value, out var s))
            return;

        // Parameter is marked as secure but value is not from a Key Vault, value exposed in parameters
        if (IsSecureParameter(type, s) && !IsSecretReferenceOrKey(s))
            context.AddValidationIssue(ISSUE_PARAMETER_UNSECURE_VALUE, parameterName, parameter.Path, ReasonStrings.UnsecureValue, parameterName);

        // Parameter is not marked as secure but value is loaded from Key Vault, value is exposed in template
        if (!IsSecureParameter(type, s) && IsSecretReferenceOrKey(s))
            context.AddValidationIssue(ISSUE_PARAMETER_SECURE_ASSIGNMENT, parameterName, parameter.Path, ReasonStrings.ParameterSecureAssignment, parameterName);
    }

    private static bool IsSecretReferenceOrKey(string s)
    {
        return s.StartsWith("{{SecretReference", StringComparison.OrdinalIgnoreCase) ||
            s.StartsWith("{{SecretList", StringComparison.OrdinalIgnoreCase) ||
            s.Equals("{{Secret}}", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsSecureValue(IValidationContext context, object value)
    {
        return value != null && context.IsSecureValue(value);
    }

    private static bool TryStringValue(object o, out string value)
    {
        return ExpressionHelpers.TryString(o, out value) && !string.IsNullOrEmpty(value);
    }

    private static bool IsSecureParameter(ParameterType type, string s)
    {
        return type.Type is TypePrimitive.SecureString or TypePrimitive.SecureObject;
    }

    private void ParameterStrongType(IValidationContext context, string parameterName, JObject parameter, object value)
    {
        if (!TryStrongType(parameter, out var strongType))
            return;

        if (StringComparer.OrdinalIgnoreCase.Equals(STRONG_TYPE_LOCATION, strongType))
            IsValidLocation(context, parameter, parameterName, value);

        if (strongType.Contains(SLASH))
            IsResourceType(context, parameter, parameterName, strongType, value);
    }

    private static bool TryStrongType(JObject parameter, out string strongType)
    {
        strongType = null;
        if (parameter.TryGetProperty(PROPERTY_METADATA, out JObject metadata) &&
            metadata.TryGetProperty(PROPERTY_STRONG_TYPE, out JValue st) &&
            st.Value<string>() is string value)
            strongType = value;

        return strongType != null;
    }

    private void IsValidLocation(IValidationContext context, JObject parameter, string parameterName, object value)
    {
        if (!ExpressionHelpers.TryString(value, out var location))
        {
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotString, value.ToString(), parameterName);
            return;
        }

        var validLocations = GetLocations(context);
        if (validLocations == null)
            return;

        if (!validLocations.Contains(location))
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.InvalidLocation, location, parameterName);
    }

    private ISet<string> GetLocations(IValidationContext context)
    {
        if (_Locations == null)
        {
            var resourceType = context.GetResourceType(PROVIDER_NAMESPACE_RESOURCES, RESOURCE_TYPE_RESOURCE_GROUPS);
            if (resourceType == null || resourceType.Length == 0)
                return null;

            _Locations = new HashSet<string>(resourceType[0].Locations, LocationHelper.Comparer);
        }
        return _Locations;
    }

    private static void IsResourceType(IValidationContext context, JObject parameter, string parameterName, string resourceType, object value)
    {
        if (!ExpressionHelpers.TryString(value, out var resourceId))
        {
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotString, value.ToString(), parameterName);
            return;
        }

        if (!ResourceHelper.IsResourceType(resourceId, resourceType))
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotResourceType, resourceId, parameterName, resourceType);
    }
}
