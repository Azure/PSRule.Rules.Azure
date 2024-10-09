// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json.Linq;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure.Data.Template;

#nullable enable

[DebuggerDisplay("{Id}")]
internal sealed class ExistingResourceValue : IResourceValue
{
    private const string PROPERTY_SCOPE = "scope";
    private const string PROPERTY_SUBSCRIPTIONID = "subscriptionId";
    private const string PROPERTY_RESOURCEGROUP = "resourceGroup";

    private readonly ITemplateContext _Context;

    private string? _Id;
    private string? _Name;


    public ExistingResourceValue(ITemplateContext context, string type, string symbolicName, JObject value, TemplateContext.CopyIndexState copy)
    {
        _Context = context;
        Type = type;
        SymbolicName = symbolicName;
        Value = value;
        Copy = copy;
    }

    /// <inheritdoc/>
    public string Id
    {
        get
        {
            return _Id ?? GetId();
        }
    }

    /// <inheritdoc/>
    public string Name
    {
        get
        {
            return _Name ?? GetName();
        }
    }

    /// <inheritdoc/>
    public string SymbolicName { get; }

    /// <inheritdoc/>
    public string Type { get; }

    /// <inheritdoc/>
    public JObject Value { get; }

    /// <inheritdoc/>
    public bool Existing => true;

    /// <inheritdoc/>
    public TemplateContext.CopyIndexState Copy { get; }

    /// <summary>
    /// Expand <c>id</c> on demand.
    /// </summary>
    /// <returns></returns>
    private string GetId()
    {
        if (!Value.TryResourceScope(_Context, out var scopeId))
            throw new TemplateSymbolException(SymbolicName);

        return _Id = ResourceHelper.ResourceId(Type, Name, scopeId);
    }

    /// <summary>
    /// Expand <c>name</c> on demand.
    /// </summary>
    private string GetName()
    {
        if (!Value.TryResourceName(out var name) || string.IsNullOrEmpty(name))
            throw new TemplateSymbolException(SymbolicName);

        return _Name = name.IsExpressionString() ? name.ToString() : name;
    }
}

#nullable restore
