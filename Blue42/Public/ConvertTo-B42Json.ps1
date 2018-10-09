function ConvertTo-B42Json {
    <#
        .SYNOPSIS
        Just enough JSON beauty for human readable output
        .DESCRIPTION
        The ConvertTo-B42Json function formats json for use as an Arm template.
        .EXAMPLE
        ConvertTo-B42Json -InputObject (ConvertTo-Json -InputObject $object)
        .EXAMPLE
        $object | ConvertTo-Json | ConvertTo-B42Json
        .NOTES
        This function removes extra unicode formatting leftove from ConvertTo-Json
    #>
    [CmdletBinding()]
    param (
        # Powershell object in ordered dictionary collection
        [System.Collections.Specialized.OrderedDictionary] $InputObject
    )

    begin {
        Write-Verbose "Starting ConvertTo-B42Json"

    }

    process {
        $InputObject | ConvertTo-Json -Depth 50 | ForEach-Object -Process {[System.Text.RegularExpressions.Regex]::Unescape($_)}
    }

    end {
        Write-Verbose "Ending ConvertTo-B42Json"
    }
}
