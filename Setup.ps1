# Run this script as admin to install the development environment prereqs.

Install-Module -Name InvokeBuild -Force
Install-Module -Name Pester -Force
Install-Module -Name PSScriptAnalyzer -Force
Install-Module -Name PSCodeHealth -Force
Install-Module -Name platyPS -Force

Install-Module -Name Az -Force
if($PSEdition -eq 'Core') {
    # This module is required for the PKI interoperability and brings along a Windows host requirement for this module.
    Install-Module -Name WindowsCompatibility -RequiredVersion 0.0.1
}
