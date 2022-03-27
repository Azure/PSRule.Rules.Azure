// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure
{
    internal sealed class ResourceDependencyComparer : IComparer<IResourceValue>
    {
        public int Compare(IResourceValue x, IResourceValue y)
        {
            if (x.DependsOn(y))
                return 1;

            return y.DependsOn(x) ? -1 : 0;
        }
    }
}
