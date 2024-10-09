// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure;

[DebuggerDisplay("Path: {Path}, Line:{LineNumber}, Position:{LinePosition}")]
internal sealed class TemplateTokenAnnotation : IJsonLineInfo
{
    private bool _HasLineInfo;

    public TemplateTokenAnnotation()
    {

    }

    public TemplateTokenAnnotation(int lineNumber, int linePosition, string path)
    {
        SetLineInfo(lineNumber, linePosition);
        Path = path;
    }

    public int LineNumber { get; private set; }

    public int LinePosition { get; private set; }

    public string Path { get; private set; }

    public bool HasLineInfo()
    {
        return _HasLineInfo;
    }

    private void SetLineInfo(int lineNumber, int linePosition)
    {
        LineNumber = lineNumber;
        LinePosition = linePosition;
        _HasLineInfo = true;
    }
}
