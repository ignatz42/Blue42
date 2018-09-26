# Include: Settings.
. './Blue42.settings.ps1'

#Synopsis: Run/Publish Tests and Fail Build on Error.
task Test Clean, RunTests, ConfirmTestsPassed

#Synopsis: Run full Pipeline.
task . Clean, Analyze, Test, Publish

#Synopsis: Install dependencies.
task InstallDependencies {
    & "./Setup.ps1"
}

$Artifacts = "build_artifacts/"
$ModuleName = "Blue42"
$ModulePath = (Resolve-Path "$PSScriptRoot\$ModuleName")


#Synopsis: Clean Artifact directory.
task Clean {
    if (Test-Path -Path $Artifacts) {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force
}

#Synopsis: Analyze code.
task Analyze {
    $scriptAnalyzerParams = @{
        Path = $ModulePath
        ExcludeRule = @('PSPossibleIncorrectComparisonWithNull', 'PSUseToExportFieldsInManifest')
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams
    # Save the results.
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")
}

#Synopsis: Run tests.
task RunTests {
    $invokePesterParams = @{
        OutputFile = (Join-Path $Artifacts "TestResults.xml")
        OutputFormat = "NUnitXml"
        Script = ".\tests*"
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        ExcludeTag = "RequiresAzureContext"
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }
    $testResults = Invoke-Pester @invokePesterParams
    $testResults | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $Artifacts "PesterResults.json")

    # Experimenting with Code Coverage. The tool doesn't get any 'Per Function Information' when the test results are supplied
    # but the additional information doesn't warrant the test time because it doesn't match the PSScriptAnalyzer output
    Invoke-PSCodeHealth -Path "$ModulePath" -Recurse -TestsResult $testResults -HtmlReportPath (Join-Path $Artifacts "PSCodeHealthReport.html")
    #Invoke-PSCodeHealth -Path "$ModulePath" -Recurse -TestsPath "$PSScriptRoot\tests\unit" -HtmlReportPath (Join-Path $Artifacts "PSCodeHealthReport.html")
}

#Synopsis: Confirm that tests passed.
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml]$xml = Get-Content (Join-Path $Artifacts "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path $Artifacts "PesterResults.json") | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

task Publish {
    Write-Host "TODO"
}