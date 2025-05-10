// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Deployments;

[DebuggerDisplay("{Id}")]
internal sealed class DeploymentValue : BaseResourceValue, IResourceValue, ILazyObject
{
    private const string RESOURCE_TYPE_DEPLOYMENT = "Microsoft.Resources/deployments";

    private const string PROPERTY_PROPERTIES = "properties";
    private const string PROPERTY_OUTPUTS = "outputs";

    private readonly Lazy<JObject> _Value;
    private readonly Dictionary<string, ILazyValue> _Outputs;

    internal DeploymentValue(string id, string name, string symbolicName, string scope, DeploymentScope deploymentScope, JObject value, CopyIndexState copy)
        : this(id, name, symbolicName, scope, deploymentScope, () => value, copy) { }

    internal DeploymentValue(string id, string name, string symbolicName, string scope, DeploymentScope deploymentScope, Func<JObject> value, CopyIndexState copy)
        : base(id, name, symbolicName)
    {
        _Value = new Lazy<JObject>(value);
        Copy = copy;
        Properties = new DeploymentProperties(this);
        _Outputs = new Dictionary<string, ILazyValue>(StringComparer.OrdinalIgnoreCase);
        Scope = scope;
        DeploymentScope = deploymentScope;
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

    private sealed class DeploymentOutputs : JObject, ILazyObject
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

        public override JToken this[object key]
        {
            get
            {
                return key is string propertyName && TryProperty(propertyName, out var o) ? JToken.FromObject(o) : default;
            }
            set
            {

            }
        }
    }

    /// <inheritdoc/>
    public JObject Value => _Value.Value;

    /// <inheritdoc/>
    public string Type => RESOURCE_TYPE_DEPLOYMENT;

    /// <inheritdoc/>
    public bool Existing => false;

    /// <inheritdoc/>
    public CopyIndexState Copy { get; }

    public ILazyObject Properties { get; }

    public string Scope { get; }

    public DeploymentScope DeploymentScope { get; }

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
