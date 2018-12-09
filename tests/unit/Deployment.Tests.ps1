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
        $finalReport = Test-B42Deployment -ResourceGroupName "deploymenttest-rg" -Templates $Script:stackedTemplates -TemplateParameters $customValues -Deployments $deploymentResults

        $finalReport.SimpleReport() | Should Be ($true)

        $finalReport.Parameters.Count | Should Be (5)

        $finalReport.Parameters.Contains("Blue42Password") | Should Be ($true)
        $finalReport.Parameters.Contains("Blue42Location") | Should Be ($true)
        $finalReport.Parameters.Contains("Blue42UID") | Should Be ($true)
        $finalReport.Parameters.Contains("CopySource") | Should Be ($true)
        $finalReport.Parameters.Contains("NewCopySource") | Should Be ($true)

        ($finalReport.Parameters.Blue42Password -eq "CustomPasswordValue") | Should Be ($true)
        ($finalReport.Parameters.CopySource -eq "OnlyInTemplate1") | Should Be ($true)
        ($finalReport.Parameters.NewCopySource -eq "OnlyInTemplate2") | Should Be ($true)
    }

    It "passes a deployment test" {
        # This is a magic value used by the Mock.
        $currentValues = [hashtable]@{
            Blue42Password = "PasswordPasswordPassword"
        }
        $finalReport = Test-B42Deployment -ResourceGroupName "$PSScriptRoot\input" -Templates $Script:stackedTemplates -TemplateParameters $currentValues
        $finalReport.SimpleReport() | Should Be ($true)
        $finalReport.Parameters.Contains("Blue42Password") | Should Be ($true)
        ($finalReport.Parameters.Blue42Password -eq "PasswordPasswordPassword") | Should Be ($true)
    }

    It "fails a deployment test" {
        # This is a magic value not used by the Mock.
        $currentValues = [hashtable]@{
            Blue42Password = "Password"
        }
        $finalReport = Test-B42Deployment -ResourceGroupName "$PSScriptRoot\input" -Templates $Script:stackedTemplates -TemplateParameters $currentValues
        $finalReport.SimpleReport() | Should Be ($false)
        $finalReport.Parameters.Contains("Blue42Password") | Should Be ($true)
        ($finalReport.Parameters.Blue42Password -eq "Password") | Should Be ($true)
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
