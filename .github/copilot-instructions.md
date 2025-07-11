Rule Development Context:

- To determine the correct rule reference number (e.g. AZR-XXXXXX) for new rules, find the next available number in the `docs/en/rules/index.md` file.
- Current rule set version to use (e.g. 2025_06, 2025_09...) based on release schedule use the next quarter based on the current date.

File Management Context:

- Do not update auto-generated files which are typically found in `docs/en/baselines/` or have the `generated: true` tag in their front matter.

Documentation Standards Context:

- Any links starting with `https://learn.microsoft.com/` should not include locale codes (e.g., `en-us`).
