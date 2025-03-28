// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// Stores the state of a copy index loop.
/// </summary>
public sealed class CopyIndexStore
{
    private readonly Dictionary<string, CopyIndexState> _Index;
    private readonly Stack<CopyIndexState> _Current;
    private readonly Stack<CopyIndexState> _CurrentResourceType;

    internal CopyIndexStore()
    {
        _Index = [];
        _Current = new Stack<CopyIndexState>();
        _CurrentResourceType = new Stack<CopyIndexState>();
    }

    public CopyIndexState Current => _Current.Count > 0 ? _Current.Peek() : null;

    public void Add(CopyIndexState state)
    {
        _Index[state.Name] = state;
    }

    public void Remove(CopyIndexState state)
    {
        if (_Current.Contains(state))
            return;

        if (_Index.ContainsValue(state))
            _Index.Remove(state.Name);
    }

    public void Push(CopyIndexState state)
    {
        _Current.Push(state);
        _Index[state.Name] = state;
    }

    internal void PushResourceType(CopyIndexState state)
    {
        Push(state);
        _CurrentResourceType.Push(state);
    }

    public void Pop()
    {
        var state = _Current.Pop();
        if (_CurrentResourceType.Count > 0 && _CurrentResourceType.Peek() == state)
            _CurrentResourceType.Pop();

        _Index.Remove(state.Name);
    }

    public bool TryGetValue(string name, out CopyIndexState state)
    {
        if (name == null)
        {
            state = _CurrentResourceType.Count > 0 ? _CurrentResourceType.Peek() : Current;
            return state != null;
        }
        return _Index.TryGetValue(name, out state);
    }
}
