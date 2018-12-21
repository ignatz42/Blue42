[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Deployments" {
    . "$PSScriptRoot\..\AzureMocks.ps1"

    It "deploys a Vnet" {
        $reportCard = Deploy-B42VNet -ResourceGroupName "mockdeployment-rg" -IncludeDDos -PrivateDNSZone "testing.local"
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("vnetName") | Should Be ($true)
        $reportCard.Parameters.Contains("subnetName") | Should Be ($true)
        [string]::IsNullOrEmpty($reportCard.Parameters.vnetName) | Should Be ($false)
        [string]::IsNullOrEmpty($reportCard.Parameters.subnetName) | Should Be ($false)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzVirtualNetwork -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzDnsZone -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Set-AzDnsZone -Scope It
    }

    It "deploys a VM" {
        $reportCard = Deploy-B42VM -ResourceGroupName "mockdeployment-rg" -IncludePublicInterface
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("vmName") | Should Be ($true)
        [string]::IsNullOrEmpty($reportCard.Parameters.vmName) | Should Be ($false)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    It "deploys a VMSS" {
        $reportCard = Deploy-B42VMSS -ResourceGroupName "mockdeployment-rg" -ImageOsDiskBlobUri "https://storage.location.test/container/image.uri"
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("vmssName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    It "deploys an ASE" {
        $reportCard = Deploy-B42ASE -ResourceGroupName "mockdeployment-rg"
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("aseName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    It "deploys an App Service" {
        $reportCard = Deploy-B42AppService -ResourceGroupName "mockdeployment-rg"
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("aspName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    Mock -ModuleName $ModuleName New-SQLCommand { return }
    It "deploys a Web App" {
        $reportCard = Deploy-B42WebApp -ResourceGroupName "mockdeployment-rg" -SQLParameters ([ordered]@{})
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("webAppName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    It "deploys a SQL local instance" {
        $reportCard = Deploy-B42SQL -ResourceGroupName "mockdeployment-rg" -AADDisplayName "testspn"
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("sqlName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    It "deploys a KeyVault" {
        $reportCard = Deploy-B42KeyVault -ResourceGroupName "mockdeployment-rg" -IncludeCurrentUserAccess
        $reportCard.SimpleReport() | Should Be ($true)
        $reportCard.Parameters.Contains("keyVaultName") | Should Be ($true)
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
