
# Blue42

## Introduction

Blue42 is a PowerShell script module that facilitates the process of writing and using Azure Resource Manager (ARM) templates. At its' most basic, Blue42 converts an ARM template stored in Json format to a native PowerShell representation for manipulation. Blue42 provisions resources in 'Sessions' that define local connections between templates. Blue42 adds features that help generate default parameter values for templates during a session. Blue42 provides a tool that verifies deployment parameter match expected values.

## The Module

### Requirements

Blue42 requires the following modules to function as intended.

+ PowerShell Core 6.1
+ AzureRm.Netcore

( PowerShell Desktop 5.1/AzrueRM has limitations noted above. )

### Installation

#### From the PowerShell Gallery

[![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/Blue42)

The preferred way to install Blue42 is via the [PowerShell Gallery](https://www.powershellgallery.com/). For more information, see the [PowerShell Gallery Getting Started](https://msdn.microsoft.com/en-us/powershell/gallery/psgallery/psgallery_gettingstarted) page.

Run the following command to install Blue42 and its dependencies :

```powershell
Install-Module -Name Blue42 -Repository PSGallery
```

#### From Github

As an alternative, you can clone this repository to a location on your system then kindly review Developer.md

### Functions

The module has the following functions

#### Paramater Helpers

+ New-B42Password - creates a password useful for defaults
+ Get-B42KeyVaultAccessPolicy - creates a key vault access policy suitable for a new deployment
+ ConvertTo-B42Json - converts a B42 powershell template to json

#### Global Session Variables

+ Set-B42Globals - sets current session values
+ Get-B42Globals - retrieves current session values

#### Templates tools

+ Find-B42Template - Lists available templates in session template directory
+ Get-B42Template - Retreieves a powershell object representation of an ARM template's json
+ Get-B42TemplateParameters - Retrieves a powershell object representation of an ARM template's json parameters.

#### Deployment tools

+ New-B42Deployment - creates a new AzureRmReourceGroup deployment with supplied parameters
+ Test-B42Deployment - verifies that a resource group's AzureRmResourceGroupDeployment variables matched expected values (Incompatible with PowerShell 5.1)

### Templates
The module includes a group of templates that have the following characteristics:

+ All parameter and variable names are globally scoped within a session. (ie no variables named 'sku' instead use '[template]sku')
+ One resource per template
+ Advanced features are disabled inside the template using conditional logic
+ Indented; 2 spaces
+ Have default values that take advantage of the following special values; [PASSWORD], [LOCATOIN], [UID]

The result is that these templates may be 'stacked' to create more complex templates. For example, create a new template that contains a Key Vault and Storage Account suitable.

## License

This project is [licensed under the MIT License](LICENSE).
