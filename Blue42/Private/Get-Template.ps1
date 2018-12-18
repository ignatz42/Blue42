function Get-Template {
    <#
        .SYNOPSIS
        ARM JSON to PowerShell conversion
        .DESCRIPTION
        The Get-Template function converts the JSON ARM template into PowerShell objects.
        .NOTES
        ordered lists are used instead of hashtables for consistent output
    #>
    [CmdletBinding()]
    param (
        # The path to the template
        [Parameter(Mandatory = $true)]
        [string] $TemplatePath,

        # Skip token replacement.
        [Parameter(Mandatory = $false)]
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
            if (($template.parameters.$parameterKey.type.EndsWith("object"))) {
                $newObject = [ordered]@{}
                foreach ($key in $template.parameters.$parameterKey.defaultValue.Keys) {
                    $newValue = $template.parameters.$parameterKey.defaultValue[$key]
                    if (($newValue.GetType().Name.EndsWith("String"))) {
                        $newValue = Edit-Tokens -DefaultValue $newValue -Globals $globals
                    }
                    $newObject.Add($key, $newValue)
                }
                $template.parameters.$parameterKey.defaultValue = $newObject
            }
            if (!($template.parameters.$parameterKey.type.EndsWith("string"))) {continue}
            $template.parameters.$parameterKey.defaultValue = Edit-Tokens -DefaultValue $template.parameters.$parameterKey.defaultValue -Globals $globals
        }
        $template
    }

    end {}
}
