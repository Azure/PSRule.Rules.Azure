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
    private const string PROPERTY_ALLOWED_VALUES = "allowedValues";
    private const string PROPERTY_MIN_LENGTH = "minLength";
    private const string PROPERTY_MAX_LENGTH = "maxLength";
    private const string PROPERTY_MIN_VALUE = "minValue";
    private const string PROPERTY_MAX_VALUE = "maxValue";
    private const string PROPERTY_VALIDATE = "validate";
    private const string PROPERTY_METADATA = "metadata";
    private const string PROPERTY_STRONG_TYPE = "strongType";
    private const string PROPERTY_RESOURCE_TYPE = "resourceType";
    private const string STRONG_TYPE_LOCATION = "location";

    private const string ISSUE_VALUE_CONSTRAINT = "PSRule.Rules.Azure.Template.ValueConstraint";
    private const string ISSUE_PARAMETER_STRONG_TYPE = "PSRule.Rules.Azure.Template.ParameterStrongType";
    private const string ISSUE_PARAMETER_UNSECURE_VALUE = "PSRule.Rules.Azure.Template.ParameterUnsecureValue";
    private const string ISSUE_PARAMETER_SECURE_ASSIGNMENT = "PSRule.Rules.Azure.Template.ParameterSecureAssignment";
    private const string ISSUE_OUTPUT_SECRET_VALUE = "PSRule.Rules.Azure.Template.OutputSecretValue";

    private const string REASON_VALUE_CONSTRAINT = "The value for '{0}' does not satisfy the '{1}' constraint.";

    private const string PROVIDER_NAMESPACE_RESOURCES = "Microsoft.Resources";
    private const string RESOURCE_TYPE_RESOURCE_GROUPS = "resourceGroups";

    private const string SLASH = "/";
    private const char API_VERSION_SEPARATOR = '@';

    private ISet<string> _Locations;

    internal void ValidateParameter(IValidationContext context, ParameterType type, string parameterName, JObject parameter, object value)
    {
        ParameterSecureValue(context, type, parameterName, parameter, value);
        ParameterStrongType(context, parameterName, parameter, value);
        ValueConstraints(context, parameterName, parameter, value);
    }

    internal void ValidateParameter(IValidationContext context, Policy.ParameterType type, string parameterName, JObject parameter, object value)
    {
        ParameterStrongType(context, parameterName, parameter, value);
    }

    internal void ValidateOutput(IValidationContext context, ParameterType type, string outputName, JObject output, object value)
    {
        OutputSecretValue(context, type, outputName, output, value);
        ValueConstraints(context, outputName, output, value);
    }

    private static void ValueConstraints(IValidationContext context, string name, JObject schema, object value)
    {
        if (schema == null)
            return;

        AllowedValues(context, name, schema, value);
        LengthConstraint(context, name, schema, value, PROPERTY_MIN_LENGTH, (actual, expected) => actual < expected);
        LengthConstraint(context, name, schema, value, PROPERTY_MAX_LENGTH, (actual, expected) => actual > expected);
        ValueConstraint(context, name, schema, value, PROPERTY_MIN_VALUE, (actual, expected) => actual < expected);
        ValueConstraint(context, name, schema, value, PROPERTY_MAX_VALUE, (actual, expected) => actual > expected);
        ValidateConstraint(context, name, schema, value);
    }

    private static void AllowedValues(IValidationContext context, string name, JObject schema, object value)
    {
        if (!schema.TryArrayProperty(PROPERTY_ALLOWED_VALUES, out var allowedValues))
            return;

        for (var i = 0; i < allowedValues.Count; i++)
        {
            if (EqualsValue(value, allowedValues[i]))
                return;
        }
        AddConstraintIssue(context, name, schema, PROPERTY_ALLOWED_VALUES);
    }

    private static void LengthConstraint(IValidationContext context, string name, JObject schema, object value, string propertyName, Func<long, long, bool> compare)
    {
        if (!schema.TryIntegerProperty(propertyName, out var constraint) || !constraint.HasValue || !TryLength(value, out var length))
            return;

        if (compare(length, constraint.Value))
            AddConstraintIssue(context, name, schema, propertyName);
    }

    private static void ValueConstraint(IValidationContext context, string name, JObject schema, object value, string propertyName, Func<long, long, bool> compare)
    {
        if (!schema.TryIntegerProperty(propertyName, out var constraint) || !constraint.HasValue || !ExpressionHelpers.TryLong(value, out var actual))
            return;

        if (compare(actual, constraint.Value))
            AddConstraintIssue(context, name, schema, propertyName);
    }

    private static void ValidateConstraint(IValidationContext context, string name, JObject schema, object value)
    {
        if (context is not ITemplateContext templateContext ||
            !schema.TryArrayProperty(PROPERTY_VALIDATE, out var validate) ||
            validate.Count == 0 ||
            !ExpressionHelpers.TryString(validate[0], out var expression) ||
            string.IsNullOrEmpty(expression))
            return;

        var fn = templateContext.BuildExpression(expression);
        if (templateContext.EvaluateExpression<object>(fn) is not LambdaExpressionFn lambda ||
            !lambda.TryInvokeBoolean(templateContext, value, out var result) ||
            result)
            return;

        if (TryValidateMessage(validate, out var message))
            context.AddValidationIssue(ISSUE_VALUE_CONSTRAINT, name, schema.Path, message);
        else
            AddConstraintIssue(context, name, schema, PROPERTY_VALIDATE);
    }

    private static bool TryValidateMessage(JArray validate, out string message)
    {
        message = null;
        return validate.Count > 1 && ExpressionHelpers.TryString(validate[1], out message) && !string.IsNullOrEmpty(message);
    }

    private static bool TryLength(object value, out long length)
    {
        if (ExpressionHelpers.TryString(value, out var s))
        {
            length = s.Length;
            return true;
        }
        if (ExpressionHelpers.TryArray(value, out var array))
        {
            length = array.Length;
            return true;
        }

        length = default;
        return false;
    }

    private static bool EqualsValue(object actual, JToken expected)
    {
        return actual is bool b && expected.Type == JTokenType.Boolean ? b == expected.Value<bool>() : ExpressionHelpers.Equal(actual, expected);
    }

    private static void AddConstraintIssue(IValidationContext context, string name, JObject schema, string constraint)
    {
        context.AddValidationIssue(ISSUE_VALUE_CONSTRAINT, name, schema.Path, REASON_VALUE_CONSTRAINT, name, constraint);
    }

    private static void OutputSecretValue(IValidationContext context, ParameterType type, string outputName, JObject output, object value)
    {
        // Ignore outputs with a secure type.
        if (IsSecureType(type))
            return;

        if (IsSecureValue(context, value) || (TryStringValue(value, out var s) && IsSecretReferenceOrKey(s)))
        {
            context.AddValidationIssue(ISSUE_OUTPUT_SECRET_VALUE, outputName, output.Path, ReasonStrings.OutputSecureAssignment, outputName);
        }
    }

    private static void ParameterSecureValue(IValidationContext context, ParameterType type, string parameterName, JObject parameter, object value)
    {
        if (!TryStringValue(value, out var s))
            return;

        // Parameter is marked as secure but value is not from a Key Vault, value exposed in parameters
        if (IsSecureType(type) && !IsSecretReferenceOrKey(s))
            context.AddValidationIssue(ISSUE_PARAMETER_UNSECURE_VALUE, parameterName, parameter.Path, ReasonStrings.UnsecureValue, parameterName);

        // Parameter is not marked as secure but value is loaded from Key Vault, value is exposed in template
        if (!IsSecureType(type) && IsSecretReferenceOrKey(s))
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

    private static bool IsSecureType(ParameterType type)
    {
        return type.Type is TypePrimitive.SecureString or TypePrimitive.SecureObject;
    }

    private void ParameterStrongType(IValidationContext context, string parameterName, JObject parameter, object value)
    {
        if (!TryStrongType(parameter, out var strongType))
            return;

        if (value == null || ExpressionHelpers.TryString(value, out var s) && string.IsNullOrEmpty(s))
            return;

        if (StringComparer.OrdinalIgnoreCase.Equals(STRONG_TYPE_LOCATION, strongType))
            IsValidLocation(context, parameter, parameterName, value);

        if (strongType.Contains(SLASH))
            IsResourceType(context, parameter, parameterName, strongType, value);
    }

    private static bool TryStrongType(JObject parameter, out string strongType)
    {
        strongType = null;
        if (!parameter.TryGetProperty(PROPERTY_METADATA, out JObject metadata))
            return false;

        if (metadata.TryGetProperty(PROPERTY_STRONG_TYPE, out JValue st) &&
            st.Value<string>() is string value)
            strongType = value;
        else if (metadata.TryGetProperty(PROPERTY_RESOURCE_TYPE, out JValue rt) &&
            rt.Value<string>() is string resourceType)
            strongType = ResourceTypeWithoutApiVersion(resourceType);

        return strongType != null;
    }

    private static string ResourceTypeWithoutApiVersion(string resourceType)
    {
        var index = resourceType.IndexOf(API_VERSION_SEPARATOR);
        return index < 0 ? resourceType : resourceType.Substring(0, index);
    }

    private void IsValidLocation(IValidationContext context, JObject parameter, string parameterName, object value)
    {
        if (!ExpressionHelpers.TryString(value, out var location))
        {
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotString, value?.ToString() ?? string.Empty, parameterName);
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
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotString, value?.ToString() ?? string.Empty, parameterName);
            return;
        }

        if (!ResourceHelper.IsResourceType(resourceId, resourceType))
            context.AddValidationIssue(ISSUE_PARAMETER_STRONG_TYPE, parameterName, parameter.Path, ReasonStrings.NotResourceType, resourceId, parameterName, resourceType);
    }
}
