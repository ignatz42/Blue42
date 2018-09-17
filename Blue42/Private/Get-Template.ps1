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
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath,

        # Skip token replacement.
        [bool] $SkipTokenReplacement = $false
    )

    begin {
        Write-Verbose "Starting Get-Template"
        $globals = Get-B42Globals
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $TemplatePath = $globals.TemplatePath
        }
    }

    process {
        $template = (Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json | ConvertTo-B42Posh)
        if (!$SkipTokenReplacement){
            foreach ($parameter in $template.parameters.Keys) {
                if ($template.parameters[$parameter].type -eq "securestring" -or
                    $template.parameters[$parameter].type -eq "string") {
                    $thisDefaultValue = $template.parameters[$parameter].defaultValue
                    if ($thisDefaultValue -match "(?<Head>.*)\[(?<Function>.+)\](?<Tail>.*)") {
                        switch ( $Matches.Function ) {
                            'PASSWORD' { $thisDefaultValue = New-B42Password }
                            'LOCATION' { $thisDefaultValue = $globals.Location }
                            'UID'      { $thisDefaultValue = $Matches.Head + $globals.UID + $Matches.Tail }
                        }
                        $template.parameters[$parameter].defaultValue = $thisDefaultValue
                    }
                }
            }
        }
        $template
    }

    end {
        Write-Verbose "Ending Get-Template"
    }
}
