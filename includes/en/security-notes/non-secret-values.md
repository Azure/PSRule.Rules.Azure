
!!! Security "Don't treat non-secrets like secrets &mdash; [SE:09 Application secrets](https://learn.microsoft.com/azure/well-architected/security/application-secrets)"
    Secrets require operational rigor that's unnecessary for non-secrets.
    This might result in additional resource management overhead and operational costs, such as:

    - Increased Key Vault transaction costs.
    - Security Information and Event Management (SIEM) integration and regular auditing and monitoring of secret usage.
    - Management overhead additional complexity to regularly rotate secrets.
