---
severity: Awareness
category: Cost management
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VM.PromoSku.md
---

# Azure.VirtualMachine.PromoSku

## SYNOPSIS

Virtual machines (VMs) should not use expired promotional SKU.

## DESCRIPTION

Some VM sizes may offer promotional rates that can be used by deploying VMs with a designated SKU. Promotional rates expire, and while this does not cause interruption to running VMs, the rate that VMs are billed at returns to the original price.

Promo SKUs are not eligible for savings from reserved instances. Expired promo SKUs may confuse billing reconciliation when the promotional period expires.

VMs should not use expired promo SKU.

## RECOMMENDATION

Consider moving from promotional SKUs to SKUs eligible for reserved instances for VMs with an extended life cycle. Consider moving from promotional SKUs to the regular SKU once the promotional period has expired.
