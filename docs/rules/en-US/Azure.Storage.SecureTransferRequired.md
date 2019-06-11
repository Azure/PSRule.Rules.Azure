---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Storage.SecureTransferRequired.md
---

# Azure.Storage.SecureTransferRequired

## SYNOPSIS

Storage accounts should only accept secure traffic.

## DESCRIPTION

An Azure Storage Account is configured to allow unencrypted connections.

Unencrypted communication to storage accounts could allow disclosure of information to an untrusted party.

This does not indicate that unencrypted connections are being used.

## RECOMMENDATION

Storage accounts should only accept secure traffic.

Storage Accounts can be configured to require encrypted connections, this is done by setting the _Secure transfer required_ option. If _secure transfer required_ is not enabled (the default), unencrypted and encrypted connections are permitted.

When _secure transfer required_ is enabled, attempts to connect to storage using HTTP or unencrypted SMB connections are rejected.

Consider _setting secure transfer_ required if there is no requirement to access storage over unencrypted connections.

For more information see [Require secure transfer in Azure Storage](https://docs.microsoft.com/en-au/azure/storage/common/storage-require-secure-transfer) and [sample policy for ensuring https traffic](https://docs.microsoft.com/en-au/azure/governance/policy/samples/ensure-https-stor-acct).
