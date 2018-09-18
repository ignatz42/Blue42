function ConvertTo-B42Json {
    <#
        .SYNOPSIS
        Just enough JSON beauty.
        .DESCRIPTION
        The ConvertTo-B42Json function formats for output.
        .NOTES
        See link for explanation of the conversion
        .LINK
        http://www.azurefieldnotes.com/2017/05/02/replacefix-unicode-characters-created-by-convertto-json-in-powershell-for-arm-templates/
    #>
    [CmdletBinding()]
    param (
        # Powershell object in ordered dictionary collection
        [System.Collections.Specialized.OrderedDictionary] $TemplateObject
    )

    begin {
        Write-Verbose "Starting ConvertTo-B42Json"
    }

    process {
        $TemplateObject | ConvertTo-Json -Depth 50 | ForEach-Object -Process {[System.Text.RegularExpressions.Regex]::Unescape($_)}
    }

    end {
        Write-Verbose "Ending ConvertTo-B42Json"
    }
}
