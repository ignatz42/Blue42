[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleManifestPath and ModuleName
. "$PSScriptRoot\..\LoadModule.ps1"

Describe -Tag 'RequiresAzureContext' "OneTouch Azure tests." {
    BeforeAll {
        $Script:testResourceGroupName = "deploymenttest-rg"
        $Script:hasContext = $false
        if ($null -eq (Get-AzContext)) {
            throw "Not Connected. Run Connect-AzAccount to establish a context then try again."
        } else {
            $Script:hasContext = $true
        }
    }

    BeforeEach {
        Set-B42Globals
    }

    # This deploys Vnet, Subnet, KeyVault, PublicIP, NSG, NetworkInterface, WinVM templates
    It "deploys a VM" {
        $reportCard = Deploy-B42VM -ResourceGroupName $Script:testResourceGroupName -IncludePublicInterface
        $reportCard.SimpleReport() | Should Be ($true)
    }

    # This deploys SQL, DB, AppServicePlan, WebApp, KeyVault, AppInsights, Storage templates
    It "deploys an webapp/db pair" {
        $reportCard = Deploy-B42WebApp -ResourceGroupName $Script:testResourceGroupName -SQLParameters ([ordered]@{})
        $reportCard.SimpleReport() | Should Be ($true)
    }

    AfterEach {
        if ($Script:hasContext) {
            if (!($null -eq (Get-AzResourceGroup -Name $Script:testResourceGroupName))) {
                Remove-AzResourceGroup -Name $Script:testResourceGroupName -Confirm:$false -Force
            }
        }
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
