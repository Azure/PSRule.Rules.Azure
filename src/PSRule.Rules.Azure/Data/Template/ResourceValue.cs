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

        string Type { get; }

        TemplateContext.CopyIndexState Copy { get; }

        bool DependsOn(string id);
    }

    internal static class ResourceValueExtensions
    {
        public static bool DependsOn(this IResourceValue resource, IResourceValue other)
        {
            return resource.DependsOn(other.Id);
        }
    }

    [DebuggerDisplay("{Id}")]
    internal sealed class ResourceValue : IResourceValue
    {
        private readonly HashSet<string> _Dependencies;

        internal ResourceValue(string id, string type, JObject value, string[] dependencies, TemplateContext.CopyIndexState copy)
        {
            Id = id;
            Type = type;
            Value = value;
            Copy = copy;
            _Dependencies = dependencies == null || dependencies.Length == 0 ? null : new HashSet<string>(dependencies, StringComparer.OrdinalIgnoreCase);
        }

        public JObject Value { get; }

        public string Id { get; }

        public string Type { get; }

        public TemplateContext.CopyIndexState Copy { get; }

        public bool DependsOn(string id)
        {
            return _Dependencies != null && _Dependencies.Contains(id);
        }
    }

    [DebuggerDisplay("{Id}")]
    internal sealed class DeploymentValue : IResourceValue, ILazyObject
    {
        private const string RESOURCETYPE_DEPLOYMENT = "Microsoft.Resources/deployments";

        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_OUTPUTS = "outputs";

        private readonly HashSet<string> _Dependencies;
        private readonly Lazy<JObject> _Value;
        private readonly Dictionary<string, ILazyValue> _Outputs;

        internal DeploymentValue(string id, JObject value, string[] dependencies, TemplateContext.CopyIndexState copy)
            : this(id, () => value, dependencies, copy) { }

        internal DeploymentValue(string id, Func<JObject> value, string[] dependencies, TemplateContext.CopyIndexState copy)
        {
            Id = id;
            _Value = new Lazy<JObject>(value);
            Copy = copy;
            _Dependencies = dependencies == null || dependencies.Length == 0 ? null : new HashSet<string>(dependencies, StringComparer.OrdinalIgnoreCase);
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

        public string Id { get; }

        public string Type => RESOURCETYPE_DEPLOYMENT;

        public TemplateContext.CopyIndexState Copy { get; }

        public ILazyObject Properties { get; }

        public bool DependsOn(string id)
        {
            return _Dependencies != null && _Dependencies.Contains(id);
        }

        public void AddOutput(string name, ILazyValue output)
        {
            _Outputs.Add(name, output);
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
