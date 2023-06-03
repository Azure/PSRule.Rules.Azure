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
            if (x.DependsOn(y, out var xc))
                return 1;

            if (y.DependsOn(x, out var yc))
                return -1;

            if (xc == 0 && yc == 0)
                return 0;

            if (yc == 0) return 1;
            if (xc == 0) return -1;

            return 0;

            //return xc == 0 && yc == 0 ? 0 : yc == 0 || yc > 0 ? -1 : 1;
        }
    }
}
