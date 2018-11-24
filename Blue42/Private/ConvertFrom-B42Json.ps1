function ConvertFrom-B42Json {
    <#
        .SYNOPSIS
        Convert Json to PowerShell objects.
        .DESCRIPTION
        The ConvertFrom-B42Json function converts Json into PowerShell lists and ordered hashtables.
        .NOTES
        The native ConvertFrom-Json implementation of -AsHashTables does not use ordered hashtables which breaks tests.
        Bonus 5.1 backward compatibility.
    #>
    [CmdletBinding()]
    param (
        # Input object in Json format
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $InputObject = $null
    )

    begin {}

    process {
        $resultObject = $null
        if ( $InputObject -is [System.Management.Automation.PSCustomObject] ) {
            $resultObject = [ordered]@{}
            foreach ($property in $InputObject.psobject.properties) {
                $resultObject[$property.Name] = ConvertFrom-B42Json -InputObject $property.Value
            }
        } elseif ($InputObject -is [System.Object[]]) {
            $list = @()
            foreach ($item in $InputObject) {
                $list += (ConvertFrom-B42Json -InputObject $item)
            }
            # The , is used here to workaround Powershell's tendancy to convert an array of 1 into that single element.
            $resultObject = ,$list
        } else {
            $resultObject = $InputObject
        }
        $resultObject
    }

    end {}
}
