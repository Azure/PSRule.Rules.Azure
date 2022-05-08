# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for unit testing
#

# Synopsis: Rule for testing SupportsTags legacy function.
Rule 'Test.SupportsTags' -If { (SupportsTags) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.Fail();
}
