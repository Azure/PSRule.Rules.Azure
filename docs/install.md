---
author: BernieWhite
---

# How to install PSRule for Azure

PSRule for Azure supports running within continuous integration (CI) systems or locally.
It is shipped as a PowerShell module which makes it easy to install and distribute updates.

Task                                      | Options
----                                      | ------
Run tests within CI pipelines             | With [GitHub Actions][8] _or_ [Azure Pipelines][9] _or_ [PowerShell][10]
Run tests locally during development      | With [Visual Studio Code][11] _and_ [PowerShell][10]
Create custom tests for your organization | With [Visual Studio Code][11] _and_ [PowerShell][10]

!!! Tip
    PSRule for Azure provides native integration to popular CI systems such as GitHub Actions and Azure Pipelines.
    If you are using a different CI system you can use the local install to run on MacOS,
    Linux, and Windows worker nodes.

  [8]: #with-github-actions
  [9]: #with-azure-pipelines
  [10]: #with-powershell
  [11]: #with-visual-studio-code

## With GitHub Actions

[:octicons-workflow-24: GitHub Action][1]

Install and use PSRule for Azure with GitHub Actions by referencing the `microsoft/ps-rule` action.

=== "Stable"

    Install the latest stable version of PSRule for Azure.

    ```yaml title="GitHub Actions"
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
      with:
        modules: 'PSRule.Rules.Azure'
    ```

=== "Pre-release"

    Install the latest stable or pre-release version of PSRule for Azure.
 
    ```yaml title="GitHub Actions"
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
      with:
        modules: 'PSRule.Rules.Azure'
        prerelease: true
    ```

This will automatically install compatible versions of all dependencies.

!!! Note
    For additional examples on commonly configured parameters see [Creating your pipeline][12].

  [1]: https://github.com/marketplace/actions/psrule
  [12]: creating-your-pipeline.md

## With Azure Pipelines

[:octicons-workflow-24: Extension][2]

Install and use PSRule for Azure with Azure Pipeline by using extension tasks.
Install the extension from the marketplace, then use the `ps-rule-assert` task in pipeline steps.

=== "Stable"

    Install the latest stable version of PSRule for Azure.

    ```yaml title="Azure Pipelines"
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
    ```

=== "Pre-release"

    Install the latest stable or pre-release version of PSRule for Azure.

    ```yaml title="Azure Pipelines"
    - task: ps-rule-install@2
      displayName: Install PSRule for Azure (pre-release)
      inputs:
        module: PSRule.Rules.Azure
        prerelease: true

    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
    ```

This will automatically install compatible versions of all dependencies.

!!! Note
    For additional examples on commonly configured parameters see [Creating your pipeline][12].

  [2]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule

## With Visual Studio Code

[:octicons-download-24: Extension][5]

An extension for Visual Studio Code is available.
The Visual Studio Code extension includes a built-in task to test locally and configuration schemas.

<p align="center">
  <img src="https://raw.githubusercontent.com/microsoft/PSRule-vscode/main/docs/images/tasks-provider.png" alt="Built-in tasks shown in task list" />
</p>

To learn about Visual Studio Code support see the [marketplace extension][5].

For best results, configure the `PSRule.Rules.Azure` module using `ps-rule.yaml` by setting `requires` and `include` options.

```yaml title="ps-rule.yaml"
requires:
  PSRule.Rules.Azure: '>=1.29.0'

include:
  module:
  - PSRule.Rules.Azure
```

!!! Note
    Currently the Visual Studio Code extension relies on PSRule for Azure installed by PowerShell.

  [5]: https://marketplace.visualstudio.com/items?itemName=bewhite.psrule-vscode

## With PowerShell

PSRule for Azure can be installed locally from the PowerShell Gallery using PowerShell.
You can also use this option to install on CI workers that are not natively supported.

### Prerequisites

Operating System      | Tool                                                         | Installation Link
----------------      | ----                                                         | -----------------
Windows               | Windows PowerShell 5.1 with .NET Framework 4.7.2 or greater. |  [link](https://dotnet.microsoft.com/download/dotnet-framework/net48)
Windows, MacOS, Linux | PowerShell version 7.4.x or greater. | [link](https://github.com/PowerShell/PowerShell#get-powershell)

To use PSRule for Azure, PSRule a separate PowerShell module must be installed.
The required version will automatically be installed along-side PSRule for Azure.

Additionally, the exporting data from a subscription functionality requires the additional
PowerShell modules:

- Az.Accounts
- Az.Resources

!!! Note
    Azure PowerShell modules are not installed automatically when installing PSRule for Azure.
    This has been changed from v1.16.0 due to [module dependency chains in Azure DevOps][3].
    In most cases these modules will be pre-installed on the CI worker.
    For private CI workers, consider pre-installing these modules in a previous step.

  [3]: troubleshooting.md#issues-with-azresources

### Installing PowerShell

PowerShell 7.x can be installed on MacOS, Linux, and Windows but is not installed by default.
For a list of platforms that PowerShell 7.4 is supported on and install instructions see [Get PowerShell][4].

  [4]: https://github.com/PowerShell/PowerShell#get-powershell

### Getting the modules

[:octicons-download-24: Module][module]

PSRule for Azure can be installed or updated from the PowerShell Gallery.
Use the following command line examples from a PowerShell terminal to install or update PSRule for Azure.

=== "For the current user"
    To install PSRule for Azure for the current user use:

    ```powershell
    Install-Module -Name 'PSRule.Rules.Azure' -Repository PSGallery -Scope CurrentUser
    ```

    To update PSRule for Azure for the current user use:

    ```powershell
    Update-Module -Name 'PSRule.Rules.Azure' -Scope CurrentUser
    ```

    This will automatically install compatible versions of all dependencies.

=== "For all users"
    To install PSRule for Azure for all users (requires admin/ root permissions) use:

    ```powershell
    Install-Module -Name 'PSRule.Rules.Azure' -Repository PSGallery -Scope AllUsers
    ```

    To update PSRule for Azure for all users (requires admin/ root permissions) use:

    ```powershell
    Update-Module -Name 'PSRule.Rules.Azure' -Scope AllUsers
    ```

    This will automatically install compatible versions of all dependencies.

### Pre-release versions

To use a pre-release version of PSRule for Azure add the `-AllowPrerelease` switch when calling `Install-Module`,
`Update-Module`, or `Save-Module` cmdlets.

!!! Tip
    To install pre-release module versions, the latest version of _PowerShellGet_ may be required.

    ```powershell
    # Install the latest PowerShellGet version
    Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force
    ```

!!! Tip
    To install a pre-release version of _PSRule_ and _PSRule for Azure_, install each in separate steps.

=== "For the current user"
    To install PSRule for Azure for the current user use:

    ```powershell
    Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force
    Install-Module -Name PSRule -Repository PSGallery -Scope CurrentUser -AllowPrerelease
    Install-Module -Name PSRule.Rules.Azure -Repository PSGallery -Scope CurrentUser -AllowPrerelease
    ```

=== "For all users"
    Open PowerShell with _Run as administrator_ on Windows or `sudo pwsh` on Linux.

    To install PSRule for Azure for all users (requires admin/ root permissions) use:

    ```powershell
    Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force
    Install-Module -Name PSRule -Repository PSGallery -Scope AllUsers -AllowPrerelease
    Install-Module -Name PSRule.Rules.Azure -Repository PSGallery -Scope AllUsers -AllowPrerelease
    ```

## Building from source

[:octicons-file-code-24: Source][6]

PSRule for Azure is provided as open source on GitHub.
To build PSRule for Azure from source code:

1. Clone the GitHub [repository][6].
2. Run `./build.ps1` from a PowerShell terminal in the cloned path.

This build script will compile the module and documentation then output the result into `out/modules/PSRule.Rules.Azure`.

  [6]: https://github.com/Azure/PSRule.Rules.Azure.git

### Development dependencies

| Operating System | Tool               | Overview | Installation Link |
| ---------------- | ----               | -------- | ----------------- |
| Windows          | Windows PowerShell | Support for version 5.1 with .NET Framework 4.7.2 or greater. |  [link](https://dotnet.microsoft.com/download/dotnet-framework/net48) |
| Windows, MacOS, Linux | PowerShell    | Version 7.4 or greater is support. | [link](https://github.com/PowerShell/PowerShell#get-powershell) |
| -                | -                  | Multiple PowerShell modules are required (PlatyPS, Pester, PSScriptAnalyzer, PowerShellGet, PackageManagement, InvokeBuild, PSRule). | Installed when you run the `build.ps1` script |
| -                | .NET               | .NET SDK v8 is required. | [link](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) |
| -                | Bicep CLI          | PSRule depends on the Bicep CLI to expand Bicep modules to ARM | [link](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) |

The following dependencies will be automatically installed if the required versions are not present:

- PowerShell modules:
  - PlatyPS
  - Pester
  - PSScriptAnalyzer
  - PowerShellGet
  - PackageManagement
  - InvokeBuild
- Bicep CLI

These dependencies are only required for building and running tests for PSRule for Azure.

### Troubleshooting

If the `./build.ps1` script fails, you can start troubleshooting this by:

- Checking the prerequisites are installed installed (and the specific versions)
  - Check the **PowerShell** version enter the following statement in the PowerShell terminal: `$PSVersionTable.PSVersion`
  - Check the installed **.NET** version by entering the `dotnet --list-sdks` command in your terminal.
- Check if your .NET setup is connected to any Nuget repositories and if there's any connectivity or authentication issues.
- Installation of some pre-reqs may require admin privileges.

## Limited access networks

If you are on a network that does not permit Internet access to the PowerShell Gallery,
download the required PowerShell modules on an alternative device that has access.
PowerShell provides the `Save-Module` cmdlet that can be run from a PowerShell terminal to do this.

The following command lines can be used to download the required modules using a PowerShell terminal.
After downloading the modules, copy the module directories to devices with restricted Internet access.

=== "Runtime modules"
    To save PSRule for Azure for offline use:

    ```powershell
    $modules = @('PSRule', 'PSRule.Rules.Azure', 'Az.Accounts', 'Az.Resources')
    Save-Module -Name $modules -Path '.\modules'
    ```

    This will save PSRule for Azure and all dependencies into the `modules` sub-directory.

=== "Development modules"
    To save PSRule for Azure development module dependencies for offline use:

    ```powershell
    $modules = @('PSRule', 'Az.Accounts', 'Az.Resources', 'PlatyPS', 'Pester',
      'PSScriptAnalyzer', 'PowerShellGet', 'PackageManagement', 'InvokeBuild')
    Save-Module -Name $modules -Repository PSGallery -Path '.\modules';
    ```

    This will save required developments dependencies into the `modules` sub-directory.

*[CI]: continuous integration

[module]: https://www.powershellgallery.com/packages/PSRule.Rules.Azure
