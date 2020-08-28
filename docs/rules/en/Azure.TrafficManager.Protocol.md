---
severity: Important
pillar: Security
category: Encryption
resource: Traffic Manager
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.TrafficManager.Protocol.md
---

# Use HTTPS to monitor web-based endpoints

## SYNOPSIS

Monitor Traffic Manager web-based endpoints with HTTPS.

## DESCRIPTION

Traffic Manager can use TCP, HTTP or HTTPS to monitor endpoint health.
For web-based endpoints use HTTPS.

If TCP is used, Traffic Manager only checks that it can open a TCP port on the endpoint.
This alone does not indicate that the endpoint is operational and ready to receive requests.
Additionally when using HTTP and HTTPS, Traffic Manager check HTTP response codes.

If HTTP is used, Traffic Manager will send unencrypted health checks to the endpoint.
HTTPS-based health checks additionally check if a certificate is present,
but do not validate if the certificate is valid.

## RECOMMENDATION

Consider using HTTPS to monitor web-based endpoint health.
HTTPS-based monitoring improves security and increases accuracy of health probes.

## LINKS

- [Traffic Manager endpoint monitoring](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-monitoring)
