// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json.Linq;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template
{
    internal interface IResourceValue
    {
        JObject Value { get; }

        string Id { get; }

        string Name { get; }

        string Type { get; }

        TemplateContext.CopyIndexState Copy { get; }

        bool DependsOn(IResourceValue other, out int count);
    }

    internal static class ResourceValueExtensions
    {
        private const string PROPERTY_EXISTING = "existing";

        public static bool DependsOn(this IResourceValue resource, IResourceValue other)
        {
            return resource.DependsOn(other);
        }

        public static bool IsType(this IResourceValue resource, string type)
        {
            return string.Equals(resource.Type, type, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Determines if the resource is flagged as an existing reference.
        /// </summary>
        public static bool IsExisting(this IResourceValue resource)
        {
            return resource.Value.TryBoolProperty(PROPERTY_EXISTING, out var existing) && existing.HasValue && existing.Value;
        }

        internal static bool TryOutput<TValue>(this DeploymentValue resource, string name, out TValue value)
        {
            value = default;
            if (resource.TryOutput(name, out var o) && o is TValue v)
            {
                value = v;
                return true;
            }
            return false;
        }
    }

    internal abstract class BaseResourceValue
    {
        private readonly HashSet<string> _Dependencies;

        protected BaseResourceValue(string id, string name, string[] dependencies)
        {
            Id = id;
            Name = name;
            _Dependencies = dependencies == null || dependencies.Length == 0 ? null : new HashSet<string>(dependencies, StringComparer.OrdinalIgnoreCase);
        }

        public string Id { get; }

        public string Name { get; }

        public bool DependsOn(IResourceValue other, out int count)
        {
            count = 0;
            if (_Dependencies == null)
                return false;

            count = _Dependencies.Count;
            return _Dependencies.Contains(other.Id) ||
                other.Copy != null && !string.IsNullOrEmpty(other.Copy.Name) && _Dependencies.Contains(other.Copy.Name) ||
                !string.IsNullOrEmpty(other.Name) && _Dependencies.Contains(other.Name);
        }
    }

    [DebuggerDisplay("{Id}")]
    internal sealed class ResourceValue : BaseResourceValue, IResourceValue
    {
        internal ResourceValue(string id, string name, string type, JObject value, string[] dependencies, TemplateContext.CopyIndexState copy)
            : base(id, name, dependencies)
        {
            Type = type;
            Value = value;
            Copy = copy;
        }

        public JObject Value { get; }

        public string Type { get; }

        public TemplateContext.CopyIndexState Copy { get; }
    }

    [DebuggerDisplay("{Id}")]
    internal sealed class DeploymentValue : BaseResourceValue, IResourceValue, ILazyObject
    {
        private const string RESOURCETYPE_DEPLOYMENT = "Microsoft.Resources/deployments";

        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_OUTPUTS = "outputs";

        private readonly Lazy<JObject> _Value;
        private readonly Dictionary<string, ILazyValue> _Outputs;

        internal DeploymentValue(string id, string name, JObject value, string[] dependencies, TemplateContext.CopyIndexState copy)
            : this(id, name, () => value, dependencies, copy) { }

        internal DeploymentValue(string id, string name, Func<JObject> value, string[] dependencies, TemplateContext.CopyIndexState copy)
            : base(id, name, dependencies)
        {

            _Value = new Lazy<JObject>(value);
            Copy = copy;
            Properties = new DeploymentProperties(this);
            _Outputs = new Dictionary<string, ILazyValue>(StringComparer.OrdinalIgnoreCase);
        }

        private sealed class DeploymentProperties : ILazyObject
        {
            private readonly DeploymentValue _Deployment;
            private readonly JObject _Properties;
            private readonly DeploymentOutputs _Outputs;

            public DeploymentProperties(DeploymentValue deployment)
            {
                _Deployment = deployment;
                _Deployment.Value.TryGetProperty(PROPERTY_PROPERTIES, out _Properties);
                _Outputs = new DeploymentOutputs(deployment);
            }

            public bool TryProperty(string propertyName, out object value)
            {
                value = null;
                if (StringComparer.OrdinalIgnoreCase.Equals(propertyName, PROPERTY_OUTPUTS))
                    value = _Outputs;
                else if (_Properties.TryGetProperty<JToken>(propertyName, out var token))
                    value = token;

                return value != null;
            }
        }

        private sealed class DeploymentOutputs : ILazyObject
        {
            private readonly DeploymentValue _Deployment;

            public DeploymentOutputs(DeploymentValue deployment)
            {
                _Deployment = deployment;
            }

            public bool TryProperty(string propertyName, out object value)
            {
                value = null;
                if (!_Deployment._Outputs.TryGetValue(propertyName, out var lazy))
                    return false;

                value = lazy.GetValue();
                return true;
            }
        }

        public JObject Value => _Value.Value;

        public string Type => RESOURCETYPE_DEPLOYMENT;

        public TemplateContext.CopyIndexState Copy { get; }

        public ILazyObject Properties { get; }

        public void AddOutput(string name, ILazyValue output)
        {
            _Outputs.Add(name, output);
        }

        internal bool TryOutput(string name, out object value)
        {
            value = null;
            if (!_Outputs.TryGetValue(name, out var lazy))
                return false;

            value = lazy.GetValue();
            return true;
        }

        public bool TryProperty(string propertyName, out object value)
        {
            value = null;
            if (StringComparer.OrdinalIgnoreCase.Equals(propertyName, PROPERTY_PROPERTIES))
                value = Properties;
            else if (Value.TryGetProperty<JToken>(propertyName, out var token))
                value = token;

            return value != null;
        }
    }
}
