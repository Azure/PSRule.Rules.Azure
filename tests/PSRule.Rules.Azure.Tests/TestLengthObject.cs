// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure;

internal sealed class TestLengthObject
{
    public TestLengthObject()
    {
        propC = "three";
        propD = new ChildObject();
    }

    internal sealed class ChildObject
    {
        public string prop1 => "sub";

        public string prop2 => "sub";
    }

    public string propA => "one";

    public string propB => "two";

    public string propC { get; set; }

    public ChildObject propD { get; set; }
}
