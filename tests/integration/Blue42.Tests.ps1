[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleManifestPath and ModuleName
. "$PSScriptRoot\..\LoadModule.ps1"

Describe -Tag 'RequiresAzureContext' "Actual Azure tests." {
    BeforeAll {
        $Script:testResourceGroupName = "deploymenttest-rg"
        $Script:hasContext = $false
        if ($null -eq (Get-AzureRmContext)) {
            throw "Not Connected. Run Connect-AzureRmAccount to establish a context then try again."
        } else {
            $Script:hasContext = $true
        }
    }

    BeforeEach {
        Set-B42Globals
    }

    It "deploys a template" {
        $templates = @("VNet", "Subnet")
        $deploymentResult = New-B42Deployment -ResourceGroupName $Script:testResourceGroupName -Templates $templates
        $deploymentResult.Count | Should Be (2)

        $testResult = Test-B42Deployment -ResourceGroupName $Script:testResourceGroupName -Templates $templates
        $testResult | Should Be ($true)
        $testResult.SimpleReport() | Should Be ($true)
    }

    It "deploys an optional template resource." {
        $templates = @("DDosPlan", "VNet", "Subnet")
        $deploymentResult = New-B42Deployment -ResourceGroupName $Script:testResourceGroupName -Templates $templates
        $deploymentResult.Count | Should Be (3)

        $testResult = Test-B42Deployment -ResourceGroupName $Script:testResourceGroupName -Templates $templates
        $testResult | Should Be ($true)
        $testResult.SimpleReport() | Should Be ($true)
    }

    It "performs a complete deployment." {
        $deploymentResult = New-B42Deployment -ResourceGroupName $Script:testResourceGroupName -Templates @("Clean") -Complete
        $deploymentResult.Count | Should Be (1)
    }

    AfterEach {
        if ($Script:hasContext) {
            if (!($null -eq (Get-AzureRmResourceGroup -Name $Script:testResourceGroupName))) {
                Remove-AzureRmResourceGroup -Name $Script:testResourceGroupName -Confirm:$false -Force
            }
        }
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
