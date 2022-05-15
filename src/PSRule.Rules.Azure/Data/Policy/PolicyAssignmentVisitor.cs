// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Policy
{
    internal abstract class PolicyAssignmentVisitor
    {
        private const string PROPERTY_PARAMETERS = "parameters";
        private const string PROPERTY_DEFINTIONS = "policyDefinitions";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_POLICYRULE = "policyRule";
        private const string PROPERTY_CONDITION = "if";
        private const string PROPERTY_EFFECT_BLOCK = "then";
        private const string PROPERTY_EFFECT = "effect";
        private const string DISABLED_EFFECT = "disabled";
        private const string PROPERTY_DETAILS = "details";
        private const string PROPERTY_EXISTENCE_CONDITION = "existenceCondition";
        private const string PROPERTY_FIELD = "field";
        private const string PROPERTY_POLICYDEFINITIONID = "policyDefinitionId";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_DEFAULTVALUE = "defaultValue";
        private const string PROPERTY_ALL_OF = "allOf";
        private const string PROPERTY_ANY_OF = "anyOf";
        private const string FIELD_EQUALS = "equals";
        private const string FIELD_NOTEQUALS = "notEquals";
        private const string FIELD_GREATER = "greater";
        private const string FIELD_GREATEROREQUALS = "greaterOrEquals";
        private const string FIELD_LESS = "less";
        private const string FIELD_LESSOREQUALS = "lessOrEquals";
        private const string PROPERTY_DISPLAYNAME = "displayName";
        private const string PROPERTY_DESCRIPTION = "description";
        private const string PROPERTY_DEPLOYMENT = "deployment";
        private const string PROPERTY_VALUE = "value";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_WHERE = "where";
        private const string COLLECTION_ALIAS = "[*]";
        private const string AND_CLAUSE = "&&";
        private const string OR_CLAUSE = "||";
        private const char SLASH = '/';
        private const char GROUP_OPEN = '(';
        private const char GROUP_CLOSE = ')';

        public sealed class PolicyAssignmentContext : ITemplateContext
        {
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly PolicyAliasProviderHelper _PolicyAliasProviderHelper;
            internal string AssignmentFile { get; private set; }
            private readonly IList<PolicyDefinition> _Definitions;
            private readonly IDictionary<string, PolicyDefinition> _DefinitionIds;
            internal readonly PipelineContext Pipeline;
            public TemplateVisitor.TemplateContext.CopyIndexStore CopyIndex { get; }
            public DeploymentValue Deployment { get; }
            public string TemplateFile { get; }
            public string ParameterFile { get; }
            public ResourceGroupOption ResourceGroup { get; }
            public SubscriptionOption Subscription { get; }
            public TenantOption Tenant { get; }
            public ManagementGroupOption ManagementGroup { get; }
            private readonly TemplateValidator _Validator;
            private readonly IDictionary<string, JToken> _ParameterAssignments;
            internal string DefinitionId { get; private set; }

            internal PolicyAssignmentContext(PipelineContext context)
            {
                _ExpressionFactory = new ExpressionFactory();
                _ExpressionBuilder = new ExpressionBuilder(_ExpressionFactory);
                _PolicyAliasProviderHelper = new PolicyAliasProviderHelper();
                _Definitions = new List<PolicyDefinition>();
                _DefinitionIds = new Dictionary<string, PolicyDefinition>(StringComparer.OrdinalIgnoreCase);
                _Validator = new TemplateValidator();
                _ParameterAssignments = new Dictionary<string, JToken>();
                Pipeline = context;

                ResourceGroup = ResourceGroupOption.Default;
                if (context?.Option?.Configuration?.ResourceGroup != null)
                    ResourceGroup = context?.Option?.Configuration?.ResourceGroup;

                Subscription = SubscriptionOption.Default;
                if (context?.Option?.Configuration?.Subscription != null)
                    Subscription = context?.Option?.Configuration?.Subscription;

                Tenant = TenantOption.Default;
                if (context?.Option?.Configuration?.Tenant != null)
                    Tenant = context?.Option?.Configuration?.Tenant;

                ManagementGroup = ManagementGroupOption.Default;
                if (context?.Option?.Configuration?.ManagementGroup != null)
                    ManagementGroup = context?.Option?.Configuration?.ManagementGroup;
            }

            public ExpressionFnOuter BuildExpression(string expression)
            {
                return _ExpressionBuilder.Build(expression);
            }

            public bool TryGetResource(string resourceId, out IResourceValue resource)
            {
                resource = null;
                return false;
            }

            internal bool TryParameterAssignment(string parameterName, out JToken value)
            {
                return _ParameterAssignments.TryGetValue(parameterName, out value);
            }

            internal void AddParameterAssignment(string name, JToken value)
            {
                _ParameterAssignments.Add(name, value);
            }

            public void AddDefinition(JObject definition, string definitionId)
            {

                if (definition.TryObjectProperty(PROPERTY_PROPERTIES, out var properties))
                {
                    properties.TryStringProperty(PROPERTY_DISPLAYNAME, out var displayName);
                    properties.TryStringProperty(PROPERTY_DESCRIPTION, out var description);

                    var policyDefinition = new PolicyDefinition(definitionId, displayName, description, definition);

                    // Set parameters
                    if (properties.TryObjectProperty(PROPERTY_PARAMETERS, out var parameters))
                    {
                        foreach (var parameter in parameters.Properties())
                            SetDefinitionParameterAssignment(policyDefinition, parameter);

                        _DefinitionIds.Add(definitionId, policyDefinition);
                    }

                    // Modify policy rule
                    if (properties.TryObjectProperty(PROPERTY_POLICYRULE, out var policyRule))
                    {
                        RemovePolicyRuleDeployment(policyRule);
                        ExpandPolicyRule(policyRule);
                        MergePolicyRuleConditions(policyRule);
                        if (policyRule.TryObjectProperty(PROPERTY_CONDITION, out var condition))
                            policyDefinition.Condition = condition;

                        if (TryPolicyRuleEffect(policyRule, out var effect))
                            policyDefinition.Effect = effect;
                    }

                    // Skip adding definitions with disabled effect
                    if (!policyDefinition.Effect.Equals(DISABLED_EFFECT, StringComparison.OrdinalIgnoreCase))
                        _Definitions.Add(policyDefinition);
                }
            }

            private void SetDefinitionParameterAssignment(PolicyDefinition definition, JProperty parameter)
            {
                var type = GetParameterType(parameter.Value);
                var parameterName = parameter.Name;
                var parameterValue = parameter.Value as JObject;

                if (TryParameterAssignment(parameterName, out var parameterAssignmentValue))
                {
                    var assignmentValue = parameterAssignmentValue[PROPERTY_VALUE];
                    CheckParameter(parameterName, parameterValue, type, assignmentValue);
                    AddParameterFromType(definition, parameterName, type, assignmentValue);
                }
                else
                {
                    if (parameterValue.ContainsKey(PROPERTY_DEFAULTVALUE))
                    {
                        var defaultValue = TemplateVisitor.ExpandPropertyToken(this, parameterValue[PROPERTY_DEFAULTVALUE]);
                        CheckParameter(parameterName, parameterValue, type, defaultValue);
                        AddParameterFromType(definition, parameterName, type, defaultValue);
                    }
                }
            }

            private static void MergePolicyRuleConditions(JObject policyRule)
            {
                if (policyRule.TryObjectProperty(PROPERTY_CONDITION, out var condition)
                    && policyRule.TryObjectProperty(PROPERTY_EFFECT_BLOCK, out var effectBlock)
                    && effectBlock.TryObjectProperty(PROPERTY_DETAILS, out var details)
                    && details.TryStringProperty(PROPERTY_TYPE, out var detailsType)
                    && details.TryObjectProperty(PROPERTY_EXISTENCE_CONDITION, out var existenceCondition))
                {
                    var existenceConditionExpression = new JArray();
                    var typeExpression = new JObject {
                        { PROPERTY_FIELD, PROPERTY_TYPE },
                        { FIELD_EQUALS, detailsType }
                    };
                    existenceConditionExpression.Add(typeExpression);
                    existenceConditionExpression.Add(existenceCondition);

                    var existenceConditionAllOfExpression = new JObject
                    {
                        { PROPERTY_ALL_OF, existenceConditionExpression }
                    };

                    var mergedConditions = new JArray
                    {
                        condition,
                        existenceConditionAllOfExpression
                    };

                    policyRule[PROPERTY_CONDITION] = new JObject {
                        { PROPERTY_ALL_OF, mergedConditions }
                    };
                }
            }

            private static bool TryPolicyRuleEffect(JObject policyRule, out string effect)
            {
                effect = string.Empty;
                return policyRule.TryObjectProperty(PROPERTY_EFFECT_BLOCK, out var effectBlock)
                    && effectBlock.TryStringProperty(PROPERTY_EFFECT, out effect);
            }

            private static void RemovePolicyRuleDeployment(JObject policyRule)
            {
                if (policyRule.TryObjectProperty(PROPERTY_EFFECT_BLOCK, out var effectBlock)
                    && effectBlock.TryObjectProperty(PROPERTY_DETAILS, out var details)
                    && details.TryObjectProperty(PROPERTY_DEPLOYMENT, out _))
                {
                    details.Remove(PROPERTY_DEPLOYMENT);
                    policyRule[PROPERTY_EFFECT_BLOCK][PROPERTY_DETAILS] = details;
                }
            }

            private static string ExpressionToObjectPathComparisonOperator(string expression) => expression switch
            {
                FIELD_EQUALS => "==",
                FIELD_NOTEQUALS => "!=",
                FIELD_GREATER => ">",
                FIELD_GREATEROREQUALS => ">=",
                FIELD_LESS => "<",
                FIELD_LESSOREQUALS => "<=",
                _ => null
            };

            private void SetPolicyRuleType(string type)
            {
                if (type.CountCharacterOccurrences(SLASH) > 0)
                {
                    var contents = type.Split(new char[] { SLASH }, count: 2);
                    var providerNamespace = contents[0];
                    var resourceType = contents[1];
                    _PolicyAliasProviderHelper.SetPolicyRuleType(providerNamespace, resourceType);
                }
            }

            private string GetFieldObjectPathArrayFilter(JObject obj)
            {
                if (obj.TryStringProperty(PROPERTY_FIELD, out var fieldProperty))
                {
                    var subProperty = string.Empty;

                    if (fieldProperty.Equals(PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase)
                        && obj.TryStringProperty(FIELD_EQUALS, out var fieldType))
                    {
                        subProperty = $".{PROPERTY_TYPE}";
                        SetPolicyRuleType(fieldType);
                    }

                    var fieldAliasPath = ResolvePolicyAliasPath(fieldProperty);
                    if (fieldAliasPath != null)
                    {
                        var splitAliasPath = fieldAliasPath.Split(new string[] { COLLECTION_ALIAS }, StringSplitOptions.None);
                        subProperty = splitAliasPath[1];
                    }

                    var comparisonExpression = obj
                        .Children<JProperty>()
                        .FirstOrDefault(prop => !prop.Name.Equals(PROPERTY_FIELD, StringComparison.OrdinalIgnoreCase));

                    if (comparisonExpression != null)
                    {
                        var objectPathComparisonOperator = ExpressionToObjectPathComparisonOperator(comparisonExpression.Name);

                        if (objectPathComparisonOperator != null)
                        {
                            return FormatObjectPathArrayFilter(
                                subProperty,
                                objectPathComparisonOperator,
                                comparisonExpression.Value);
                        }
                    }
                }
                return null;
            }

            private void ExpressionToObjectPathArrayFilter(JArray expression, string clause, StringBuilder objectPath)
            {
                var clauseSeparator = string.Empty;
                foreach (var obj in expression.Children<JObject>())
                {
                    var filter = GetFieldObjectPathArrayFilter(obj);
                    if (filter != null)
                    {
                        objectPath.Append(clauseSeparator);
                        objectPath.Append(filter);
                        clauseSeparator = $" {clause} ";
                    }

                    else if (obj.TryArrayProperty(PROPERTY_ALL_OF, out var allOfExpression))
                    {
                        objectPath.Append($" {clause} ");
                        objectPath.Append(GROUP_OPEN);
                        ExpressionToObjectPathArrayFilter(allOfExpression, AND_CLAUSE, objectPath);
                        objectPath.Append(GROUP_CLOSE);
                    }

                    else if (obj.TryArrayProperty(PROPERTY_ANY_OF, out var anyOfExpression))
                    {
                        objectPath.Append($" {clause} ");
                        objectPath.Append(GROUP_OPEN);
                        ExpressionToObjectPathArrayFilter(anyOfExpression, OR_CLAUSE, objectPath);
                        objectPath.Append(GROUP_CLOSE);
                    }
                }
            }

            private static string FormatObjectPathArrayExpression(string array, string filter)
            {
                return string.Format(
                    Thread.CurrentThread.CurrentCulture,
                    "{0}[?{1}]",
                    array,
                    filter);
            }

            private static string FormatObjectPathArrayFilter(string subProperty, string comparisonOperator, JToken value)
            {
                // Surround right hand side with quotes if string
                var normalizedFormattedExpression = value.Type == JTokenType.String
                    ? "@{0} {1} '{2}'"
                    : "@{0} {1} {2}";

                return string.Format(
                    Thread.CurrentThread.CurrentCulture,
                    normalizedFormattedExpression,
                    subProperty,
                    comparisonOperator,
                    value);
            }

            private void ExpandPolicyRule(JToken policyRule)
            {
                if (policyRule.Type == JTokenType.Object)
                {
                    var hasFieldType = false;
                    var hasFieldCount = false;

                    foreach (var child in policyRule.Children<JProperty>().ToList())
                    {
                        // Expand field aliases
                        if (child.Name.Equals(PROPERTY_FIELD, StringComparison.OrdinalIgnoreCase))
                        {
                            if (child.Value.Type == JTokenType.String)
                            {
                                var field = child.Value.Value<string>();
                                if (field.Equals(PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase))
                                    hasFieldType = true;

                                var aliasPath = ResolvePolicyAliasPath(field);
                                if (aliasPath != null)
                                    policyRule[child.Name] = aliasPath;
                            }
                        }

                        // Set policy rule type
                        else if (hasFieldType && child.Name.Equals(FIELD_EQUALS, StringComparison.OrdinalIgnoreCase))
                        {
                            if (child.Value.Type == JTokenType.String)
                            {
                                var field = child.Value.Value<string>();
                                SetPolicyRuleType(field);
                            }
                        }

                        // Replace equals with count if field count expression is currently being visited
                        else if (hasFieldCount && child.Name.Equals(FIELD_EQUALS, StringComparison.OrdinalIgnoreCase))
                        {
                            policyRule[FIELD_EQUALS].Parent.Remove();
                            policyRule[PROPERTY_COUNT] = child.Value;
                        }

                        // Expand field count expressions
                        else if (child.Name.Equals(PROPERTY_COUNT, StringComparison.OrdinalIgnoreCase))
                        {
                            hasFieldCount = true;

                            if (child.Value.Type == JTokenType.Object)
                            {
                                var countObject = child.Value.ToObject<JObject>();

                                if (countObject.TryStringProperty(PROPERTY_FIELD, out var outerFieldAlias))
                                {
                                    var outerFieldAliasPath = ResolvePolicyAliasPath(outerFieldAlias);

                                    if (outerFieldAliasPath != null)
                                    {
                                        if (countObject.TryObjectProperty(PROPERTY_WHERE, out var whereExpression))
                                        {
                                            // field in where expression
                                            var fieldFilter = GetFieldObjectPathArrayFilter(whereExpression);
                                            if (fieldFilter != null)
                                            {
                                                var splitAliasPath = outerFieldAliasPath.Split(new string[] { COLLECTION_ALIAS }, StringSplitOptions.None);
                                                policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], fieldFilter);
                                                policyRule[PROPERTY_COUNT].Parent.Remove();
                                            }

                                            // nested allOf in where expression
                                            else if (whereExpression.TryArrayProperty(PROPERTY_ALL_OF, out var allofExpression))
                                            {
                                                var splitAliasPath = outerFieldAliasPath.Split(new string[] { COLLECTION_ALIAS }, StringSplitOptions.None);
                                                var filter = new StringBuilder();
                                                ExpressionToObjectPathArrayFilter(allofExpression, AND_CLAUSE, filter);
                                                policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], filter.ToString());
                                                policyRule[PROPERTY_COUNT].Parent.Remove();
                                            }

                                            // nested anyOf in where expression
                                            else if (whereExpression.TryArrayProperty(PROPERTY_ANY_OF, out var anyOfExpression))
                                            {
                                                var splitAliasPath = outerFieldAliasPath.Split(new string[] { COLLECTION_ALIAS }, StringSplitOptions.None);
                                                var filter = new StringBuilder();
                                                ExpressionToObjectPathArrayFilter(anyOfExpression, OR_CLAUSE, filter);
                                                policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], filter.ToString());
                                                policyRule[PROPERTY_COUNT].Parent.Remove();
                                            }
                                        }

                                        // Single field in count expression
                                        else
                                        {
                                            policyRule[PROPERTY_FIELD] = outerFieldAliasPath;
                                            policyRule[PROPERTY_COUNT].Parent.Remove();
                                        }
                                    }
                                }
                            }
                        }

                        // Expand string expressions
                        else if (child.Value.Type == JTokenType.String)
                        {
                            var expression = TemplateVisitor.ExpandPropertyToken(this, child.Value);
                            policyRule[child.Name] = expression;
                        }

                        // Recurse any objects or arrays
                        else if (child.Value.Type == JTokenType.Object || child.Value.Type == JTokenType.Array)
                            ExpandPolicyRule(child.Value);
                    }
                }

                // Recurse arrays
                else if (policyRule.Type == JTokenType.Array)
                    foreach (var child in policyRule.Children())
                        ExpandPolicyRule(child);
            }

            private static ParameterType GetParameterType(JToken parameter)
            {
                return parameter[PROPERTY_TYPE].ToObject<ParameterType>();
            }

            private void CheckParameter(string parameterName, JObject parameter, ParameterType type, JToken value)
            {
                if (type == ParameterType.String && !string.IsNullOrEmpty(value.Value<string>()))
                    _Validator.ValidateParameter(this, parameterName, parameter, value);
            }

            private static void AddParameterFromType(PolicyDefinition definition, string parameterName, ParameterType type, JToken value)
            {
                switch (type)
                {
                    case ParameterType.Boolean:
                        definition.AddParameter(new LazyParameter<bool>(parameterName, type, value));
                        break;
                    case ParameterType.Integer:
                        definition.AddParameter(new LazyParameter<long>(parameterName, type, value));
                        break;
                    case ParameterType.String:
                        definition.AddParameter(new LazyParameter<string>(parameterName, type, value));
                        break;
                    case ParameterType.Array:
                        definition.AddParameter(new LazyParameter<JArray>(parameterName, type, value));
                        break;
                    case ParameterType.Object:
                        definition.AddParameter(new LazyParameter<JObject>(parameterName, type, value));
                        break;
                    case ParameterType.Float:
                        definition.AddParameter(new LazyParameter<float>(parameterName, type, value));
                        break;
                    case ParameterType.DateTime:
                        definition.AddParameter(new LazyParameter<DateTime>(parameterName, type, value));
                        break;
                }
            }

            public PolicyDefinition[] GetDefinitions()
            {
                return _Definitions.ToArray();
            }

            public string ResolvePolicyAliasPath(string aliasName)
            {
                return !string.IsNullOrEmpty(aliasName)
                    && _PolicyAliasProviderHelper.ResolvePolicyAliasPath(aliasName, out var aliasPath)
                    ? aliasPath
                    : null;
            }

            internal void SetSource(string assignmentFile)
            {
                AssignmentFile = assignmentFile;
            }

            public CloudEnvironment GetEnvironment()
            {
                return null;
            }

            public ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
            {
                return null;
            }

            public bool TryVariable(string variableName, out object value)
            {
                value = null;
                return false;
            }

            public void WriteDebug(string message, params object[] args)
            {
                if (Pipeline == null || Pipeline.Writer == null || string.IsNullOrEmpty(message) || !Pipeline.Writer.ShouldWriteDebug())
                    return;

                Pipeline.Writer.WriteDebug(message, args);
            }

            public void AddValidationIssue(string issueId, string name, string message, params object[] args)
            {
                return;
            }

            public bool TryParameter(string parameterName, out object value)
            {
                value = null;

                if (_DefinitionIds.TryGetValue(DefinitionId, out var definition)
                    && definition.TryParameter(parameterName, out var parameterValue))
                {
                    value = parameterValue.GetValue(this);
                    return true;
                }

                return false;
            }

            internal void SetDefinitionId(string definitionId)
            {
                DefinitionId = definitionId;
            }
        }

        internal void Visit(PolicyAssignmentContext context, JObject assignment)
        {
            Assignment(context, assignment);
        }

        protected virtual void VisitAssignmentParameters(PolicyAssignmentContext context, JObject parameters)
        {
            if (parameters == null || parameters.Count == 0)
                return;

            foreach (var parameter in parameters.Children<JProperty>())
                context.AddParameterAssignment(parameter.Name, parameter.Value);
        }

        protected virtual void VisitDefinitions(PolicyAssignmentContext context, IEnumerable<JObject> definitions)
        {
            if (definitions == null || !definitions.Any())
                return;

            foreach (var definition in definitions)
            {
                if (definition.TryStringProperty(PROPERTY_POLICYDEFINITIONID, out var definitionId))
                {
                    context.SetDefinitionId(definitionId);
                    context.AddDefinition(definition, definitionId);
                }
            }
        }

        protected virtual void Assignment(PolicyAssignmentContext context, JObject assignment)
        {
            // Process assignment sections

            // Assignment Properties
            if (assignment.TryObjectProperty(PROPERTY_PROPERTIES, out var properties))
            {
                // Assignment Parameters
                if (properties.TryObjectProperty(PROPERTY_PARAMETERS, out var parameters))
                    VisitAssignmentParameters(context, parameters);
            }

            // Assignment Defintions
            if (assignment.TryArrayProperty(PROPERTY_DEFINTIONS, out var definitions))
                VisitDefinitions(context, definitions.Values<JObject>());
        }
    }

    internal sealed class PolicyAssignmentDataExportVisitor : PolicyAssignmentVisitor
    {

    }
}