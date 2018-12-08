[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleManifestPath and ModuleName
. "$PSScriptRoot\..\LoadModule.ps1"

Describe -Tag 'RequiresAzureContext' "OneTouch Azure tests." {
    BeforeAll {
        $Script:testResourceGroupName = "deploymenttesting-rg"
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

    It "deploys a VM" {
        $results = Deploy-B42VM -ResourceGroupName $Script:testResourceGroupName -IncludePublicInterface -Verbose
        $results.Count | Should Be (9)
    }

    It "deploys an webapp/db pair" {
        $results = Deploy-B42AppService -ResourceGroupName $Script:testResourceGroupName -WebApps @{} -SQLParameters @{}
        $results.Count | Should Be (6)
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
