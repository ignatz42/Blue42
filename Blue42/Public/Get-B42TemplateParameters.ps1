function Get-B42TemplateParameters {
    <#
        .SYNOPSIS
        Retrieves a hashtable of template parameters suitable for deployment.
        .DESCRIPTION
        The Get-B42TemplateParameters function returns a hashtable of template parameters suitable for deployment. The template's default values are used as a starting place. Special tokens are replaced.
        .EXAMPLE
        Get-B42TemplateParameters -Templates @("Vnet", "Subnet")
        .NOTES
        This function does a token replacement on [PASSWORD] and [UID] contained in the template's default value field.
    #>
    [OutputType('System.Collections.Specialized.OrderedDictionary')]
    [CmdletBinding()]
    param (
        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory = $true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory = $false)]
        [string] $TemplatePath,

        # A list of override parameters. If empty, the default parameters supplied in the template will be used instead
        [Parameter(Mandatory = $false)]
        [hashtable] $TemplateParameters = @{},

        # Return object in JSON format
        [Parameter(Mandatory = $false)]
        [switch] $AsJson,

        # Skip token replacement.
        [Parameter(Mandatory = $false)]
        [switch] $SkipTokenReplacement
    )

    begin {
        Write-Verbose "Starting Get-B42TemplateParameters"
    }

    process {
        $thisTemplate = Get-B42Template -Templates $Templates -TemplatePath $TemplatePath -SkipTokenReplacement:$SkipTokenReplacement
        $outputTemplateParameters = [ordered]@{}
        foreach ($parameterKey in $thisTemplate.parameters.Keys) {
            $keyValue = $thisTemplate.parameters.$parameterKey.defaultValue
            if ($TemplateParameters.Contains($parameterKey)) {
                $keyValue = $TemplateParameters.$parameterKey
            }
            $outputTemplateParameters.Add($parameterKey, $keyValue)
        }

        if ($AsJson) {
            $parametersJson = [ordered]@{
                '$schema'      = "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
                contentVersion = "1.0.0.0"
                parameters     = [ordered]@{}
            }
            foreach ($templateParameterKey in $outputTemplateParameters.Keys) {
                $parametersJson.parameters.Add($templateParameterKey, @{value = $outputTemplateParameters.$templateParameterKey})
            }
            $outputTemplateParameters = ConvertTo-B42Json -InputObject $parametersJson
        }

        $outputTemplateParameters
    }

    end {
        Write-Verbose "Ending Get-B42TemplateParameters"
    }
}
