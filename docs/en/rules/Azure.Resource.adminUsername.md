---
severity: Awareness
pillar: Security
category: Design
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Resource.adminUsername/
---

# Administrator Username Types

## SYNOPSIS

The adminUsername or administratorUsername property should not be a string literal in nested templates.

## DESCRIPTION

In nested deployments a resource can have the adminUsername property set to a string literal value.
This means that the value is passed through insecurely and is a security risk.

## RECOMMENDATION

Resources should use a secureString type when specifying the adminUsername for nested resources.
