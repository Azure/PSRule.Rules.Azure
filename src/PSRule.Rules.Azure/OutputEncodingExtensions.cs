// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure;

internal static class OutputEncodingExtensions
{
    /// <summary>
    /// Get the character encoding for the specified output encoding.
    /// </summary>
    /// <param name="encoding"></param>
    /// <returns></returns>
    internal static Encoding GetEncoding(this OutputEncoding? encoding)
    {
        return encoding switch
        {
            OutputEncoding.UTF8 => Encoding.UTF8,
            OutputEncoding.UTF7 => Encoding.UTF7,
            OutputEncoding.Unicode => Encoding.Unicode,
            OutputEncoding.UTF32 => Encoding.UTF32,
            OutputEncoding.ASCII => Encoding.ASCII,
            _ => new UTF8Encoding(encoderShouldEmitUTF8Identifier: false),
        };
    }
}
