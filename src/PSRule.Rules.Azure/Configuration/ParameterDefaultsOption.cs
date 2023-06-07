// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Configuration
{
    /// <summary>
    /// Options that set parameter defaults for expansion.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Naming", "CA1710:Identifiers should have correct suffix", Justification = "Not a generic dictionary.")]
    public sealed class ParameterDefaultsOption : IEquatable<ParameterDefaultsOption>, IDictionary<string, object>
    {
        internal static readonly ParameterDefaultsOption Default = new();

        private readonly Dictionary<string, object> _Defaults;

        /// <summary>
        /// Create an empty parameter defaults option.
        /// </summary>
        public ParameterDefaultsOption()
        {
            _Defaults = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        }

        internal ParameterDefaultsOption(ParameterDefaultsOption option)
        {
            if (option == null)
                return;

            _Defaults = new Dictionary<string, object>(option._Defaults, StringComparer.OrdinalIgnoreCase);
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            return obj is ParameterDefaultsOption option && Equals(option);
        }

        /// <inheritdoc/>
        public bool Equals(ParameterDefaultsOption other)
        {
            return other != null &&
                ContentsEquals(_Defaults);
        }

        private bool ContentsEquals(Dictionary<string, object> other)
        {
            if (_Defaults.Count != other.Count)
                return false;

            foreach (var kv in _Defaults)
            {
                if (!other.TryGetValue(kv.Key, out var value) || kv.Value != value)
                    return false;
            }
            return true;
        }

        /// <summary>
        /// Compares two parameter default options to determine if they are equal.
        /// </summary>
        public static bool operator ==(ParameterDefaultsOption o1, ParameterDefaultsOption o2)
        {
            return Equals(o1, o2);
        }

        /// <summary>
        /// Compares two parameter default options to determine if they are not equal.
        /// </summary>
        public static bool operator !=(ParameterDefaultsOption o1, ParameterDefaultsOption o2)
        {
            return !Equals(o1, o2);
        }

        /// <summary>
        /// Compares two parameter default options to determine if they are equal.
        /// </summary>
        public static bool Equals(ParameterDefaultsOption o1, ParameterDefaultsOption o2)
        {
            return (object.Equals(null, o1) && object.Equals(null, o2)) ||
                (!object.Equals(null, o1) && o1.Equals(o2));
        }

        /// <inheritdoc/>
        public override int GetHashCode()
        {
            unchecked // Overflow is fine
            {
                var hash = 17;
                hash = hash * 23 + (_Defaults != null ? _Defaults.GetHashCode() : 0);
                return hash;
            }
        }

        internal static ParameterDefaultsOption Combine(ParameterDefaultsOption o1, ParameterDefaultsOption o2)
        {
            var result = new ParameterDefaultsOption();
            result._Defaults.AddUnique(o1?._Defaults);
            result._Defaults.AddUnique(o2?._Defaults);
            return result;
        }

        internal bool TryGetString(string parameterName, out JToken value)
        {
            value = default;
            if (!_Defaults.TryGetString(parameterName, out var result))
                return false;

            value = new JValue(result);
            return true;
        }

        internal bool TryGetBool(string parameterName, out JToken value)
        {
            value = default;
            if (!_Defaults.TryGetBool(parameterName, out var result) || !result.HasValue)
                return false;

            value = new JValue(result.Value);
            return true;
        }

        internal bool TryGetLong(string parameterName, out JToken value)
        {
            value = default;
            if (!_Defaults.TryGetLong(parameterName, out var result) || !result.HasValue)
                return false;

            value = new JValue(result.Value);
            return true;
        }

        internal bool TryGetObject(string parameterName, out JToken value)
        {
            value = default;
            if (!_Defaults.TryGetValue<Dictionary<object, object>>(parameterName, out var result))
                return false;

            value = JObject.FromObject(result);
            return true;
        }

        internal bool TryGetArray(string parameterName, out JToken value)
        {
            value = default;
            if (!_Defaults.TryGetValue<List<object>>(parameterName, out var result))
                return false;

            value = JArray.FromObject(result);
            return true;
        }

        #region IDictionary<string, object>

        ICollection<string> IDictionary<string, object>.Keys => ((IDictionary<string, object>)_Defaults).Keys;

        ICollection<object> IDictionary<string, object>.Values => ((IDictionary<string, object>)_Defaults).Values;

        int ICollection<KeyValuePair<string, object>>.Count => ((ICollection<KeyValuePair<string, object>>)_Defaults).Count;

        bool ICollection<KeyValuePair<string, object>>.IsReadOnly => false;

        /// <inheritdoc/>
        public object this[string key] { get => ((IDictionary<string, object>)_Defaults)[key]; set => ((IDictionary<string, object>)_Defaults)[key] = value; }

        void IDictionary<string, object>.Add(string key, object value)
        {
            ((IDictionary<string, object>)_Defaults).Add(key, value);
        }

        bool IDictionary<string, object>.ContainsKey(string key)
        {
            return ((IDictionary<string, object>)_Defaults).ContainsKey(key);
        }

        bool IDictionary<string, object>.Remove(string key)
        {
            return ((IDictionary<string, object>)_Defaults).Remove(key);
        }

        bool IDictionary<string, object>.TryGetValue(string key, out object value)
        {
            return ((IDictionary<string, object>)_Defaults).TryGetValue(key, out value);
        }

        void ICollection<KeyValuePair<string, object>>.Add(KeyValuePair<string, object> item)
        {
            ((ICollection<KeyValuePair<string, object>>)_Defaults).Add(item);
        }

        void ICollection<KeyValuePair<string, object>>.Clear()
        {
            ((ICollection<KeyValuePair<string, object>>)_Defaults).Clear();
        }

        bool ICollection<KeyValuePair<string, object>>.Contains(KeyValuePair<string, object> item)
        {
            return ((ICollection<KeyValuePair<string, object>>)_Defaults).Contains(item);
        }

        void ICollection<KeyValuePair<string, object>>.CopyTo(KeyValuePair<string, object>[] array, int arrayIndex)
        {
            ((ICollection<KeyValuePair<string, object>>)_Defaults).CopyTo(array, arrayIndex);
        }

        bool ICollection<KeyValuePair<string, object>>.Remove(KeyValuePair<string, object> item)
        {
            return ((ICollection<KeyValuePair<string, object>>)_Defaults).Remove(item);
        }

        IEnumerator<KeyValuePair<string, object>> IEnumerable<KeyValuePair<string, object>>.GetEnumerator()
        {
            return ((IEnumerable<KeyValuePair<string, object>>)_Defaults).GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return ((IEnumerable)_Defaults).GetEnumerator();
        }

        #endregion IDictionary<string, object>
    }
}
