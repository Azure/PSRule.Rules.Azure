// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// An expression for resolving lambda functions.
    /// </summary>
    internal sealed class LambdaExpressionFn
    {
        private readonly object[] _Args;

        /// <summary>
        /// Create an instance of a lambda function with the specified arguments for the function.
        /// </summary>
        /// <param name="args">An array of arguments for the function.</param>
        public LambdaExpressionFn(params object[] args)
        {
            _Args = args;
        }

        private sealed class LambdaContext : NestedTemplateContext
        {
            private readonly Dictionary<string, object> _Variables;

            public LambdaContext(ITemplateContext context)
                : base(context)
            {
                _Variables = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
            }

            public override bool ShouldThrowMissingProperty => false;

            public override bool TryLambdaVariable(string variableName, out object value)
            {
                return _Variables.TryGetValue(variableName, out value);
            }

            internal void LambdaVariable(string variableName, object value)
            {
                if (string.IsNullOrEmpty(variableName))
                    return;

                _Variables[variableName] = value;
            }
        }

        private sealed class LambdaSort : IComparer<object>
        {
            private readonly LambdaContext _LambdaContext;
            private readonly ExpressionFnOuter _Comparer;
            private readonly string _VarName1;
            private readonly string _VarName2;

            public LambdaSort(LambdaContext lambdaContext, ExpressionFnOuter comparer, string varName1, string varName2)
            {
                _LambdaContext = lambdaContext;
                _Comparer = comparer;
                _VarName1 = varName1;
                _VarName2 = varName2;
            }

            public int Compare(object x, object y)
            {
                _LambdaContext.LambdaVariable(_VarName1, x);
                _LambdaContext.LambdaVariable(_VarName2, y);
                return AsBoolean(_LambdaContext, _Comparer) ? 1 : -1;
            }
        }

        #region Lambda functions

        /// <summary>
        /// Call the <c>filter</c> function to filter the input array to items that meet the condition.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputArray">An array of inputs.</param>
        /// <returns>An array of items that meet the condition. If not items meet the condition an empty array will be returned.</returns>
        internal object Filter(ITemplateContext context, object[] inputArray)
        {
            var lambdaContext = GetArgs3(context, out var varName, out var indexName, out var filter) ??
                GetArgs2(context, out varName, out filter);

            if (lambdaContext == null)
                return null;

            var result = new List<object>(inputArray.Length);
            for (var i = 0; i < inputArray.Length; i++)
            {
                lambdaContext.LambdaVariable(varName, inputArray[i]);
                lambdaContext.LambdaVariable(indexName, i);
                if (AsBoolean(lambdaContext, filter))
                    result.Add(inputArray[i]);
            }
            return result.ToArray();
        }

        /// <summary>
        /// Call the <c>map</c> function to transform the input array into items based on the input elements based on a custom function.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputArray">An array of inputs.</param>
        /// <returns>An array of transformed items.</returns>
        internal object Map(ITemplateContext context, object[] inputArray)
        {
            var lambdaContext = GetArgs3(context, out var varName, out var indexName, out var mapper) ??
                GetArgs2(context, out varName, out mapper);

            if (lambdaContext == null)
                return null;

            var result = new object[inputArray.Length];
            for (var i = 0; i < inputArray.Length; i++)
            {
                lambdaContext.LambdaVariable(indexName, i);
                result[i] = ObjectMapper(inputArray[i], lambdaContext, varName, mapper);
            }
            return result;
        }

        /// <summary>
        /// Call the <c>group</c> function to group the input array by a key.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputArray">An array of inputs.</param>
        /// <returns>A resulting object by grouping inputs by a key.</returns>
        internal object GroupBy(ITemplateContext context, object[] inputArray)
        {
            // Example: groupBy(createArray('foo', 'bar', 'baz'), lambda('x', substring(lambdaVariables('x'), 0, 1)))
            var lambdaContext = GetArgs2(context, out var varName, out var groupMapper);
            if (lambdaContext == null)
                return null;

            // Get the key for each input and group by the key.
            var result = new JObject();
            for (var i = 0; i < inputArray.Length; i++)
            {
                lambdaContext.LambdaVariable(varName, inputArray[i]);
                if (groupMapper(lambdaContext) is not string propertyName)
                    continue;

                var propertyValue = result.TryArrayProperty(propertyName, out var v) ? v : new JArray();
                propertyValue.Add(JToken.FromObject(inputArray[i]));
                result[propertyName] = propertyValue;
            }

            return result;
        }

        /// <summary>
        /// Call the <c>mapValues</c> function to transform the value of each property in the input object using a custom function.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputObject">The input object.</param>
        /// <returns>A transformed object.</returns>
        internal object MapValues(ITemplateContext context, JObject inputObject)
        {
            // Example: mapValues(createObject('foo', 'foo'), lambda('val', toUpper(lambdaVariables('val'))))
            var lambdaContext = GetArgs2(context, out var varName, out var mapper);
            if (lambdaContext == null)
                return null;

            // Enumerate each property and call the custom function.
            var result = new JObject();
            foreach (var property in inputObject.Properties())
            {
                lambdaContext.LambdaVariable(varName, property.Value);
                result.Add(property.Name, JToken.FromObject(mapper(lambdaContext)));
            }
            return result;
        }

        /// <summary>
        /// Call the <c>reduce</c> function to combine the input array using a custom combining function.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputArray">An array of inputs.</param>
        /// <param name="initialValue"></param>
        /// <returns>A combined output result from the custom function.</returns>
        internal object Reduce(ITemplateContext context, object[] inputArray, object initialValue)
        {
            var lambdaContext = GetArgs4(context, out var varName1, out var varName2, out var indexName, out var reducer) ??
                GetArgs3(context, out varName1, out varName2, out reducer);

            if (lambdaContext == null)
                return null;

            var result = initialValue;
            for (var i = 0; i < inputArray.Length; i++)
            {
                lambdaContext.LambdaVariable(varName1, result);
                lambdaContext.LambdaVariable(varName2, inputArray[i]);
                lambdaContext.LambdaVariable(indexName, i);
                result = reducer(lambdaContext);
            }
            return result;
        }

        /// <summary>
        /// Call the <c>sort</c> function to reorder the input array elements using a custom sorting function.
        /// </summary>
        /// <param name="context">The current context.</param>
        /// <param name="inputArray">An array of inputs.</param>
        /// <returns>An array of reordered items.</returns>
        internal object Sort(ITemplateContext context, object[] inputArray)
        {
            var lambdaContext = GetArgs3(context, out var varName1, out var varName2, out var comparer);
            if (lambdaContext == null)
                return null;

            var result = new object[inputArray.Length];
            inputArray.CopyTo(result, 0);
            Array.Sort(result, new LambdaSort(lambdaContext, comparer, varName1, varName2));
            return result;
        }

        internal object ToObject(ITemplateContext context, object[] inputArray, LambdaExpressionFn lambdaValues)
        {
            var keyContext = GetArgs2(context, out var varName1, out var keyMapper);
            if (keyContext == null)
                return null;

            string varName2 = null;
            ExpressionFnOuter valueMapper = null;
            var valueContext = lambdaValues?.GetArgs2(context, out varName2, out valueMapper);
            var result = new Dictionary<string, object>(inputArray.Length);
            for (var i = 0; i < inputArray.Length; i++)
            {
                var key = ObjectMapper(inputArray[i], keyContext, varName1, keyMapper)?.ToString() ?? string.Empty;
                var value = valueContext != null ? ObjectMapper(inputArray[i], valueContext, varName2, valueMapper) : inputArray[i];
                result.Add(key, value);
            }
            return result;
        }

        #endregion Lambda functions

        #region Helper methods

        private static bool AsBoolean(ITemplateContext context, ExpressionFnOuter fn)
        {
            var result = fn(context);
            return result is bool b && b;
        }

        private static object GetExpression(ITemplateContext context, object o)
        {
            return o is ExpressionFnOuter fn ? fn(context) : o;
        }

        /// <summary>
        /// Get uses of the <c>lambda</c> function that have two arguments.
        /// </summary>
        private LambdaContext GetArgs2(ITemplateContext context, out string varName1, out ExpressionFnOuter fn)
        {
            fn = null;
            varName1 = null;
            if (_Args.Length < 2)
                return null;

            var arg0 = GetExpression(context, _Args[0]);
            if (!ExpressionHelpers.TryString(arg0, out varName1) || _Args[1] is not ExpressionFnOuter arg1)
                return null;

            fn = arg1;
            return context is LambdaContext existing ? existing : new LambdaContext(context);
        }

        /// <summary>
        /// Get uses of the <c>lambda</c> function that have three arguments.
        /// </summary>
        private LambdaContext GetArgs3(ITemplateContext context, out string varName1, out string varName2, out ExpressionFnOuter fn)
        {
            fn = null;
            varName1 = null;
            varName2 = null;
            if (_Args.Length < 3)
                return null;

            var arg0 = GetExpression(context, _Args[0]);
            var arg1 = GetExpression(context, _Args[1]);
            if (!ExpressionHelpers.TryString(arg0, out varName1) ||
                !ExpressionHelpers.TryString(arg1, out varName2) ||
                _Args[2] is not ExpressionFnOuter arg2)
                return null;

            fn = arg2;
            return context is LambdaContext existing ? existing : new LambdaContext(context);
        }

        /// <summary>
        /// Get uses of the <c>lambda</c> function that have four arguments.
        /// </summary>
        private LambdaContext GetArgs4(ITemplateContext context, out string varName1, out string varName2, out string varName3, out ExpressionFnOuter fn)
        {
            fn = null;
            varName1 = null;
            varName2 = null;
            varName3 = null;
            if (_Args.Length < 4)
                return null;

            var arg0 = GetExpression(context, _Args[0]);
            var arg1 = GetExpression(context, _Args[1]);
            var arg2 = GetExpression(context, _Args[2]);
            if (!ExpressionHelpers.TryString(arg0, out varName1) ||
                !ExpressionHelpers.TryString(arg1, out varName2) ||
                !ExpressionHelpers.TryString(arg2, out varName3) ||
                _Args[3] is not ExpressionFnOuter arg3)
                return null;

            fn = arg3;
            return context is LambdaContext existing ? existing : new LambdaContext(context);
        }

        private static object ObjectMapper(object input, LambdaContext context, string varName, ExpressionFnOuter mapper)
        {
            if (context == null || mapper == null)
                return null;

            context.LambdaVariable(varName, input);
            return mapper(context);
        }

        #endregion Helper methods
    }
}
