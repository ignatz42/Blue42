function Get-B42Globals {
    <#
        .SYNOPSIS
        Retrieves the current set of globals parameters and their values.
        .DESCRIPTION
        The Get-B42Globals function displays the Unique Identifer, Location, and Module Template Path
        .NOTES
        Run Set-B42Globals to change or update the values.
    #>
    [OutputType('System.Collections.Hashtable')]
    [CmdletBinding()]
    param ()

    begin {}

    process {
        if ([string]::IsNullOrEmpty($Script:uid) -or
            [string]::IsNullOrEmpty($Script:location) -or
            [string]::IsNullOrEmpty($Script:templatePath)) {
            Set-B42Globals
        }

        @{
            UID          = $Script:uid
            Location     = $Script:location
            TemplatePath = $Script:templatePath
        }
    }

    end {}
}
