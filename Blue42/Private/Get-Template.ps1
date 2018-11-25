function Get-Template {
    <#
        .SYNOPSIS
        ARM JSON to PowerShell conversion
        .DESCRIPTION
        The Get-Template function converts the JSON ARM template into PowerShell objects.
        .NOTES
        The tokens [PASSWORD], [LOCATION] and [UID] are replaced here.
    #>
    [CmdletBinding()]
    param (
        # The path to the template
        [Parameter(Mandatory=$true)]
        [string] $TemplatePath,

        # Skip token replacement.
        [Parameter(Mandatory=$false)]
        [switch] $SkipTokenReplacement
    )

    begin {
        Write-Verbose "B42 - Getting Template: $TemplatePath"
        $globals = Get-B42Globals
    }

    process {
        $template = (Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json | ConvertFrom-B42Json)
        if ($SkipTokenReplacement) {
            Write-Verbose "B42 - Skipping token replacement."
            return $template
        }

        # Replace the tokens to make sure that all parameters have working default values after the template is read.
        foreach ($parameterKey in $template.parameters.Keys) {
            if (!($template.parameters.$parameterKey.type.EndsWith("string"))) {continue}
            if (!($template.parameters.$parameterKey.defaultValue -match "(?<Head>.*)\[(?<Function>.+)\](?<Tail>.*)")) {continue}
            if ('PASSWORD' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = New-B42Password
                Write-Verbose "B42 - Replaced [PASSWORD]. See KeyVault for value or edit this line."
            }
            if ('LOCATION' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = $globals.Location
                Write-Verbose ("B42 - Replaced [LOCATION] with {0}" -f $template.parameters.$parameterKey.defaultValue)
            }
            if ('UID' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = $Matches.Head + $globals.UID + $Matches.Tail
                Write-Verbose ("B42 - Replaced [UID] with {0}" -f $template.parameters.$parameterKey.defaultValue)
            }
        }
        $template
    }

    end {}
}
