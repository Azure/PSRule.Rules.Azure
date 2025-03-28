// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// State for a copy index operation.
/// </summary>
[DebuggerDisplay("{Name}: {Index} of {Count}")]
public sealed class CopyIndexState
{
    internal CopyIndexState()
    {
        Index = -1;
        Count = 1;
        Input = null;
        Name = null;
    }

    internal int Index { get; set; }

    internal int Count { get; set; }

    internal string Name { get; set; }

    internal JToken Input { get; set; }

    internal bool IsCopy()
    {
        return Name != null;
    }

    internal bool Next()
    {
        Index++;
        return Index < Count;
    }

    internal T CloneInput<T>() where T : JToken
    {
        return Input == null ? null : (T)Input.CloneTemplateJToken();
    }

    internal CopyIndexState Clone()
    {
        return new CopyIndexState
        {
            Index = Index,
            Count = Count,
            Input = Input,
            Name = Name
        };
    }
}
