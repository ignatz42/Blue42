function Get-B42TemplateParameters {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Retrieves a hashtable of template parameters suitable for deployment.
        .DESCRIPTION
        The Get-B42TemplateParameters function returns a hashtable of template parameters suitable for deployment. The template's default values are used as a starting place. Special tokens are replaced.
        .NOTES
        This function does a token replacement on [PASSWORD] and [UID] contained in the template's default value field.
    #>
    param (
        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory = $true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory = $false)]
        [string] $TemplatePath,

        # Return object in JSON format
        [switch] $AsJson,

        # Skip token replacement.
        [switch] $SkipTokenReplacement
    )

    begin {
        Write-Verbose "Starting Get-B42TemplateParameters"
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $globals = Get-B42Globals
            $TemplatePath = $globals.TemplatePath
        }
    }

    process {
        $thisTempateParams = @{
            Templates    = $Templates
            TemplatePath = $TemplatePath
        }
        if ($SkipTokenReplacement) {
            $thisTempateParams.Add("SkipTokenReplacement", $true)
        }
        $thisTemplate = Get-B42Template @thisTempateParams
        $returnObject = [ordered]@{}
        foreach ($parameter in $thisTemplate.parameters.Keys) {
            $returnObject.Add($parameter, $thisTemplate.parameters[$parameter].defaultValue)
        }

        if ($AsJson) {
            $combinedTemplate = [ordered]@{
                '$schema'      = "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
                contentVersion = "1.0.0.0"
                parameters     = [ordered]@{}
            }
            foreach ($parameter in $returnObject.Keys) {
                $combinedTemplate.parameters.Add($parameter, @{value = $returnObject[$parameter]})
            }

            $returnObject = ConvertTo-B42Json -TemplateObject $combinedTemplate
        }

        $returnObject
    }

    end {
        Write-Verbose "Ending Get-B42TemplateParameters"
    }
}
