
!!! Security "Secret rotation &mdash; [SE:09 Application secrets](https://learn.microsoft.com/azure/well-architected/security/application-secrets#secret-rotation)"
    If a secret has already been exposed by a previous insecure deployment,
    rotate it immediately to prevent unauthorized access to your resources.

    Rotating a secret involves changing or regenerating the secret value and updating all dependent resources with the new value.
    This process should be done in a secure manner to prevent the new secret from being exposed.
