Update resource-type-mapping static content

Purpose

This prompt instructs an automated agent to run the repository script that (re)generates the static resource type mapping and to safely commit the results when they change.

Frequency

Run regularly (suggested: weekly) or on-demand when resource provider updates are suspected.

Steps

1. Ensure a clean git workspace: `git status --porcelain` must be empty.
2. Create a branch named `update/resource-type-mapping/YYYYMMDD` (use today's date).
3. From the repository root run the script with PowerShell (Windows) or pwsh (cross-platform):

   pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/resource-type-mapping.ps1

   - If the script accepts output arguments, follow the script's documented parameters. The agent MUST not modify the script.

4. The script should update the single canonical file `data/resource-type-mapping.json`.
5. Validate the generated JSON exists and is well-formed. If not, abort and signal human review.

6. If generated files differ from the committed versions, stage only those files and any related docs (do not stage unrelated changes):

   git add data/resource-type-mapping.json

7. The change log must not be updated for this change.

8. Commit with a clear message and author identity representing the automation, for example:

   git commit -m "Update resource-type-mapping: YYYY-MM-DD"

10. Push the branch and open a pull request targeting `main` with a brief description of what changed and why. Include the list of changed files and a short note about the validation steps performed.

Safety and review

- Do not change other repository files. If other changes are detected, abort and signal human review.
- If the script or generated data causes failing tests, leave the branch for human review rather than merging automatically.
- The PR should request review from at least one repository maintainer.

Commit and PR conventions

- Branch name: `update/resource-type-mapping/YYYYMMDD`
- Commit message: `Update resource-type-mapping: YYYY-MM-DD`
- PR title: `Update resource-type-mapping (YYYY-MM-DD)`
- PR body: include steps run, validation results, and files changed.

Example agent checklist (for the PR description)
- Ran: `pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/resource-type-mapping.ps1`
- Validated JSON formatting
- Ran tests: `Invoke-Build Test -AssertStyle Client` (pass/fail)
- Files changed: `data/resource-type-mapping.json`
