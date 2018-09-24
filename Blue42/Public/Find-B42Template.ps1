function Find-B42Template {
    <#
        .SYNOPSIS
        Retrieves a list of templates (files with json extension) in the path.
        .DESCRIPTION
        The Find-B42Template function lists the json file names in the given directory. Use Get-B42Globals to view the default directory.
        .NOTES
        This function is mostly useful for listing templates in the default directory.
    #>
    [CmdletBinding()]
    param (
        # The template search path.
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath
    )

    begin {
        Write-Verbose "Starting Find-B42Templates"
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $globals = Get-B42Globals
            $TemplatePath = $globals.TemplatePath
        }
    }

    process {
        $templates = Get-ChildItem -Path $TemplatePath -Filter *.json
        foreach ($template in $templates) {
            $template.Name.SubString(0, $template.Name.IndexOf('.'))
        }
    }

    end {
        Write-Verbose "Ending Find-B42Templates"
    }
}
