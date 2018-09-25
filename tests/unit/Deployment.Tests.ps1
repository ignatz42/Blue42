[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Deployments" {
    Mock -ModuleName $ModuleName Get-AzureRmResourceGroup { return $null }
    Mock -ModuleName $ModuleName New-AzureRmResourceGroup { return $null }
    Mock -ModuleName $ModuleName New-AzureRmResourceGroupDeployment {
        $theReturn = @{}
        foreach ($key in $TemplateParameterObject.Keys) {
            $deploymentVariableMock = @{
                Type = ($TemplateParameterObject.$key).GetType().Name
                Value = $TemplateParameterObject.$key
            }
            if (($deploymentVariableMock.Type -eq "Object[]") -or ($deploymentVariableMock.Type -eq "Hashtable")) {
                    $deploymentVariableMock.Type = ($TemplateParameterObject.$key).GetType().BaseType.Name
                    $deploymentVariableMock.Value = (,$TemplateParameterObject.$key | ConvertTo-Json)
            }
            $theReturn.Add($key, $deploymentVariableMock)
        }
        $mockDeploymentResult = [ordered]@{
            DeploymentName          = $Name
            ResourceGroupName       = $ResourceGroupName
            ProvisioningState       = "Succeeded"
            Timestamp               = "NOTSTAMPED"
            Mode                    = $Mode
            TemplateLink            = ""
            Parameters              = $theReturn
            Outputs                 = ""
            DeploymentDebugLogLevel = $DeploymentDebugLogLevel
        }
        return $mockDeploymentResult
    }
    Mock -ModuleName $ModuleName Get-AzureRmResourceGroupDeployment {
        if (![string]::IsNullOrEmpty($ResourceGroupName)) {
            $currentValues = [hashtable]@{
                Blue42Password = "PasswordPasswordPassword"
            }
            return New-B42Deployment -ResourceGroupName "stackedDeploymentTest" -Templates @("Blue42.Test", "Blue42.Alt") -TemplatePath $ResourceGroupName -TemplateParameters $currentValues
        }
    }

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

    AfterAll {
        Remove-Module $ModuleName
    }
}
