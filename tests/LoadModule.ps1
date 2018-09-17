# Dot source this script in any Pester test script that requires the module to be imported
# or access to the following variables
$ModuleName = "Blue42"
$ModuleBasePath = (Resolve-Path "$PSScriptRoot\..\$ModuleName")
$ModuleManifestPath = ("{0}\{1}.psd1" -f $ModuleBasePath, $ModuleName)

if (!$SuppressImportModule) {
    # -Scope Global is needed when running tests from inside of psake, otherwise
    # the module's functions cannot be found in the Blue42 namespace
    Import-Module $ModuleManifestPath -Scope Global
}
