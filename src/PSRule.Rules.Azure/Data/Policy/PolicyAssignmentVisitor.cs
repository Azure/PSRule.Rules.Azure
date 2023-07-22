// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Management.Automation;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Policy
{
    /// <summary>
    /// This visitor processes each assignment to convert the assignment in to one or mny rules.
    /// </summary>
    internal abstract class PolicyAssignmentVisitor : ResourceManagerVisitor
    {
        private const string PROPERTY_POLICYASSIGNMENTID = "policyAssignmentId";
        private const string PROPERTY_PARAMETERS = "parameters";
        private const string PROPERTY_POLICYDEFINITIONS = "policyDefinitions";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_POLICYRULE = "policyRule";
        private const string PROPERTY_MODE = "mode";
        private const string PROPERTY_IF = "if";
        private const string PROPERTY_THEN = "then";
        private const string PROPERTY_EFFECT = "effect";
        private const string PROPERTY_DETAILS = "details";
        private const string PROPERTY_EXISTENCECONDITION = "existenceCondition";
        private const string PROPERTY_FIELD = "field";
        private const string PROPERTY_POLICYDEFINITIONID = "policyDefinitionId";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_DEFAULTVALUE = "defaultValue";
        private const string PROPERTY_ALLOF = "allOf";
        private const string PROPERTY_ANYOF = "anyOf";
        private const string PROPERTY_EQUALS = "equals";
        private const string PROPERTY_NOTEQUALS = "notEquals";
        private const string PROPERTY_GREATER = "greater";
        private const string PROPERTY_GREATEROREQUALS = "greaterOrEquals";
        private const string PROPERTY_LESS = "less";
        private const string PROPERTY_LESSOREQUALS = "lessOrEquals";
        private const string PROPERTY_IN = "in";
        private const string PROPERTY_NOTIN = "notIn";
        private const string PROPERTY_EXISTS = "exists";
        private const string PROPERTY_DISPLAYNAME = "displayName";
        private const string PROPERTY_DESCRIPTION = "description";
        private const string PROPERTY_METADATA = "metadata";
        private const string PROPERTY_VERSION = "version";
        private const string PROPERTY_CATEGORY = "category";
        private const string PROPERTY_DEPLOYMENT = "deployment";
        private const string PROPERTY_VALUE = "value";
        private const string PROPERTY_COUNT = "count";
        private const string PROPERTY_NOTCOUNT = "notCount";
        private const string PROPERTY_WHERE = "where";
        private const string PROPERTY_RESOURCES = "resources";
        private const string PROPERTY_REQUESTCONTEXT = "requestContext";
        private const string PROPERTY_APIVERSION = "apiVersion";
        private const string EFFECT_DISABLED = "Disabled";
        private const string EFFECT_AUDITIFNOTEXISTS = "AuditIfNotExists";
        private const string EFFECT_DEPLOYIFNOTEXISTS = "DeployIfNotExists";
        private const string COLLECTION_ALIAS = "[*]";
        private const string AND_CLAUSE = "&&";
        private const string OR_CLAUSE = "||";
        private const string EQUALITY_OPERATOR = "==";
        private const string INEQUALITY_OPERATOR = "!=";
        private const string LESS_OPERATOR = "<";
        private const string LESSOREQUAL_OPERATOR = "<=";
        private const string GREATER_OPERATOR = ">";
        private const string GREATEROREQUAL_OPERATOR = ">=";
        private const string DOT = ".";
        private const char SLASH = '/';
        private const char GROUP_OPEN = '(';
        private const char GROUP_CLOSE = ')';
        private const string TYPE_SECURITYASSESSMENTS = "Microsoft.Security/assessments";
        private const string TYPE_GUESTCONFIGURATIONASSIGNMENTS = "Microsoft.GuestConfiguration/guestConfigurationAssignments";
        private const string TYPE_BACKUPPROTECTEDITEMS = "Microsoft.RecoveryServices/backupprotecteditems";
        private const string TYPE_SUBSCRIPTION_RESOURCEGROUP = "Microsoft.Resources/subscriptions/resourceGroups";
        private const string TYPE_RESOURCEGROUP = "Microsoft.Resources/resourceGroups";

        private static readonly CultureInfo AzureCulture = new("en-US");

        /// <summary>
        /// A context state used during expanding policy assignments and definitions.
        /// </summary>
        public sealed class PolicyAssignmentContext : ITemplateContext
        {
            private readonly ExpressionFactory _ExpressionFactory;
            private readonly ExpressionBuilder _ExpressionBuilder;
            private readonly PolicyAliasProviderHelper _PolicyAliasProviderHelper;
            internal string AssignmentFile { get; private set; }
            private readonly IList<PolicyDefinition> _Definitions;
            internal readonly IDictionary<string, IDictionary<string, IParameterValue>> DefinitionParameterMap;
            internal readonly PipelineContext Pipeline;
            private readonly TemplateValidator _Validator;
            private readonly IDictionary<string, JToken> _ParameterAssignments;
            private readonly HashSet<string> _PolicyIgnore;

            internal PolicyAssignmentContext(PipelineContext context)
            {
                _ExpressionFactory = new ExpressionFactory(policy: true);
                _ExpressionBuilder = new ExpressionBuilder(_ExpressionFactory);
                _PolicyAliasProviderHelper = new PolicyAliasProviderHelper();
                _Definitions = new List<PolicyDefinition>();
                DefinitionParameterMap = new Dictionary<string, IDictionary<string, IParameterValue>>(StringComparer.OrdinalIgnoreCase);
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

                PolicyRulePrefix = ConfigurationOption.Default.PolicyRulePrefix;
                if (context?.Option?.Configuration?.PolicyRulePrefix != null)
                    PolicyRulePrefix = context?.Option?.Configuration?.PolicyRulePrefix;

                _PolicyIgnore = new PolicyIgnoreData().GetIndex();
                if (context?.Option?.Configuration?.PolicyIgnoreList != null)
                    _PolicyIgnore.UnionWith(context?.Option?.Configuration?.PolicyIgnoreList);
            }

            public TemplateVisitor.TemplateContext.CopyIndexStore CopyIndex { get; }
            public DeploymentValue Deployment { get; }
            public string TemplateFile { get; }
            public string ParameterFile { get; }
            public ResourceGroupOption ResourceGroup { get; }
            public SubscriptionOption Subscription { get; }
            public TenantOption Tenant { get; }
            public ManagementGroupOption ManagementGroup { get; }
            public string PolicyRulePrefix { get; }

            /// <summary>
            /// A unique identifer for the current assignment that is being processed.
            /// </summary>
            internal string AssignmentId { get; private set; }

            /// <summary>
            /// A unique identifer for the current policy definition that is being processed.
            /// </summary>
            internal string PolicyDefinitionId { get; private set; }

            public ExpressionFnOuter BuildExpression(string s)
            {
                return _ExpressionBuilder.Build(s);
            }

            private JToken GetExpression(JProperty child)
            {
                return TemplateVisitor.ExpandPropertyToken(this, child.Value);
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

            public void AddDefinition(PolicyDefinition policyDefinition)
            {
                _Definitions.Add(policyDefinition);
            }

            private static string ExpressionToObjectPathComparisonOperator(string expression) => expression switch
            {
                PROPERTY_EQUALS => EQUALITY_OPERATOR,
                PROPERTY_NOTEQUALS => INEQUALITY_OPERATOR,
                PROPERTY_GREATER => GREATER_OPERATOR,
                PROPERTY_GREATEROREQUALS => GREATEROREQUAL_OPERATOR,
                PROPERTY_LESS => LESS_OPERATOR,
                PROPERTY_LESSOREQUALS => LESSOREQUAL_OPERATOR,
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

            internal void SetDefinitionParameterAssignment(PolicyDefinition definition, JProperty parameter)
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

            private string GetFieldObjectPathArrayFilter(JObject obj)
            {
                if (obj.TryStringProperty(PROPERTY_FIELD, out var fieldProperty))
                {
                    var subProperty = string.Empty;

                    // If we come across a type, set the .type sub property in the object path
                    // Also set the current type for any further alias expansion
                    if (fieldProperty.Equals(PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase) &&
                        obj.TryStringProperty(PROPERTY_EQUALS, out var fieldType))
                    {
                        subProperty = $".{PROPERTY_TYPE}";
                        SetPolicyRuleType(fieldType);
                    }
                    else if (TryPolicyAliasPath(fieldProperty, out var fieldAliasPath))
                    {
                        subProperty = fieldAliasPath.SplitByLastSubstring(COLLECTION_ALIAS)[1];
                    }

                    var comparisonExpression = obj.Children<JProperty>()
                        .FirstOrDefault(prop => !prop.Name.Equals(PROPERTY_FIELD, StringComparison.OrdinalIgnoreCase));

                    if (comparisonExpression != null)
                    {
                        var objectPathComparisonOperator = ExpressionToObjectPathComparisonOperator(comparisonExpression.Name);

                        // Expand string values if we come across any
                        var comparisonValue = comparisonExpression.Value;
                        if (comparisonValue.Type == JTokenType.String)
                            comparisonValue = TemplateVisitor.ExpandPropertyToken(this, comparisonValue);

                        if (objectPathComparisonOperator != null)
                        {
                            return FormatObjectPathArrayFilter(
                                subProperty,
                                objectPathComparisonOperator,
                                comparisonValue
                            );
                        }
                        else
                        {
                            // Convert in expression
                            if (comparisonExpression.Name.Equals(PROPERTY_IN, StringComparison.OrdinalIgnoreCase)
                                && comparisonValue.Type == JTokenType.Array)
                            {
                                var filters = comparisonValue
                                    .Select(val => FormatObjectPathArrayFilter(subProperty, EQUALITY_OPERATOR, val));

                                return string.Concat(GROUP_OPEN, string.Join($" {OR_CLAUSE} ", filters), GROUP_CLOSE);
                            }

                            // Convert notIn expression
                            else if (comparisonExpression.Name.Equals(PROPERTY_NOTIN, StringComparison.OrdinalIgnoreCase)
                                && comparisonValue.Type == JTokenType.Array)
                            {
                                var filters = comparisonValue
                                    .Select(val => FormatObjectPathArrayFilter(subProperty, INEQUALITY_OPERATOR, val));

                                return string.Concat(GROUP_OPEN, string.Join($" {AND_CLAUSE} ", filters), GROUP_CLOSE);
                            }

                            // Convert exists expression
                            else if (comparisonExpression.Name.Equals(PROPERTY_EXISTS, StringComparison.OrdinalIgnoreCase))
                            {
                                var existsValue = comparisonValue.Value<bool>();

                                return FormatObjectPathArrayFilter(
                                    subProperty,
                                    existsValue ? INEQUALITY_OPERATOR : EQUALITY_OPERATOR,
                                    null);
                            }
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

                    else if (obj.TryArrayProperty(PROPERTY_ALLOF, out var allOfExpression))
                    {
                        objectPath.Append($" {clause} ");
                        objectPath.Append(GROUP_OPEN);
                        ExpressionToObjectPathArrayFilter(allOfExpression, AND_CLAUSE, objectPath);
                        objectPath.Append(GROUP_CLOSE);
                    }

                    else if (obj.TryArrayProperty(PROPERTY_ANYOF, out var anyOfExpression))
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
                return value == null
                    ? string.Format(
                        Thread.CurrentThread.CurrentCulture,
                        "@{0} {1} null",
                        subProperty,
                        comparisonOperator)
                    : string.Format(
                    Thread.CurrentThread.CurrentCulture,
                    value.Type == JTokenType.String ? "@{0} {1} '{2}'" : "@{0} {1} {2}",
                    subProperty,
                    comparisonOperator,
                    value);
            }

            /// <summary>
            /// Comparer class which orders certain properties before others
            /// </summary>
            private sealed class PropertyNameComparer : IComparer<JProperty>
            {
                public int Compare(JProperty x, JProperty y)
                {
                    return OrderFirst(y)
                        ? 1
                        : OrderFirst(x)
                        ? -1
                        : string.Compare(x.Name, y.Name, StringComparison.OrdinalIgnoreCase);
                }

                private static bool OrderFirst(JProperty prop)
                {
                    return prop.Name.Equals(PROPERTY_FIELD, StringComparison.OrdinalIgnoreCase)
                        || prop.Name.Equals(PROPERTY_COUNT, StringComparison.OrdinalIgnoreCase);
                }
            }

            /// <summary>
            /// Converts the policy condition to a PSRule rule condition.
            /// </summary>
            internal void ExpandPolicyRule(JToken policyRule, IList<string> types)
            {
                if (policyRule.Type == JTokenType.Object)
                {
                    var hasFieldType = false;
                    var hasFieldCount = false;

                    // Go through each property and make sure fields and counts are sorted first
                    foreach (var child in policyRule.Children<JProperty>().OrderBy(prop => prop, new PropertyNameComparer()))
                    {
                        // Expand field aliases
                        if (child.TryGetProperty(PROPERTY_FIELD, out var field))
                        {
                            if (field.Equals(PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase))
                            {
                                hasFieldType = true;
                                child.Parent[PROPERTY_TYPE] = DOT;
                                child.Remove();
                            }

                            if (TryPolicyAliasPath(field, out var aliasPath))
                                policyRule[child.Name] = aliasPath;
                        }

                        // Set policy rule type
                        else if (hasFieldType && child.TryGetProperty(PROPERTY_EQUALS, out field))
                        {
                            if (string.Equals(TYPE_SUBSCRIPTION_RESOURCEGROUP, field, StringComparison.OrdinalIgnoreCase))
                                field = TYPE_RESOURCEGROUP;

                            types.Add(field);
                            SetPolicyRuleType(field);
                        }

                        // Replace equals with count if field count expression is currently being visited
                        // Replace notEquals with notCount if field count expression is currently being visited
                        else if (hasFieldCount && (child.TryRenameProperty(PROPERTY_EQUALS, PROPERTY_COUNT) ||
                            child.TryRenameProperty(PROPERTY_NOTEQUALS, PROPERTY_NOTCOUNT)))
                        {
                            // Do nothing.
                        }

                        // Expand field count expressions
                        else if (child.Name.Equals(PROPERTY_COUNT, StringComparison.OrdinalIgnoreCase))
                        {
                            hasFieldCount = true;

                            if (child.Value.Type == JTokenType.Object)
                            {
                                var countObject = child.Value.ToObject<JObject>();
                                if (countObject.TryStringProperty(PROPERTY_FIELD, out var outerFieldAlias) &&
                                    TryPolicyAliasPath(outerFieldAlias, out var outerFieldAliasPath))
                                {
                                    if (countObject.TryObjectProperty(PROPERTY_WHERE, out var whereExpression))
                                    {
                                        // field in where expression
                                        var fieldFilter = GetFieldObjectPathArrayFilter(whereExpression);
                                        if (fieldFilter != null)
                                        {
                                            var splitAliasPath = outerFieldAliasPath.SplitByLastSubstring(COLLECTION_ALIAS);
                                            policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], fieldFilter);
                                        }

                                        // nested allOf in where expression
                                        else if (whereExpression.TryArrayProperty(PROPERTY_ALLOF, out var allofExpression))
                                        {
                                            var splitAliasPath = outerFieldAliasPath.SplitByLastSubstring(COLLECTION_ALIAS);
                                            var filter = new StringBuilder();
                                            ExpressionToObjectPathArrayFilter(allofExpression, AND_CLAUSE, filter);
                                            policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], filter.ToString());
                                        }

                                        // nested anyOf in where expression
                                        else if (whereExpression.TryArrayProperty(PROPERTY_ANYOF, out var anyOfExpression))
                                        {
                                            var splitAliasPath = outerFieldAliasPath.SplitByLastSubstring(COLLECTION_ALIAS);
                                            var filter = new StringBuilder();
                                            ExpressionToObjectPathArrayFilter(anyOfExpression, OR_CLAUSE, filter);
                                            policyRule[PROPERTY_FIELD] = FormatObjectPathArrayExpression(splitAliasPath[0], filter.ToString());
                                        }
                                    }

                                    // Single field in count expression
                                    else
                                        policyRule[PROPERTY_FIELD] = outerFieldAliasPath;

                                    // Remove the count property when we're done
                                    policyRule[PROPERTY_COUNT].Parent.Remove();
                                }
                            }
                        }

                        // Convert string booleans for exists expression
                        else if (child.Name.Equals(PROPERTY_EXISTS, StringComparison.OrdinalIgnoreCase) && child.Value.Type == JTokenType.String)
                            policyRule[child.Name] = child.Value.Value<bool>();

                        // Expand string expressions
                        else if (child.Value.Type == JTokenType.String)
                        {
                            var expression = GetExpression(child);
                            policyRule[child.Name] = expression;
                        }

                        // Recurse any objects or arrays
                        else if (child.Value.Type is JTokenType.Object or JTokenType.Array)
                            ExpandPolicyRule(child.Value, types);
                    }
                }

                // Recurse arrays
                else if (policyRule.Type == JTokenType.Array)
                    foreach (var child in policyRule.Children().ToArray())
                        ExpandPolicyRule(child, types);
            }

            private static ParameterType GetParameterType(JToken parameter)
            {
                return parameter[PROPERTY_TYPE].ToObject<ParameterType>();
            }

            private void CheckParameter(string parameterName, JObject parameter, ParameterType type, JToken value)
            {
                if (type == ParameterType.String && !string.IsNullOrEmpty(value.Value<string>()))
                    _Validator.ValidateParameter(this, type, parameterName, parameter, value);
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

            internal bool TryPolicyAliasPath(string aliasName, out string aliasPath)
            {
                aliasPath = null;
                return !string.IsNullOrEmpty(aliasName) &&
                    _PolicyAliasProviderHelper.ResolvePolicyAliasPath(aliasName, out aliasPath);
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

            public void AddValidationIssue(string issueId, string name, string path, string message, params object[] args)
            {
                return;
            }

            public bool IsSecureValue(object value)
            {
                return false;
            }

            public bool TryParameter(string parameterName, out object value)
            {
                value = null;

                if (DefinitionParameterMap.TryGetValue(PolicyDefinitionId, out var definitionParameters)
                    && definitionParameters.TryGetValue(parameterName, out var parameterValue))
                {
                    value = parameterValue.GetValue(this);
                    return true;
                }

                return false;
            }

            /// <summary>
            /// Set the Id for the assignment that is being processed.
            /// </summary>
            internal void EnterAssignment(string assignmentId)
            {
                AssignmentId = assignmentId;
            }

            /// <summary>
            /// Clean up after processing an assignment.
            /// </summary>
            internal void ExitAssignment()
            {
                AssignmentId = null;
                PolicyDefinitionId = null;
                _ParameterAssignments.Clear();
            }

            /// <summary>
            /// Set the Id for the policy definition that is being processed.
            /// </summary>
            internal void SetPolicyDefinitionId(string definitionId)
            {
                PolicyDefinitionId = definitionId;
            }

            /// <summary>
            /// Determines if the policy definition should be skipped.
            /// </summary>
            internal bool ShouldIgnorePolicyDefinition(string definitionId)
            {
                return _PolicyIgnore.Contains(definitionId);
            }

            /// <inheritdoc/>
            public bool TryLambdaVariable(string variableName, out object value)
            {
                throw new NotImplementedException();
            }

            bool ITemplateContext.TryDefinition(string type, out ITypeDefinition definition)
            {
                throw new NotImplementedException();
            }
        }

        internal void Visit(PolicyAssignmentContext context, JObject assignment)
        {
            Assignment(context, assignment);
        }

        /// <summary>
        /// Process each policy assignment and linked definitions.
        /// </summary>
        protected virtual void Assignment(PolicyAssignmentContext context, JObject assignment)
        {
            try
            {
                if (!assignment.TryGetProperty(PROPERTY_POLICYASSIGNMENTID, out var assignmentId))
                    return;

                // Get the Id of the assignment for logging.
                context.EnterAssignment(assignmentId);

                // Get assignment Properties
                if (assignment.TryObjectProperty(PROPERTY_PROPERTIES, out var properties))
                {
                    // Get assignment parameters
                    if (properties.TryObjectProperty(PROPERTY_PARAMETERS, out var parameters))
                        AssignmentParameters(context, parameters);
                }

                // Get assignment policy definitions Definitions
                if (assignment.TryArrayProperty(PROPERTY_POLICYDEFINITIONS, out var definitions))
                    Definitions(context, definitions.Values<JObject>());
            }
            finally
            {
                context.ExitAssignment();
            }
        }

        /// <summary>
        /// Add parameters for the assignment to the context.
        /// </summary>
        protected virtual void AssignmentParameters(PolicyAssignmentContext context, JObject parameters)
        {
            if (parameters == null || parameters.Count == 0)
                return;

            foreach (var parameter in parameters.Children<JProperty>())
                context.AddParameterAssignment(parameter.Name, parameter.Value);
        }

        /// <summary>
        /// Process each policy definition of the assignment.
        /// </summary>
        protected virtual void Definitions(PolicyAssignmentContext context, IEnumerable<JObject> definitions)
        {
            if (definitions == null || !definitions.Any())
                return;

            foreach (var definition in definitions)
            {
                try
                {
                    if (definition.TryStringProperty(PROPERTY_POLICYDEFINITIONID, out var definitionId) && !ShouldFilterDefinition(context, definitionId))
                    {
                        context.SetPolicyDefinitionId(definitionId);
                        if (TryPolicyDefinition(context, definition, definitionId, out var policyDefinition))
                            context.AddDefinition(policyDefinition);
                    }
                }
                catch (Exception inner)
                {
                    context.Pipeline.Writer?.WriteError(inner, inner.GetBaseException().GetType().FullName, errorCategory: ErrorCategory.NotSpecified, targetObject: definition);
                }
            }
        }

        private static bool ShouldFilterDefinition(PolicyAssignmentContext context, string definitionId)
        {
            return context.ShouldIgnorePolicyDefinition(definitionId);
        }

        /// <summary>
        /// Checks if two parameters are equal
        /// </summary>
        private static bool ParametersEqual(PolicyAssignmentContext context, IParameterValue paramA, IParameterValue paramB)
        {
            var typeA = paramA.Type;
            var typeB = paramB.Type;
            var valueA = paramA.GetValue(context);
            var valueB = paramB.GetValue(context);

            if (typeA == ParameterType.String && typeB == ParameterType.String)
                return valueA.ToString().Equals(valueB.ToString(), StringComparison.OrdinalIgnoreCase);

            if (typeA == ParameterType.Integer && typeB == ParameterType.Integer)
                return Convert.ToInt64(valueA, Thread.CurrentThread.CurrentCulture) == Convert.ToInt64(valueB, Thread.CurrentThread.CurrentCulture);

            if (typeA == ParameterType.Boolean && typeB == ParameterType.Boolean)
                return Convert.ToBoolean(valueA, Thread.CurrentThread.CurrentCulture) == Convert.ToBoolean(valueB, Thread.CurrentThread.CurrentCulture);

            if (typeA == ParameterType.Array && typeB == ParameterType.Array)
                return JToken.DeepEquals(JArray.FromObject(valueA), JArray.FromObject(valueB));

            if (typeA == ParameterType.Object && typeB == ParameterType.Object)
                return JToken.DeepEquals(JObject.FromObject(valueA), JObject.FromObject(valueB));

            // TODO: Handle more types

            return true;
        }

        /// <summary>
        /// Convert each definition into <see cref="PolicyDefinition"/>.
        /// </summary>
        protected virtual bool TryPolicyDefinition(PolicyAssignmentContext context, JObject definition, string policyDefinitionId, out PolicyDefinition policyDefinition)
        {
            policyDefinition = null;

            // A definition must have properties, policyRule, and a non-disabled effect.
            if (!definition.TryObjectProperty(PROPERTY_PROPERTIES, out var properties) ||
                !properties.TryObjectProperty(PROPERTY_POLICYRULE, out var policyRule) ||
                !policyRule.TryObjectProperty(PROPERTY_IF, out _) ||
                !policyRule.TryObjectProperty(PROPERTY_THEN, out var then))
                return false;

            if (!properties.TryStringProperty(PROPERTY_MODE, out var mode) ||
                !IsPolicyMode(mode, out var policyMode))
                return false;

            properties.TryStringProperty(PROPERTY_DISPLAYNAME, out var displayName);
            properties.TryStringProperty(PROPERTY_DESCRIPTION, out var description);
            var result = new PolicyDefinition(policyDefinitionId, description, definition);

            // Set annotations
            if (properties.TryObjectProperty(PROPERTY_METADATA, out var metadata))
            {
                if (metadata.TryStringProperty(PROPERTY_CATEGORY, out var category))
                    result.Category = category;

                if (metadata.TryStringProperty(PROPERTY_VERSION, out var version))
                    result.Version = version;
            }

            // Set parameters
            if (properties.TryObjectProperty(PROPERTY_PARAMETERS, out var parameters))
            {
                foreach (var parameter in parameters.Properties())
                    context.SetDefinitionParameterAssignment(result, parameter);

                // Check if definition with same parameters has already been added
                if (context.DefinitionParameterMap.TryGetValue(policyDefinitionId, out var previousDefinitionParameters))
                {
                    var foundDuplicateDefinition = true;
                    foreach (var currentParameter in result.Parameters)
                    {
                        if (previousDefinitionParameters.TryGetValue(currentParameter.Key, out var previousParameterValue))
                        {
                            if (!ParametersEqual(context, previousParameterValue, currentParameter.Value))
                            {
                                foundDuplicateDefinition = false;
                                break;
                            }
                        }
                    }

                    // Skip adding definition if duplicate parameters found
                    if (foundDuplicateDefinition)
                        return false;
                }

                context.DefinitionParameterMap[policyDefinitionId] = result.Parameters;
            }

            // Modify policy rule
            TrimPolicyRule(policyRule);
            VisitPolicyRule(context, policyRule);

            context.ExpandPolicyRule(policyRule, result.Types);
            if (!TryPolicyRuleEffect(then, out var effect) ||
                ShouldFilterRule(then, effect))
                return false;

            if (policyRule.TryObjectProperty(PROPERTY_IF, out var condition))
                result.Condition = condition;

            AddSelectors(result, policyMode);
            EffectConditions(result, policyRule);
            OptimizeConditions(result);
            policyDefinition = result;

            // Check for an resulting empty condition.
            if (policyDefinition.Condition == null || policyDefinition.Condition.Count == 0)
                throw ThrowEmptyConditionExpandResult(context, policyDefinitionId);

            var policyRuleHash = GetPolicyRuleHash(policyDefinitionId, policyDefinition.Condition, policyDefinition.Where);
            policyDefinition.Name = $"{context.PolicyRulePrefix}.Policy.{policyRuleHash}";

            return true;
        }

        /// <summary>
        /// Visit the policyRule node.
        /// </summary>
        private static void VisitPolicyRule(PolicyAssignmentContext context, JObject policyRule)
        {
            if (policyRule.TryObjectProperty(PROPERTY_IF, out var condition))
                VisitCondition(context, condition);
        }

        /// <summary>
        /// Visit a policy condition node.
        /// </summary>
        private static void VisitCondition(PolicyAssignmentContext context, JObject condition)
        {
            if (condition.TryArrayProperty(PROPERTY_ALLOF, out var allOf))
            {
                foreach (var item in allOf.Values<JObject>())
                {
                    VisitCondition(context, item);
                }
            }
            else if (condition.TryArrayProperty(PROPERTY_ANYOF, out var anyOf))
            {
                foreach (var item in anyOf.Values<JObject>())
                {
                    VisitCondition(context, item);
                }
            }
            else
            {
                if (condition.TryStringProperty(PROPERTY_VALUE, out var s) && s.IsExpressionString())
                {
                    VisitValueExpression(context, condition, s);
                }
            }
        }

        private static void VisitValueExpression(PolicyAssignmentContext context, JObject condition, string s)
        {
            var tokens = ExpressionParser.Parse(s);

            // Handle [requestContext().apiVersion]
            if (tokens.ConsumeFunction(PROPERTY_REQUESTCONTEXT) &&
                tokens.ConsumeGroup() &&
                tokens.ConsumePropertyName(PROPERTY_APIVERSION))
            {
                condition.Remove(PROPERTY_VALUE);
                condition.Add(PROPERTY_FIELD, PROPERTY_APIVERSION);
                if (condition.TryGetProperty(PROPERTY_LESS, out var value))
                {
                    condition.Remove(PROPERTY_LESS);
                    condition.Add(PROPERTY_APIVERSION, string.Concat(LESS_OPERATOR, value));
                }
                else if (condition.TryGetProperty(PROPERTY_LESSOREQUALS, out value))
                {
                    condition.Remove(PROPERTY_LESSOREQUALS);
                    condition.Add(PROPERTY_APIVERSION, string.Concat(LESSOREQUAL_OPERATOR, value));

                }
                else if (condition.TryGetProperty(PROPERTY_GREATER, out value))
                {
                    condition.Remove(PROPERTY_GREATER);
                    condition.Add(PROPERTY_APIVERSION, string.Concat(GREATER_OPERATOR, value));
                }
                else if (condition.TryGetProperty(PROPERTY_GREATEROREQUALS, out value))
                {
                    condition.Remove(PROPERTY_GREATEROREQUALS);
                    condition.Add(PROPERTY_APIVERSION, string.Concat(GREATEROREQUAL_OPERATOR, value));
                }
                else if (condition.TryGetProperty(PROPERTY_EQUALS, out value))
                {
                    condition.Remove(PROPERTY_EQUALS);
                    condition.Add(PROPERTY_APIVERSION, value);
                }
            }

            // Handle [field('string')]
            else if (tokens.ConsumeFunction(PROPERTY_FIELD) &&
                tokens.TryTokenType(ExpressionTokenType.GroupStart, out _) &&
                tokens.ConsumeString(out var field) &&
                tokens.TryTokenType(ExpressionTokenType.GroupEnd, out _))
            {
                // Handle [field('type')]
                if (string.Equals(field, PROPERTY_TYPE, StringComparison.OrdinalIgnoreCase))
                {
                    condition.Remove(PROPERTY_VALUE);
                    condition.Add(PROPERTY_TYPE, DOT);
                }
                else
                {
                    condition.Remove(PROPERTY_VALUE);
                    condition.Add(PROPERTY_FIELD, field);
                }
            }
        }

        /// <summary>
        /// Get hash of definitionID + condition + pre-condition
        /// </summary>
        private static string GetPolicyRuleHash(string definitionId, JObject condition, JObject preCondition, int length = 6)
        {
            using var hashAlgorithm = SHA256.Create();

            var seed = new Guid("bce66f73-3809-4740-b3c3-f52958e7ab51").ToByteArray();
            hashAlgorithm.TransformBlock(seed, 0, seed.Length, null, 0);

            if (!string.IsNullOrEmpty(definitionId))
            {
                var bytes = Encoding.UTF8.GetBytes(definitionId);
                hashAlgorithm.TransformBlock(bytes, 0, bytes.Length, null, 0);
            }

            var conditionBytes = condition != null
                ? Encoding.UTF8.GetBytes(condition.ToString(Formatting.None))
                : Array.Empty<byte>();

            hashAlgorithm.TransformBlock(conditionBytes, 0, conditionBytes.Length, null, 0);

            var preConditionBytes = preCondition != null
                ? Encoding.UTF8.GetBytes(preCondition.ToString(Formatting.None))
                : Array.Empty<byte>();

            hashAlgorithm.TransformFinalBlock(preConditionBytes, 0, preConditionBytes.Length);

            var hash = hashAlgorithm.Hash;

            var builder = new StringBuilder();
            for (var i = 0; i < hash.Length && i < length; i++)
                builder.Append(hash[i].ToString("x2", AzureCulture));

            return builder.ToString();
        }

        private static void AddSelectors(PolicyDefinition policyDefinition, PolicyMode policyMode)
        {
            if (policyMode != PolicyMode.Indexed)
                return;

            policyDefinition.With = new string[] { "PSRule.Rules.Azure\\Azure.Resource.SupportsTags" };
        }

        private static void OptimizeConditions(PolicyDefinition policyDefinition)
        {
            policyDefinition.Where = OptimizeConditionObject(policyDefinition, policyDefinition.Where);
            policyDefinition.Condition = OptimizeConditionObject(policyDefinition, policyDefinition.Condition, keep: true);
        }

        private static JObject OptimizeConditionObject(PolicyDefinition policyDefinition, JObject condition, bool keep = false)
        {
            if (condition == null || !keep && OptimizeTypeCondition(policyDefinition, condition))
                return null;

            // Handle allOf and anyOf depth
            if (condition.TryArrayProperty(PROPERTY_ALLOF, out var items) ||
                condition.TryArrayProperty(PROPERTY_ANYOF, out items))
            {
                foreach (var item in items.OfType<JObject>().ToArray())
                {
                    if (OptimizeConditionObject(policyDefinition, item) == null)
                        item.Remove();
                }
            }
            // Handle field merge
            else if (condition.TryGetProperty(PROPERTY_FIELD, out var field))
            {
                MergeWithPeerCondition(condition, field);
            }
            return condition;
        }

        private static void MergeWithPeerCondition(JObject condition, string field)
        {
            if (condition.TryArrayProperty(PROPERTY_IN, out var values))
            {
                foreach (var peer in condition.GetPeerConditionByField(field))
                {
                    if (peer.TryArrayProperty(PROPERTY_IN, out var otherValues))
                    {
                        values.AddRange(otherValues);
                        condition[PROPERTY_IN] = values;
                        peer.Remove();
                    }
                }
            }
        }

        private static bool OptimizeTypeCondition(PolicyDefinition policyDefinition, JObject condition)
        {
            return policyDefinition.Types != null &&
                policyDefinition.Types.Count == 1 &&
                condition.ContainsKeyInsensitive(PROPERTY_TYPE) &&
                condition.ContainsKeyInsensitive(PROPERTY_EQUALS);
        }

        /// <summary>
        /// Handle conditions or pre-conditions associated with the effect of the policy definition.
        /// </summary>
        private static void EffectConditions(PolicyDefinition policyDefinition, JObject policyRule)
        {
            if (!policyRule.TryObjectProperty(PROPERTY_THEN, out var then) ||
                !then.TryObjectProperty(PROPERTY_DETAILS, out var details))
                return;

            if (IsIfNotExistsEffect(then))
            {
                policyDefinition.Where = policyDefinition.Condition;
                policyDefinition.Condition = AndExistanceExpression(details, DefaultEffectConditions(details));
            }
            else
            {
                policyDefinition.Condition = AndCondition(policyDefinition.Condition, DefaultEffectConditions(details));
            }
        }

        /// <summary>
        /// Determines if the effect is AuditIfNotExists or DeployIfNotExists.
        /// </summary>
        private static bool IsIfNotExistsEffect(JObject then)
        {
            return TryPolicyRuleEffect(then, out var effect) &&
                (StringComparer.OrdinalIgnoreCase.Equals(effect, EFFECT_AUDITIFNOTEXISTS) ||
                StringComparer.OrdinalIgnoreCase.Equals(effect, EFFECT_DEPLOYIFNOTEXISTS));
        }

        /// <summary>
        /// Update the condition if then policy effect is Audit, Deny, Modify, or Append.
        /// </summary>
        private static JObject DefaultEffectConditions(JObject details)
        {
            return AndNameCondition(details, TypeExpression(details));
        }

        private static JObject TypeExpression(JObject details)
        {
            return details == null || !details.TryStringProperty(PROPERTY_TYPE, out var type) ? null : new JObject {
                { PROPERTY_TYPE, DOT },
                { PROPERTY_EQUALS, type }
            };
        }

        private static JObject AndExistanceExpression(JObject details, JObject subselector)
        {
            if (details == null || !details.TryObjectProperty(PROPERTY_EXISTENCECONDITION, out var existenceCondition))
            {
                existenceCondition = new JObject
                {
                    { PROPERTY_VALUE, true },
                    { PROPERTY_EQUALS, true }
                };
            }

            var allOf = new JArray
            {
                existenceCondition
            };
            var existanceExpression = new JObject
            {
                { PROPERTY_FIELD, PROPERTY_RESOURCES },
                { PROPERTY_ALLOF, allOf }
            };
            if (subselector != null && subselector.Count > 0)
                existanceExpression[PROPERTY_WHERE] = subselector;

            return existanceExpression;
        }

        private static JObject AndNameCondition(JObject details, JObject condition)
        {
            if (details == null || !details.TryStringProperty(PROPERTY_NAME, out var name))
                return condition;

            var nameCondition = new JObject {
                { PROPERTY_NAME, DOT },
                { PROPERTY_EQUALS, name }
            };
            return AndCondition(condition, nameCondition);
        }

        private static JObject AndCondition(JObject left, JObject right)
        {
            if (left != null && left.Count > 0 && right != null && right.Count > 0)
            {
                var allOf = new JArray
                {
                    left,
                    right
                };
                return new JObject
                {
                    { PROPERTY_ALLOF, allOf }
                };
            }
            return left == null || left.Count == 0 ? right : left;
        }

        private static bool TryPolicyRuleEffect(JObject then, out string effect)
        {
            return then.TryStringProperty(PROPERTY_EFFECT, out effect);
        }

        /// <summary>
        /// Removes unneeded properties from the policy rule object.
        /// </summary>
        private static void TrimPolicyRule(JObject policyRule)
        {
            if (policyRule.TryObjectProperty(PROPERTY_THEN, out var effectBlock) &&
                effectBlock.TryObjectProperty(PROPERTY_DETAILS, out var details) &&
                details.TryObjectProperty(PROPERTY_DEPLOYMENT, out _))
            {
                details.Remove(PROPERTY_DEPLOYMENT);
                policyRule[PROPERTY_THEN][PROPERTY_DETAILS] = details;
            }
        }

        /// <summary>
        /// Determines if the policy definition should be skipped and not generate a rule.
        /// </summary>
        private static bool ShouldFilterRule(JObject then, string effect)
        {
            if (effect.Equals(EFFECT_DISABLED, StringComparison.OrdinalIgnoreCase))
                return true;

            // Check if AuditIfNotExists type is a runtime type.
            return then.TryObjectProperty(PROPERTY_DETAILS, out var details) &&
                details.TryStringProperty(PROPERTY_TYPE, out var type) &&
                effect.Equals(EFFECT_AUDITIFNOTEXISTS, StringComparison.OrdinalIgnoreCase) &&
                IsRuntimeType(type);
        }

        private static bool IsRuntimeType(string type)
        {
            return type.Equals(TYPE_SECURITYASSESSMENTS, StringComparison.OrdinalIgnoreCase) ||
                type.Equals(TYPE_GUESTCONFIGURATIONASSIGNMENTS, StringComparison.OrdinalIgnoreCase) ||
                type.Equals(TYPE_BACKUPPROTECTEDITEMS, StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsPolicyMode(string mode, out PolicyMode policyMode)
        {
            policyMode = PolicyMode.None;
            return !string.IsNullOrEmpty(mode) && Enum.TryParse(mode, ignoreCase: true, out policyMode);
        }

        private static PolicyDefinitionEmptyConditionException ThrowEmptyConditionExpandResult(PolicyAssignmentContext context, string policyDefinitionId)
        {
            return new PolicyDefinitionEmptyConditionException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.EmptyConditionExpandResult, policyDefinitionId, context.AssignmentId), context.AssignmentFile, context.AssignmentId, policyDefinitionId);
        }
    }

    internal sealed class PolicyAssignmentDataExportVisitor : PolicyAssignmentVisitor
    {

    }
}
