# Run this script as admin to install the development environment prereqs.

Install-Module -Name InvokeBuild -Force
Install-Module -Name Pester -Force
Install-Module -Name PSScriptAnalyzer -Force
Install-Module -Name PSCodeHealth -Force
Install-Module -Name platyPS -Force

if($PSEdition -eq 'Core') {
    Install-Module -Name AzureRM.Netcore -Force
} else { # Desktop
    Install-Module -Name AzureRM -Force
}
