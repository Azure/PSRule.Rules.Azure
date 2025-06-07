---
reviewed: 2025-06-07
description: Learn how to create a pull request to contribute rules to PSRule for Azure.
discussion: false
---

# Pull Request

## Commit your changes

Once your changes are ready, commit your changes to your fork:

```bash title="Git"
git add .
git commit -m "Brief description of your changes"
git push origin YOUR_BRANCH
```

## Submit a pull request (PR)

- Go to your forked repository on GitHub.
- Click on "Compare & pull request."
- In the provided PR template provide a clear and concise description of your changes.

### Review and approval

What you can expect from review and approval of your contribution:

- **Once your PR is submitted** &mdash; project maintainers will review your changes and make suggestions or comments.
  Be prepared to make updates based on feedback until your PR is approved.
  If you are unclear on the feedback you can comment in the PR to get clarification.
- **Automated CI tests** &mdash; for your PR do not run automatically, a maintainer must approve running the workflow.
  Once approved, if any automated CI tests fail be prepared to test your changes locally and update your branch.
  If you get stuck, you can comment in the PR to ask questions.
- **Update your PR** &mdash; by adding commits to your branch and pushing changes to GitHub.
  After a few moments your PR will update with your latest changes.
  Avoid using forced pushes or squashing changes while your PR is active, as this makes it harder to review your changes.
- **Contributor License Agreement (CLA)** &mdash; The Microsoft policy bot may request you accept the CLA.
  Please read and follow the instructions of the bot to complete acceptance of the Microsoft CLA.
  We can not approve and merge your PR if it is flagged by the bot until the CLA is accepted.
- **After PR approval** &mdash; your PR will be merged into the main repository by the maintainers.
