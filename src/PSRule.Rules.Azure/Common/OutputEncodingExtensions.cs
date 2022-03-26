// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure
{
    internal static class OutputEncodingExtensions
    {
        /// <summary>
        /// Get the character encoding for the specified output encoding.
        /// </summary>
        /// <param name="encoding"></param>
        /// <returns></returns>
        internal static Encoding GetEncoding(this OutputEncoding? encoding)
        {
            switch (encoding)
            {
                case OutputEncoding.UTF8:
                    return Encoding.UTF8;

                case OutputEncoding.UTF7:
                    return Encoding.UTF7;

                case OutputEncoding.Unicode:
                    return Encoding.Unicode;

                case OutputEncoding.UTF32:
                    return Encoding.UTF32;

                case OutputEncoding.ASCII:
                    return Encoding.ASCII;

                default:
                    return new UTF8Encoding(encoderShouldEmitUTF8Identifier: false);
            }
        }
    }
}