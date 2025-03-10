---
author: BernieWhite
type: SuppressionGroup
---

# Suppress geo-replication in dev

A suppression group to suppress geo-replication rules in dev.

## Summary

This sample shows how to create a suppression group that suppresses geo-replication rules in dev environments.
The suppression group identifies resources that are deployed in a dev environment by looking for the `env` = `dev` tag.

The suppression group then suppresses the following rules:

- `Azure.ACR.GeoReplica`
- `Azure.Storage.UseReplication`

## Usage

- Copy the `SuppressGeoReplicationInDev.Rule.yaml` file to your default include path `.ps-rule/`.

## References

- [Suppression](https://azure.github.io/PSRule.Rules.Azure/concepts/suppression/)
- [Suppression group reference](https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_SuppressionGroups/)
