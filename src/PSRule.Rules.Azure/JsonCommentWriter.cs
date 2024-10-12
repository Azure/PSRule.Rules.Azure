// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure;

internal sealed class JsonCommentWriter(TextWriter textWriter) : JsonTextWriter(textWriter)
{
    public override void WriteComment(string text)
    {
        SetWriteState(JsonToken.Comment, text);
        if (Indentation > 0 && Formatting == Formatting.Indented)
            WriteIndent();
        else
            WriteRaw(Environment.NewLine);

        WriteRaw("// ");
        WriteRaw(text);
        if (Indentation == 0 || Formatting == Formatting.None)
            WriteRaw(Environment.NewLine);
    }
}
