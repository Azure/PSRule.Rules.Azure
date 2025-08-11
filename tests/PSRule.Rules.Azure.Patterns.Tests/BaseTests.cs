// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

public abstract class BaseTests
{
    protected static string GetSourcePath(string fileName)
    {
        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
    }

    protected static string GetContent(string fileName)
    {
        var path = GetSourcePath(fileName);
        return File.ReadAllText(path);
    }
}
