[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Deployments" {
    . "$PSScriptRoot\..\AzureMocks.ps1"

    It "deploys the Vnet" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VNet -ResourceGroupName "mockdeployment-rg" -IncludeDDos -Subnets @{} -PrivateDNSZone "testing.local"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        # Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroupDeployment -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzVirtualNetwork -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzDnsZone -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Set-AzDnsZone -Scope It
    }

    It "deploys the VM" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VM -ResourceGroupName "mockdeployment-rg" -IncludePublicInterface
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the VMSS" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VMSS -ResourceGroupName "mockdeployment-rg" -ImageOsDiskBlobUri "https://storage.location.test/container/image.uri"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the ASE" {
        # TODO Should this return a Report card maybe?
        Deploy-B42ASE -ResourceGroupName "mockdeployment-rg"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    Mock -ModuleName $ModuleName New-SQLCommand { return }
    It "deploys the App Service" {
        # TODO Should this return a Report card maybe?
        Deploy-B42AppService -ResourceGroupName "mockdeployment-rg" -WebApps @{} -SQLParameters @{}
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the SQL" {
        # TODO Should this return a Report card maybe?
        Deploy-B42SQL -ResourceGroupName "mockdeployment-rg"  -DBs @{}
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzResourceGroupDeployment -Scope It
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
