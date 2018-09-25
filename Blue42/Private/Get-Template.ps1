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
        [bool] $SkipTokenReplacement = $false
    )

    begin {
        Write-Verbose "Starting Get-Template"
        $globals = Get-B42Globals
    }

    process {
        $template = (Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json | ConvertFrom-B42Json)
        if ($SkipTokenReplacement) {return $template}

        foreach ($parameterKey in $template.parameters.Keys) {
            if (!($template.parameters.$parameterKey.type.EndsWith("string"))) {continue}
            if (!($template.parameters.$parameterKey.defaultValue -match "(?<Head>.*)\[(?<Function>.+)\](?<Tail>.*)")) {continue}
            if ('PASSWORD' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = New-B42Password
            }
            if ('LOCATION' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = $globals.Location
            }
            if ('UID' -eq $Matches.Function) {
                $template.parameters.$parameterKey.defaultValue = $Matches.Head + $globals.UID + $Matches.Tail
            }
        }
        $template
    }

    end {
        Write-Verbose "Ending Get-Template"
    }
}
