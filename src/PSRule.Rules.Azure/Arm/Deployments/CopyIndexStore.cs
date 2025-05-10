// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure.Arm.Deployments;

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

    /// <summary>
    /// The current copy index loop being processed.
    /// </summary>
    public CopyIndexState Current => _Current.Count > 0 ? _Current.Peek() : null;

    /// <summary>
    /// Add state for a new copy loop to the store.
    /// </summary>
    /// <param name="state">The state of a copy loop.</param>
    public void Add(CopyIndexState state)
    {
        _Index[state.Name] = state;
    }

    /// <summary>
    /// Remove state for a copy loop from the store.
    /// </summary>
    public void Remove(CopyIndexState state)
    {
        if (_Current.Contains(state))
            return;

        if (_Index.ContainsValue(state))
            _Index.Remove(state.Name);
    }

    /// <summary>
    /// Add a new copy index state to the store and make it the current state.
    /// </summary>
    /// <param name="state">The state of a copy loop.</param>
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

    /// <summary>
    /// Remove the current copy index state from the store and make the previous state the current state.
    /// </summary>
    public void Pop()
    {
        var state = _Current.Pop();
        if (_CurrentResourceType.Count > 0 && _CurrentResourceType.Peek() == state)
            _CurrentResourceType.Pop();

        _Index.Remove(state.Name);
    }

    /// <summary>
    /// Get the copy index by name.
    /// </summary>
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
