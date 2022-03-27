// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
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
        private const string FIELD_EQUALS = "equals";
        private const string PROPERTY_DISPLAYNAME = "displayName";
        private const string PROPERTY_DESCRIPTION = "description";
        private const string PROPERTY_DEPLOYMENT = "deployment";
        private const string PROPERTY_VALUE = "value";
        private const char SLASH = '/';

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
            public JObject Deployment { get; }
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

            private void ExpandPolicyRule(JToken policyRule)
            {
                if (policyRule.Type == JTokenType.Object)
                {
                    var hasFieldType = false;
                    foreach (var child in policyRule.Children<JProperty>())
                    {
                        // Expand field aliases
                        if (child.Name.Equals(PROPERTY_FIELD, StringComparison.OrdinalIgnoreCase))
                        {
                            var field = child.Value.Value<string>();
                            if (field.Equals(PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase))
                                hasFieldType = true;

                            var aliasPath = ResolvePolicyAliasPath(field);
                            if (aliasPath != null)
                                policyRule[child.Name] = aliasPath;
                        }

                        else if (hasFieldType && child.Name.Equals(FIELD_EQUALS, StringComparison.OrdinalIgnoreCase))
                        {
                            var field = child.Value.Value<string>();
                            if (field.CountCharacterOccurrences(SLASH) == 1)
                            {
                                var contents = field.Split(SLASH);
                                var providerNamespace = contents[0];
                                var resourceType = contents[1];
                                _PolicyAliasProviderHelper.SetPolicyRuleType(providerNamespace, resourceType);
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