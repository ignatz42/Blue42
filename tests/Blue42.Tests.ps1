[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $true
# The dotsourced script defines ModuleName, ModuleBasePath, and ModuleManifestPath
. "$PSScriptRoot\LoadModule.ps1"

Describe "the physical manifest" {
    BeforeAll{
        $Script:Manifest = $null
    }

    It "has a valid manifest" {
        $Script:Manifest = Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
        $Script:Manifest | Should Not BeNullOrEmpty
    }

    It "has a valid name" {
        $Script:Manifest.Name | Should Be $ModuleName
    }

	It "has a valid root module" {
        $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
    }

	It "has a valid description" {
        $Script:Manifest.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        $Script:Manifest.Guid | Should Be '660945b3-52d9-4f83-b4c6-aef50dc00b1e'
    }

    It "has a valid copyright" {
        $Script:Manifest.CopyRight | Should Not BeNullOrEmpty
    }

	It "exports all public functions" {
        $publicDirectory = "Public"
        $exportedModuleFunctions = $Script:Manifest.ExportedFunctions.Values.Name
        $functionFileBaseNames = Get-ChildItem ("$ModuleBasePath\{0}" -f $publicDirectory) -Filter *.ps1 | Select-Object -ExpandProperty BaseName
        $matchedCount = 0
        foreach ($functionName in $functionFileBaseNames)
        {
            $exportedModuleFunctions -contains $functionName  | Should Be $true
            $matchedCount += 1
        }

        $matchedCount | Should Be ($Script:Manifest.ExportedFunctions.Values.Name.Count)
    }

	It "doesn't export the private functions" {
        $privateDirectory = "Private"
        $exportedModuleFunctions = $Script:Manifest.ExportedFunctions.Values.Name
        $functionFileBaseNames = Get-ChildItem ("$ModuleBasePath\{0}" -f $privateDirectory) -Filter *.ps1 | Select-Object -ExpandProperty BaseName
        foreach ($functionName in $functionFileBaseNames)
        {
            $exportedModuleFunctions -contains $functionName  | Should Be $false
        }
    }

	It "has functions with minimum file contents" {
        $sourceDirectories = @("Public", "Private")
        foreach ($sourceDirectory in $sourceDirectories) {
            $functionFileNames = Get-ChildItem ("$ModuleBasePath\{0}" -f $sourceDirectory) -Filter *.ps1
            foreach ($functionFileName in $functionFileNames)
            {
                $functionFileName.FullName | Should -FileContentMatch ".SYNOPSIS"
                $functionFileName.FullName | Should -FileContentMatch ".DESCRIPTION"
                $functionFileName.FullName | Should -FileContentMatch ".NOTES"
                $functionFileName.FullName | Should -FileContentMatch "CmdletBinding()"
                $functionFileName.FullName | Should -FileContentMatch "param "
                $functionFileName.FullName | Should -FileContentMatch "begin {"
                $functionFileName.FullName | Should -FileContentMatch "process {"
                $functionFileName.FullName | Should -FileContentMatch "end {"
            }
        }
    }
}
