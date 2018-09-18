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
        $customValues = [hashtable]@{
            Blue42Password = "MockValue"
            Blue42Location = "MockValue"
            Blue42UID      = "MockValue"
        }
        $testParameters = Get-B42TemplateParameters -Templates @("Blue42.Test") -TemplateParams $customValues
        foreach ($key in $customValues.Keys) {
            $testParameters.Contains($key) | Should Be ($true)
            ($testParameters[$key] -eq $customValues.$key) | Should Be ($true)
        }
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
