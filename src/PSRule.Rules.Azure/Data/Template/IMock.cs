// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

#nullable enable

namespace PSRule.Rules.Azure.Data.Template;

internal interface IMock
{
    TypePrimitive BaseType { get; }

    bool IsSecret { get; }

    TValue? GetValue<TValue>();

    JToken? GetValue(TypePrimitive type);

    JToken? GetValue(object key);

    string GetString();
}

#nullable restore
