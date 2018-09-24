function Get-B42Template {
    <#
        .SYNOPSIS
        Retrieves an ARM template in native PowerShell objects.
        .DESCRIPTION
        The Get-B42Template function creates a new template by combining the supplied atomic templates and returns it in Hashtable/array format.
        .NOTES
        This function is mostly useful for creating templates by stacking the atomic elements.
    #>
    [CmdletBinding()]
    param (
        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory=$true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath,

        # Return object in JSON format
        [switch] $AsJson,

        # Skip token replacement.
        [switch] $SkipTokenReplacement
    )

    begin {
        Write-Verbose "Starting Get-B42Template"
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $globals = Get-B42Globals
            $TemplatePath = $globals.TemplatePath
        }
    }

    process {
        $combinedTemplate = [ordered]@{
            '$schema'      = ""
            contentVersion = ""
            parameters     = [ordered]@{}
            variables      = [ordered]@{}
            resources      = @()
            outputs        = [ordered]@{}
        }

        foreach ($template in $Templates) {
            $thisTemplate = Get-Template -TemplatePath ("{0}\{1}.json" -f $TemplatePath, $template) -SkipTokenReplacement $SkipTokenReplacement
            # Todo Are these values always the same?
            $combinedTemplate.'$schema' = $thisTemplate.'$schema'
            $combinedTemplate.contentVersion = $thisTemplate.contentVersion
            foreach ($key in $thisTemplate.parameters.Keys) {
                if ($combinedTemplate.parameters.Contains($key)) {continue}
                $combinedTemplate.parameters.Add($key, $thisTemplate.parameters[$key])
            }
            foreach ($key in $thisTemplate.variables.Keys) {
                if ($combinedTemplate.variables.Contains($key)) {continue}
                $combinedTemplate.variables.Add($key, $thisTemplate.variables[$key])
            }
            foreach ($resource in $thisTemplate.resources) {
                $combinedTemplate.resources += $resource
            }
            foreach ($key in $thisTemplate.outputs.Keys) {
                if ($combinedTemplate.outputs.Contains($key)) {continue}
                $combinedTemplate.outputs.Add($key, $thisTemplate.outputs[$key])
            }
        }
        $returnObject = $combinedTemplate
        if ($AsJson) {
            $returnObject = ConvertTo-B42Json -TemplateObject $combinedTemplate
        }

        $returnObject
    }

    end {
        Write-Verbose "Ending Get-B42Template"
    }
}
