function Get-DateTime15 {
    <#
        .SYNOPSIS
        DateTime.ToString helper
        .DESCRIPTION
        The Get-DateTime15 function returns a 15 character version of the current date/time
        .NOTES
        This feels new
    #>
    [CmdletBinding()]
    param ()

    begin {
        Write-Verbose "Starting Get-DateTime15"
    }

    process {
        ([string](Get-Date -Format yyyyMMddTHHmmss)).ToLower().ToString()
    }

    end {
        Write-Verbose "Ending Get-DateTime15"
    }
}
