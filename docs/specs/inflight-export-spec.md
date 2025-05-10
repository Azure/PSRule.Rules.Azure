# Design spec for export of in-flight resource data

To support analysis of in-flight resources, the configuration data must be exported from Azure.
This spec documents this mode of operation.

## Requirements

The requirements for this feature/ mode of operation include:

- Export resources, resource groups, and subscription configuration.
- Export related sub-resource configuration data to support rules.

Additionally some non-function requirements include:

- Gracefully handle Azure management API throttling.
- Limit exported data based on filters.
