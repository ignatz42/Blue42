
# Blue42

## Introduction

Blue42 is a PowerShell script module that facilitates the process of writing and using Azure Resource Manager (ARM) templates. At its' most basic, Blue42 converts an ARM template stored in Json format to a native PowerShell representation for manipulation. Blue42 provisions resources in 'Sessions' that define local connections between templates. Blue42 adds features that help generate default parameter values for templates during a session. Blue42 provides a tool that verifies deployment parameter match expected values.

## The Module

### Requirements

Blue42 requires the following modules to function as intended.

+ PowerShell Core 6.1
+ Az
+ WindowsCompatibility - Required for PKI support

( PowerShell Desktop 5.1/AzrueRM has limitations noted below. )

### Installation

#### From the PowerShell Gallery

[![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/Blue42)

The preferred way to install Blue42 is via the [PowerShell Gallery](https://www.powershellgallery.com/). For more information, see the [PowerShell Gallery Getting Started](https://msdn.microsoft.com/en-us/powershell/gallery/psgallery/psgallery_gettingstarted) page.

Run the following command to install Blue42 and its dependencies :

```powershell
Install-Module -Name Blue42 -Repository PSGallery
```

#### From Github

As an alternative, you can clone this repository to a location on your system then kindly review [Developer docs](./Developer.md)

### Functions

The module has the following functions

#### Paramater Helpers

+ [New-B42Password](./docs/New-B42Password.md) - creates a password useful for defaults
+ [Get-B42KeyVaultAccessPolicy](./docs/Get-B42KeyVaultAccessPolicy.md) - creates a key vault access policy suitable for a new deployment
+ [ConvertTo-B42Json](./docs/ConvertTo-B42Json.md) - converts a B42 powershell template to json

#### Global Session Variables

+ [Set-B42Globals](./docs/Set-B42Globals.md) - sets current session values
+ [Get-B42Globals](./docs/Get-B42Globals.md) - retrieves current session values

#### Templates Tools

+ [Find-B42Template](./docs/Find-B42Template.md) - Lists available templates in session template directory
+ [Get-B42Template](./docs/Get-B42Template.md) - Retreieves a powershell object representation of an ARM template's json
+ [Get-B42TemplateParameters](./docs/Get-B42TemplateParameters.md) - Retrieves a powershell object representation of an ARM template's json parameters

#### Deployment Tools

+ [New-B42Deployment](./docs/New-B42Deployment.md) - creates a new AzReourceGroup deployment with supplied parameters
+ [Test-B42Deployment](./docs/Test-B42Deployment.md) - verifies that a resource group's AzResourceGroupDeployment variables matched expected values (Incompatible with PowerShell 5.1)

#### Deployment Helpers

+ [Deploy-B42VNet](./docs/Deploy-B42VNetmd) - deploys a virtual network and 0 or more subnets
+ [Deploy-B42VM](./docs/Deploy-B42VM.md) - deploys a virtual machine with 0 or more script extensions
+ [Deploy-B42VMSS](./docs/Deploy-B42VMSS.md) - deploys a virtual machine scale set with 0 or more script extensions
+ [Deploy-B42SQL](./docs/Deploy-B42SQL.md) - deploys a SQL server and 0 or more databases
+ [Deploy-B42AppService](./docs/Deploy-B42AppService.md) - deploys an application service plan and 0 or more web apps
+ [Deploy-B42ASE](./docs/Deploy-B42ASE.md) - deploys an application service environment

### Templates

The module includes a group of templates that have the following characteristics:

+ All parameter and variable names are globally scoped within a session. (ie no variables named 'sku' instead use '[template]sku')
+ One resource per template
+ Advanced features are disabled inside the template using conditional logic
+ Indented with 2 spaces.
+ Have default values that may take advantage of the following special values; [PASSWORD], [LOCATION], [UID]

The result is that these templates may be 'stacked' to create more complex templates.

## License

This project is [licensed under the MIT License](./LICENSE).
