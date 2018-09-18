[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "the basic module" {
    Context "Private functions with Azure mocks" {
        Mock -ModuleName $ModuleName Get-AzureRmResourceGroup { return $null }
        Mock -ModuleName $ModuleName New-AzureRmResourceGroup { return $null }
        Mock -ModuleName $ModuleName New-AzureRmResourceGroupDeployment {
            $mockDeploymentResult = [ordered]@{
                DeploymentName          = $Name
                ResourceGroupName       = $ResourceGroupName
                ProvisioningState       = "Succeeded"
                Timestamp               = "NOTSTAMPED"
                Mode                    = $Mode
                TemplateLink            = ""
                Parameters              = $TemplateParameterObject
                Outputs                 = ""
                DeploymentDebugLogLevel = $DeploymentDebugLogLevel
            }
            return $mockDeploymentResult
        }

        InModuleScope $ModuleName {
            It "generates a unique date identifier" {
                $dateUID = Get-DateTime15
                $dateUID.Length | Should Be (15)
                $dateUID.GetType() | Should Be ("string")
            }

            It "parses the module test template" {
                $template = Get-Template -TemplatePath "$PSScriptRoot\input\Blue42.Test.json" -SkipTokenReplacement $true
                ($template.'$schema' -eq "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#") | Should Be ($true)
                ($template.parameters["Blue42Password"].defaultValue -eq "get[PASSWORD]") | Should Be ($true)
                ($template.parameters["Blue42UID"].defaultValue -eq "root[UID]") | Should Be ($true)
                ($template.parameters["Blue42Location"].defaultValue -eq "azure[LOCATION]") | Should Be ($true)
            }

            It "performs a simple deployment" {
                $mockParameters = @{
                    Blue42Password = "get[PASSWORD]"
                    Blue42UID      = "root[UID]"
                    Blue42Location = "azure[LOCATION]"
                }

                $deploymentResult = New-Deployment -Location "blueMan" -ResourceGroupName "deploymenttest-rg" -TemplatePath "$PSScriptRoot\input\Blue42.Test.json" -TemplateParams $mockParameters
                ($deploymentResult.Parameters.Count) | Should Be (3)

                $deploymentResult.Parameters.Contains("Blue42Password") | Should Be ($true)
                $deploymentResult.Parameters.Contains("Blue42Location") | Should Be ($true)
                $deploymentResult.Parameters.Contains("Blue42UID") | Should Be ($true)
            }
        }
    }

    Context "Helper functions" {
        It "passes basic globals workflow" {
            $globals = Get-B42Globals
            ($globals.UID.Length) | Should Be (15)
            ([string]::IsNullOrEmpty($globals.Location)) | Should Be ($false)
            (Test-Path $globals.TemplatePath) | Should Be ($true)
            # The Sleep statement is required to make sure that that the values for UID change.
            Start-Sleep -Seconds 1
            $null = Set-B42Globals
            $newGlobals = Get-B42Globals
            ($globals.Location -eq $newGlobals.Location) | Should Be ($true)
            ($globals.TemplatePath -eq $newGlobals.TemplatePath) | Should Be ($true)
            ($globals.UID -eq $newGlobals.UID) | Should Be ($false)
        }

        It "generates a password with the minimum security requirements." {
            $password = New-B42Password
            ($password -match ("\W")) | Should Be ($true)
            ($password -match ("\d")) | Should Be ($true)
            ($password -match ("[A-Z]")) | Should Be ($true)
            ($password -match ("[a-z]")) | Should Be ($true)
            ($password.Length -gt 36) | Should Be ($true)
        }        
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
