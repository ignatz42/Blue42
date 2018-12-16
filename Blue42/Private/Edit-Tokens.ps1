function Edit-Tokens {
    <#
        .SYNOPSIS
        Edit default values by replacing tokens with session values.
        .DESCRIPTION
        The Edit-Tokens function edits default values by replacing tokens with session values.
        .NOTES
        The tokens [PASSWORD], [LOCATION], [DATE] and [UID] are supported.
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param (
        # The path to the template
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $DefaultValue,

        # The sessions global variables.
        [Parameter(Mandatory = $true)]
        [hashtable] $Globals
    )

    begin {}

    process {
        $editValue = $DefaultValue
        if (($DefaultValue -match "(?<Head>.*)\[(?<Function>.+)\](?<Tail>.*)")) {
            if ('PASSWORD' -eq $Matches.Function) {
                $editValue = New-B42Password
                Write-Verbose "B42 - Replaced [PASSWORD]. See KeyVault for value or edit this line."
            }
            if ('LOCATION' -eq $Matches.Function) {
                $editValue = $Globals.Location
                Write-Verbose ("B42 - Replaced [LOCATION] with {0}" -f $editValue)
            }
            if ('UID' -eq $Matches.Function) {
                $editValue = $Matches.Head + $Globals.UID + $Matches.Tail
                Write-Verbose ("B42 - Replaced [UID] with {0}" -f $editValue)
            }
            if ('DATE' -eq $Matches.Function) {
                $editValue = Get-Date -Format "g"
                Write-Verbose ("B42 - Replaced [DATE] with {0}" -f $editValue)
            }
        }
        $editValue
    }

    end {}
}
