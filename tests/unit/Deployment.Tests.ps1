[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Deployments" {
    . "$PSScriptRoot\..\AzureMocks.ps1"

    BeforeAll {
        $Script:stackedTemplates = @("Blue42.Test", "Blue42.Alt")

        $globals = Get-B42Globals
        $globals.TemplatePath = "$PSScriptRoot\input"
        Set-B42Globals @globals
    }

    It "performs a stacked deployment" {
        $customValues = [hashtable]@{
            Blue42Password = "CustomPasswordValue"
            CopySource     = "OnlyInTemplate1"
            NewCopySource  = "OnlyInTemplate2"
        }
        $deploymentResults = New-B42Deployment -ResourceGroupName "deploymenttest-rg" -Templates $Script:stackedTemplates -TemplateParameters $customValues -Complete

        $deploymentResults[0].Parameters.Count | Should Be (4)
        $deploymentResults[0].Parameters.Contains("Blue42Password") | Should Be ($true)
        $deploymentResults[0].Parameters.Contains("Blue42Location") | Should Be ($true)
        $deploymentResults[0].Parameters.Contains("Blue42UID") | Should Be ($true)
        $deploymentResults[0].Parameters.Contains("CopySource") | Should Be ($true)

        ($deploymentResults[0].Parameters["Blue42Password"].Value -eq "CustomPasswordValue") | Should Be ($true)
        ($deploymentResults[0].Parameters["CopySource"].Value -eq "OnlyInTemplate1") | Should Be ($true)

        $deploymentResults[1].Parameters.Count | Should Be (2)
        $deploymentResults[1].Parameters.Contains("Blue42Password") | Should Be ($true)
        $deploymentResults[1].Parameters.Contains("NewCopySource") | Should Be ($true)

        ($deploymentResults[1].Parameters["Blue42Password"].Value -eq "CustomPasswordValue") | Should Be ($true)
        ($deploymentResults[1].Parameters["NewCopySource"].Value -eq "OnlyInTemplate2") | Should Be ($true)
    }

    It "performs a deployment test" {
        $currentValues = [hashtable]@{
            Blue42Password = "PasswordPasswordPassword"
        }
        $finalReport = Test-B42Deployment -ResourceGroupName "$PSScriptRoot\input" -Templates $Script:stackedTemplates -TemplateParameters $currentValues
        $finalReport.SimpleReport() | Should Be ($true)
    }

    It "fails a deployment test" {
        $currentValues = [hashtable]@{
            Blue42Password = "Password"
        }
        $finalReport = Test-B42Deployment -ResourceGroupName "$PSScriptRoot\input" -Templates $Script:stackedTemplates -TemplateParameters $currentValues
        $finalReport.SimpleReport() | Should Be ($false)
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
