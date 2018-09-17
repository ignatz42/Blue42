# Classes. Classes must be returned from a function so are not exorted but included first.
$classes = Get-ChildItem -Recurse -Path $PSScriptRoot\Classes -File -Filter *.ps1
foreach ($class in $classes) {
    . $class.FullName
}

# Private functions. Functions in this directories must not be exported
$privteFunctions = Get-ChildItem -Recurse -Path $PSScriptRoot\Private -File -Filter *.ps1
foreach ($privteFunction in $privteFunctions) {
    . $privteFunction.FullName
}

# Public functions. Functions in this directories must be exported
$publicFunctions = Get-ChildItem -Recurse -Path $PSScriptRoot\Public -File -Filter *.ps1
foreach ($publicFunction in $publicFunctions) {
    . $publicFunction.FullName
}
