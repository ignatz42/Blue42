[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\..\LoadModule.ps1"

Describe "helpers in the Public directory" {
    It "generates a password with the minimum security requirements." {
        $password = New-B42Password
        ($password -match ("\W")) | Should Be ($true)
        ($password -match ("\d")) | Should Be ($true)
        ($password -match ("[A-Z]")) | Should Be ($true)
        ($password -match ("[a-z]")) | Should Be ($true)
        ($password.Length -gt 36) | Should Be ($true)
    }

    AfterAll {
        Remove-Module $ModuleName
    }
}
