function Get-DateTime15 {
    <#
        .SYNOPSIS
        DateTime.ToString helper
        .DESCRIPTION
        The Get-DateTime15 function returns a 15 character version of the current date/time
        .NOTES
        This feels new
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param ()

    begin {}

    process {
        ([string](Get-Date -Format yyyyMMddTHHmmss)).ToLower().ToString()
    }

    end {}
}
