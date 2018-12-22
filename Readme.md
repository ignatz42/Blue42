
# Blue42

## Introduction

Blue42 is a PowerShell script module that facilitates the process of writing and using Azure Resource Manager (ARM) templates. At its' most basic, Blue42 converts an ARM template stored in Json format to a native PowerShell representation for manipulation. Blue42 provisions resources in 'Sessions' that define local connections between templates. Blue42 adds features that help generate default parameter values for templates during a session. Blue42 provides a tool that verifies deployment parameter match expected values.

## The Module

### License

This project is [licensed under the MIT License](./LICENSE).

### Requirements

Blue42 requires the following modules to function as intended.

+ PowerShell
+ Az
+ WindowsCompatibility - Required for PKI support with PowerShell Core

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
+ [Test-B42Deployment](./docs/Test-B42Deployment.md) - verifies that a resource group's AzResourceGroupDeployment variables matched expected values

#### Deployment Helpers

+ [Deploy-B42VNet](./docs/Deploy-B42VNetmd) - deploys a virtual network with options
+ [Deploy-B42VM](./docs/Deploy-B42VM.md) - deploys a virtual machine with
+ [Deploy-B42VMSS](./docs/Deploy-B42VMSS.md) - deploys a virtual machine scale set
+ [Deploy-B42SQL](./docs/Deploy-B42SQL.md) - deploys a SQL server
+ [Deploy-B42AppService](./docs/Deploy-B42AppService.md) - deploys an application service plan
+ [Deploy-B42ASE](./docs/Deploy-B42ASE.md) - deploys an application service environment
+ [Deploy-B42KeyVault](./docs/Deploy-B42KeyVault.md) - deploys a key vault
+ [Deploy-B42WebApp](./docs/Deploy-B42WebApp.md) - deploys a web app

### Templates

The module includes a group of templates that have the following characteristics:

+ All parameter and variable names are globally scoped within a session. (ie no variables named 'sku' instead use '[template]sku')
+ One resource per template
+ Advanced features are disabled inside the template using conditional logic
+ Indented with 2 spaces.
+ Have default values that may take advantage of the following special values; %PASSWORD%, %LOCATION%, %UID%, and %DATE%

The result is that these templates may be 'stacked' to create more complex templates.

## Usage Examples

Blue42 may be useful when creating new stack resource manager templates and deploying related one-off test resources

### Creating stacked Azure Resource Manager templates

The included templates may be stacked together to make starting points for future customization. For example, the following:

```powershell
$templates = @("VNet", "Subnet")
(Get-B42Template -Templates $template -AsJson) | Out-File "vnet_subnet.json"
```

will produce a valid arm template for deploying a vnet and a subnet later. Likewise, a parameter file for this new template can be created with:

```powershell
(Get-B42TemplateParameters -Templates @("vnet_subnet") -TemplatePath "." -AsJson) | Out-File "vnet_subnet.paramenters.json"
```

### Deploying related test resources

The basic deployment stanza, with auto-generated names, might look like:

```powershell
$templates = @("VNet", "Subnet")
$deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates
$reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Deployments $deployments

if ($reportCard.SimpleReport() -ne $true) {
    throw "Failed to deploy VNet"
}
...
```

This can be further defined by passing parameters like this:

```powershell
$parameters = [ordered]@{
  vnetName = "Blue42VNet"
  subnetName = "ClientSubnet"
}
$templates = @("VNet", "Subnet")
$deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $parameters
$reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $parameters -Deployments $deployments

if ($reportCard.SimpleReport() -ne $true) {
    throw "Failed to deploy VNet"
}
...
```

### One-Touch Deployments

Common deployments have been collected in the series of Deploy-* scripts which might look like this:

```powershell
$reportCard = Deploy-B42VNet -ResourceGroupName $ResourceGroupName

if ($reportCard.SimpleReport() -ne $true) {
    throw "Failed to deploy VNet"
}
...
```

The One-Touch Deployment script also take override parameters.

```powershell
$parameters = [ordered]@{
  vnetName = "Blue42VNet"
  subnetName = "ClientSubnet"
}
$reportCard = Deploy-B42VNet -ResourceGroupName $ResourceGroupName -VNetParameters $parameters

if ($reportCard.SimpleReport() -ne $true) {
    throw "Failed to deploy VNet"
}
...
```
