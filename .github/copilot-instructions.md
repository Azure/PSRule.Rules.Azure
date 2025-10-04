Rule Development Context:

- To determine the correct rule reference number (e.g. AZR-XXXXXX) for new rules, find the next available number in the `docs/en/rules/index.md` file.
- Current rule set version to use (e.g. 2025_06, 2025_09...) based on release schedule use the next quarter based on the current date.
- Use the documentation in `docs/license-contributing/metadata-reference.md` to determine the correct metadata tags and labels for rules.

File Management Context:

- Do not update auto-generated files which are typically found in `docs/en/baselines/` or other `.md` files that have the `generated: true` tag in their front matter.

Documentation Standards Context:

- Any links starting with `https://learn.microsoft.com/` should not include locale codes (e.g., `en-us`).

Updating the change log:

- After completing updates, update the change log in `docs/changelog.md` with a high-level one or two-line summary of the changes and the linked issue.
- Change log entries are added as a new bullet point with the issue number in square brackets, under the Unreleased section.
