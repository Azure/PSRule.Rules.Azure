# Azure Security Benchmark

Azure Security Benchmark (ASB) es un conjunto de controles y recomendaciones que ayudan a mejorar la seguridad de las cargas de trabajo en Azure.
Los controles del ASB también se asignan a los marcos de la industria, como CIS, PCI-DSS y NIST.
Si esta es su primera introduccion a ASB o esta busecano por ayudo a como utilizarlo, refiera a la [Introducción a Azure Security Benchmark][1]

[1]: https://learn.microsoft.com/security/benchmark/azure/introduction

## Azure Security Benchmark v3

Esta es la versión mas reciente del ASB.
Las reglas incluidas en PSRule para Azure se han asignado a [v3][2] para que pueda comprender el impacto de las reglas.
Esto es particularmente útil cuando busca comprender cómo abordar un requisito de cumplimiento específico de su organización.

Los siguientes controles están incluidos en Azure Security Benchmark v3:

- [Seguridad de red (NS)][3]
- [Administración de identidades (IM)][4]
- [Acceso con privilegios (PA)][5]
- [Protección de datos (DP)][6]
- [Administración de recursos (AM)][7]
- [Registro y detección de amenazas (LT)][8]
- [Respuesta a incidentes IR)][9]
- [Posición y administración de vulnerabilidades (PV)][10]
- [Seguridad de los puntos de conexión (ES)][11]
- [Copia de seguridad y recuperación (BR)][12]
- [Seguridad de DevOps (DS)][13]
- [Gobernanza y estrategia (GS)][14]

  [2]: https://learn.microsoft.com/security/benchmark/azure/overview
  [3]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-network-security
  [4]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management
  [5]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-privileged-access
  [6]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-data-protection
  [7]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-asset-management
  [8]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-logging-threat-detection
  [9]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-incident-response
  [10]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-posture-vulnerability-management
  [11]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-endpoint-security
  [12]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-backup-recovery
  [13]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-devops-security
  [14]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-governance-strategy

<!-- ### Using the ASB v3 baseline with PSRule

:octicons-milestone-24: v1.nn.0

To start using the ASB v3 baseline with PSRule configure the baseline parameter to use `Azure.SecurityBenchmark.v3`.

!!! Note
    It's important to note that the ASB v3 baseline is reduced set of rules.
    Not all rules for the Well-Architected Framework are included in ASB v3. -->

## Links

- [Introducción a los controles de seguridad de Azure (v3)][2]
