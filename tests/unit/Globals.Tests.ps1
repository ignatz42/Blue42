[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "Globals" {
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

    AfterAll {
        Remove-Module $ModuleName
    }
}
