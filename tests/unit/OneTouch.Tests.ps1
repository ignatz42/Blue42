[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Deployments" {
    . "$PSScriptRoot\..\AzureMocks.ps1"

    It "deploys the Vnet" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VNet -ResourceGroupName "mockdeployment-rg" -IncludeDDos -Subnets @{} -PrivateDNSZone "testing.local"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
        # Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroupDeployment -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmVirtualNetwork -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmDnsZone -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName Set-AzureRmDnsZone -Scope It
    }

    It "deploys the VM" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VM -ResourceGroupName "mockdeployment-rg"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the VMSS" {
        # TODO Should this return a Report card maybe?
        Deploy-B42VMSS -ResourceGroupName "mockdeployment-rg" -ImageOsDiskBlobUri "https://storage.location.test/container/image.uri"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the ASE" {
        # TODO Should this return a Report card maybe?
        Deploy-B42ASE -ResourceGroupName "mockdeployment-rg"
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the App Service" {
        # TODO Should this return a Report card maybe?
        Deploy-B42AppService -ResourceGroupName "mockdeployment-rg" -WebApps @{}
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
        # Verify functions called?
    }

    It "deploys the SQL" {
        # TODO Should this return a Report card maybe?
        Deploy-B42SQL -ResourceGroupName "mockdeployment-rg"  -DBs @{}
        Assert-MockCalled -ModuleName $ModuleName -CommandName Get-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroup -Scope It
        Assert-MockCalled -ModuleName $ModuleName -CommandName New-AzureRmResourceGroupDeployment -Scope It
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
