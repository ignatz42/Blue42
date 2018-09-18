[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Templates" {
    BeforeAll {
        $globals = Get-B42Globals
        $globals.TemplatePath = "$PSScriptRoot\input"
        Set-B42Globals @globals
    }

    It "lists available templates with default and custom directory" {
        $tests = [ordered]@{
            Clean  = "$ModuleBasePath\Templates"
            Blue42 = ""
        }

        foreach ($test in $tests.Keys) {
            $templateList = Find-B42Template -TemplatePath $tests[$test]
            ($templateList.Count -gt 0) | Should Be ($true)
            ($templateList.Contains($test)) | Should Be ($true)
        }
    }

    It "gets a single template stack" {
        $testTemplate = Get-B42Template -Templates @("Blue42.Test") -AsJson -SkipTokenReplacement
        $rawJson = (Get-Content -Path "$PSScriptRoot\input\Blue42.Test.json" -Raw)
        ($testTemplate -eq $rawJson) | Should Be ($true)
    }

    It "gets a multi template stack" {
        $testTemplate = Get-B42Template -Templates @("Blue42.Test", "Blue42.Alt") -AsJson -SkipTokenReplacement
        $rawJson = (Get-Content -Path "$PSScriptRoot\output\Blue42.Test_Alt.json" -Raw)
        ($testTemplate -eq $rawJson) | Should Be ($true)
    }

    It "gets the Parameters" {
        $testParameters = Get-B42TemplateParameters -Templates @("Blue42.Test") -SkipTokenReplacement
        $testParameters.Contains("Blue42Password") | Should Be ($true)
        $testParameters.Contains("Blue42Location") | Should Be ($true)
        $testParameters.Contains("Blue42UID") | Should Be ($true)
        ($testParameters["Blue42Password"] -eq "get[PASSWORD]") | Should Be ($true)
        ($testParameters["Blue42Location"] -eq "azure[LOCATION]") | Should Be ($true)
        ($testParameters["Blue42UID"] -eq "root[UID]") | Should Be ($true)
    }

    It "gets the Parameters in JSON" {
        $testParameters = Get-B42TemplateParameters -Templates @("Blue42.Test") -SkipTokenReplacement -AsJson
        $rawJson = (Get-Content -Path "$PSScriptRoot\output\Blue42.Parameters.json" -Raw)
        ($testParameters -eq $rawJson) | Should Be ($true)
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
