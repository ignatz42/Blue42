# Include: Settings.
. './Blue42.settings.ps1'

#Synopsis: Run/Publish Tests and Fail Build on Error.
task Test Clean, Analyze, RunTests, ConfirmTestsPassed

#Synopsis: Run/Publish Tests and Fail Build on Error.
task Health Clean, CodeHealth

#Synopsis: Use platyPS to produce markdown files from the exisitng module.
task Docs WriteDocs

#Synopsis: Run full Pipeline.
task . Test, Publish

#Synopsis: Install dependencies.
task InstallDependencies {
    & "./Setup.ps1"
}

#Synopsis: Clean Artifact directory.
task Clean {
    if (Test-Path -Path $Artifacts) {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force
}

#Synopsis: Analyze code using PSScriptAnalyzer.
task Analyze {
    $scriptAnalyzerParams = @{
        Path        = $ModulePath
        ExcludeRule = @('PSPossibleIncorrectComparisonWithNull', 'PSUseToExportFieldsInManifest')
        Severity    = @('Error', 'Warning')
        Recurse     = $true
        Verbose     = $false
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams
    # Save the results.
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")
}

#Synopsis: Run Pester tests.
task RunTests {
    $invokePesterParams = @{
        OutputFile   = (Join-Path $Artifacts "TestResults.xml")
        OutputFormat = "NUnitXml"
        Script       = ".\tests*"
        Strict       = $true
        PassThru     = $true
        Verbose      = $false
        EnableExit   = $false
        ExcludeTag   = "RequiresAzureContext"
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }
    $testResults = Invoke-Pester @invokePesterParams
    $testResults | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $Artifacts "PesterResults.json")
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

#Synopsis: Produce the PSCodeHealth report.
task CodeHealth {
    # The tool's output doesn't match the PSScriptAnalyzer output for function coverage.
    # The following command shows that the total missed lines is equal to 5 but the function coverage here shows 20+
    Invoke-PSCodeHealth -Verbose -Path "$ModulePath" -Recurse -TestsPath "$PSScriptRoot\tests\unit\*" -HtmlReportPath (Join-Path $Artifacts "PSCodeHealthReport.html") 4> (Join-Path $Artifacts "PSCodeHealthReport.Verbose.Log")
}

#Synopsis: Publish the module.
task Publish {
    Publish-Module -NuGetApiKey $env:NUGET_API_KEY -Path $ModulePath
}

#Synopsis: Write the docs from help with platyPS
task WriteDocs {
    Import-Module $ModulePath -Force
    New-MarkdownHelp -Module $ModuleName -OutputFolder .\docs -Force
    Remove-Module $ModuleName -Force
}
