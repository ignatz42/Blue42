[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "the basic module" {
    # All contexts require the Azure Mocks.
    . "$PSScriptRoot\..\AzureMocks.ps1"

    BeforeAll {
        # When calling functions via WindowsCompatibility, the TestDrive PSDrive is lost.
        $testDrivePath = Convert-Path -Path "TestDrive:"
    }

    Context "Private functions with internal mocks" {
        Mock -ModuleName $ModuleName New-B42Password { "ExpectedTestResult" }
        Mock -ModuleName $ModuleName Get-B42Globals {
            @{
                UID          = "ExpectedUID"
                Location     = "AzureLocation"
                TemplatePath = "$PSScriptRoot\input\"
            }
        }

        InModuleScope $ModuleName {
            It "parses the module test template" {
                $template = Get-Template -TemplatePath "$PSScriptRoot\input\Blue42.Test.json"
                ($template.'$schema' -eq "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#") | Should Be ($true)
                ($template.parameters["Blue42Password"].defaultValue -eq "ExpectedTestResult") | Should Be ($true)
                ($template.parameters["Blue42UID"].defaultValue -eq "rootExpectedUID") | Should Be ($true)
                ($template.parameters["Blue42Location"].defaultValue -eq "AzureLocation") | Should Be ($true)
            }

            It "performs a simple deployment" {
                $mockParameters = @{
                    Blue42Password = "%PASSWORD%"
                    Blue42UID      = "root%UID%"
                    Blue42Location = "%LOCATION%"
                }

                $deploymentResult = New-Deployment -Location "blueMan" -ResourceGroupName "deploymenttest-rg" -TemplatePath "$PSScriptRoot\input\Blue42.Test.json" -TemplateParameters $mockParameters -Name "B42_Deployment"
                ($deploymentResult.Parameters.Count) | Should Be (3)

                $deploymentResult.Parameters.Contains("Blue42Password") | Should Be ($true)
                $deploymentResult.Parameters.Contains("Blue42Location") | Should Be ($true)
                $deploymentResult.Parameters.Contains("Blue42UID") | Should Be ($true)
            }

            It "checks the default Class" {
                $test = [B42DeploymentReport]::new()
                $test.SimpleReport() | Should Be ($false)
                $test.SuccessfulDeploymentCount | Should Be (0)
                $test.MismatchedParameters | Should Be (0)
            }

            It "generates an NSG list" {
                $list = Get-NSGList
                ($list.Count -eq 1) | Should Be ($true)
                ($list[0].destinationPortRange -eq "5986") | Should Be ($true)

                $list = Get-NSGList -IsLinux
                ($list.Count -eq 1) | Should Be ($true)
                ($list[0].destinationPortRange -eq "22") | Should Be ($true)
            }

            It "adds a secret" {
                $secretMeta = Add-Secret -KeyVaultName "testvault" -SecretName "AdminUser" -SecretValue "Password"
                ($secretMeta.SecretValueText -eq "Password") | Should Be ($true)

                $securePassword = (ConvertTo-SecureString -AsPlainText -Force -String "Password")
                $secretMeta = Add-Secret -KeyVaultName "testvault" -SecretName "AdminUser" -SecretValue $securePassword
                ($secretMeta.SecretValue -eq $securePassword) | Should Be ($true)
            }
        }
    }

    Context "Helper functions" {
        It "passes basic globals workflow" {
            $globals = Get-B42Globals
            # The UID is the max length of a VM host name.
            ($globals.UID.Length) | Should Be (15)
            # Must have a Location
            ([string]::IsNullOrEmpty($globals.Location)) | Should Be ($false)
            # Template path should be valid.
            (Test-Path $globals.TemplatePath) | Should Be ($true)
            # Verify the Date is parsable
            [DateTime]$dtOutput = New-Object DateTime
            [DateTime]::TryParseExact($globals.Date, "g", [System.Globalization.CultureInfo]::CurrentCulture, [System.Globalization.DateTimeStyles]::None, [ref]$dtOutput) | Should Be ($true)

            # The Sleep statement is required to make sure that that the values for UID change.
            Start-Sleep -Seconds 1
            $null = Set-B42Globals
            $newGlobals = Get-B42Globals
            ($globals.Location -eq $newGlobals.Location) | Should Be ($true)
            ($globals.TemplatePath -eq $newGlobals.TemplatePath) | Should Be ($true)
            ($globals.UID -eq $newGlobals.UID) | Should Be ($false)
            # The date value has minute level granularity so it should be the same.
            ($globals.Date -eq $newGlobals.Date) | Should Be ($true)
        }

        It "generates a password with the minimum security requirements." {
            $password = New-B42Password
            ($password -match ("\W")) | Should Be ($true)
            ($password -match ("\d")) | Should Be ($true)
            ($password -match ("[A-Z]")) | Should Be ($true)
            ($password -match ("[a-z]")) | Should Be ($true)
            ($password.Length -gt 36) | Should Be ($true)
        }

        It "generates a KeyVault Access Policy" {
            # These GUIDs are made-up.  In a real environment, use something like this:
            #   $currentContext = Get-AzContext
            #   $TenantID = $currentContext.Tenant.Id
            #   $ObjectID = (Get-AzADUser -StartsWith $currentContext.Account.Id).Id
            $objectId = "2dd39430-f77b-4f9e-83dd-61c26e222df1"
            $tenantId = "52154619-1815-4178-a7e7-44a1ac3a5f98"
            $accessPolicy = Get-B42KeyVaultAccessPolicy -ObjectID $objectId -TenantID $tenantId
            ($null -eq $accessPolicy) | Should Be ($false)
        }

        # Currently, this test only work in PowerShell 5.1 due to the interaction between WindowsCompatibility and PKI modules.
        It "generates a Certificate and converts it to usable forms" {
            $certifacteResults = Get-B42CertificateForms -CertificatePath ("{0}Blue42TemplateTest.pfx" -f $testDrivePath) -DomainNames @("testing.local")
            ($certifacteResults.Path -eq ("{0}Blue42TemplateTest.pfx" -f $testDrivePath)) | Should Be ($true)
            ([string]::IsNullOrEmpty($certifacteResults.Password)) | Should Be ($false)
            ([string]::IsNullOrEmpty($certifacteResults.Thumbprint)) | Should Be ($false)
            ([string]::IsNullOrEmpty($certifacteResults.JsonArray)) | Should Be ($false)
            ([string]::IsNullOrEmpty($certifacteResults.IntegerEncoded)) | Should Be ($false)
            ([string]::IsNullOrEmpty($certifacteResults.PkcsSecret)) | Should Be ($false)
        }
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
