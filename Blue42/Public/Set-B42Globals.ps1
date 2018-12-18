function Set-B42Globals {
    <#
        .SYNOPSIS
        Sets the default values for Location, TemplatePath, and a Unique Identifer.
        .DESCRIPTION
        The Set-B42Globals function sets some helper values with a Module Global scope.
        .EXAMPLE
        Set-B42Globals -UID "uniqueString" -Location "azureLocation" -TemplatePath "pathToCustomTemplates"
        .NOTES
        The unique identifer is used to relate default resource names.
    #>
    [CmdletBinding()]
    param (
        # The default unique identifer used in name generation
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string] $UID = "",

        # The default destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location = "East US",

        # The default search path for templates
        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [string] $TemplatePath = (Resolve-Path "$PSScriptRoot\..\Templates").ToString(),

        # The date
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string] $Date = ""
    )

    begin {}

    process {
        $d = Get-Date
        if ([string]::IsNullOrEmpty($UID)) {
            $UID = $d.ToString("yyyyMMddTHHmmss").ToLower()
        }
        if ([string]::IsNullOrEmpty($Date)) {
            $Date = $d.ToString("g")
        }

        $Script:uid = $UID
        $Script:location = $Location
        $Script:templatePath = $TemplatePath
        $Script:Date = $Date
    }

    end {}
}
