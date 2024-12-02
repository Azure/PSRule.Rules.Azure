# Getting Started with Contributing to PSRule for Azure

Welcome to PSRule for Azure! We are excited to have you contribute to the project. This guide will walk you through the process of setting up your local development environment, understanding the project structure, and submitting your first contribution.

## 1. **Fork and Clone the Repository**

To start contributing, the first step is to fork the repository to your GitHub account and then clone it to your local machine.

1. **Fork the repository**:
   - Go to the [PSRule for Azure GitHub repository](https://github.com/Azure/PSRule.Rules.Azure).
   - Click the "Fork" button in the top-right corner.


2. **Clone your fork**:
   - Once the repository is forked, clone it to your local machine:
     ```bash
     git clone https://github.com/YOUR_USERNAME/PSRule.Rules.Azure.git
     cd PSRule.Rules.Azure
     ```


## 2. **Set Up Your Local Development Environment**

PSRule for Azure requires the following dependencies:

- **PowerShell** (for running the tests and contributing to the codebase).
- **PSRule.Rules.Azure** module (for testing Azure resources).
- **Az PowerShell module** (for interacting with Azure resources).

### Install Dependencies:

1. For development dependencies, refer to the [installation guide](https://azure.github.io/PSRule.Rules.Azure/install/#development-dependencies).

2. Install PSRule from GitHub if needed:
 
    ```
    Install-Module -Name 'PSRule' -Scope CurrentUser
    ```


## 3. **Understand the Project Structure**

Before you start coding, it's helpful to understand the organization of the repository.


## 4. **Contributing to Code**

Before writing a fix or feature enhancement, ensure that an issue is logged. Be prepared to discuss your feature and take feedback. Additionally, ensure that your changes include unit tests and any necessary updates to the documentation.

### Steps for Contributing Code:

1. Fork the PSRule.Rules.Azure repo: Follow the steps above to fork and clone the repository.

2. Create a new branch from `main` in your fork for your changes.

3. Add commits in your branch, making sure they are logically grouped and well-described.

4. If you have updated module code or rules, also update the `docs/CHANGELOG-v1.md`.
    - Note: You don't need to update the `docs/CHANGELOG-v1.md` for changes to unit tests or documentation.

5. Build your changes locally before pushing them. This ensures that they work as expected.

6. Create a Pull Request (PR):
    - Once you are ready for your changes to be reviewed, create a PR to merge changes into the PSRule `main` branch.
    - If your changes are not ready for review, create a draft pull request instead.

7. The Continuous Integration (CI) process will automatically build your changes. Ensure that your changes build successfully to be merged.
    - If there are build errors, push new commits to your branch to fix them.

8. Avoid using forced pushes or squashing changes while your PR is under review, as this makes it harder to review your changes.


## 5. **Building and Testing Your Changes**

Before opening a pull request, it’s important to build and test your changes locally. PSRule for Azure uses Continuous Integration (CI) pipelines to test changes across MacOS, Linux, and Windows configurations.

1. Build and Test Locally:
   - Ensure that you can build your changes locally. Follow the instructions in the [Building from Source](https://azure.github.io/PSRule.Rules.Azure/install/#building-from-source) guide to set up your local environment for testing.

2. Run All Tests:
    - Before creating your PR, run the tests to make sure your changes are working as expected:
      
       ```
       Invoke-Build Test -AssertStyle Client
       ```

### Example Unit Test

Here is an example of a unit test for validating rules:
[Azure.ACR.Tests.ps1 Example](https://github.com/Azure/psrule.rules.azure/blob/main/tests/PSRule.Rules.Azure.Tests/Azure.ACR.Tests.ps1#L40-L56)



## 6. **Submit Your Pull Request**

Once your changes are ready, submit your pull request:

1. Commit your changes:
    ```
    git add .
    git commit -m "Brief description of your changes"
    git push origin YOUR_BRANCH
    ```
    
2. Create a Pull Request:
   
- Go to your forked repository on GitHub.
- Click on "Compare & pull request."
- Provide a clear and concise description of your changes.


## 7. **Review and Merge**

Once your pull request is submitted, the project maintainers will review your changes. Be prepared to make updates based on feedback. After approval, your PR will be merged into the main repository.

## 8. **Stay Engaged**

   - Follow discussions and updates by subscribing to issues and PRs.
   - Keep up with the latest changes in the project by regularly pulling updates from the upstream repository.
   
   - Share feedback and help others when possible.


## 9. **Further Resources**

  - [Contributing Guide](https://github.com/Azure/PSRule.Rules.Azure/blob/main/CONTRIBUTING.md) – Detailed guidelines for contributing to the project.

  - [PSRule Documentation](https://github.com/microsoft/PSRule) – Learn about the PSRule engine used in this project.

  - [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) – Understand the principles that guide this project.
