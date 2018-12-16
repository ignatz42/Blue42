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
                foreach ($value in $template.parameters.$parameterKey.defaultValue.Values) {
                    if (!($value.GetType().Name.EndsWith("String"))) {continue}
                    $value = Edit-Tokens -DefaultValue $value -Globals $globals
                }
            }
            if (!($template.parameters.$parameterKey.type.EndsWith("string"))) {continue}
            $template.parameters.$parameterKey.defaultValue = Edit-Tokens -DefaultValue $template.parameters.$parameterKey.defaultValue -Globals $globals
        }
        $template
    }

    end {}
}
