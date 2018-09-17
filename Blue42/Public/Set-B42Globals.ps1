function Set-B42Globals {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Sets the default values for Location, TemplatePath, and a Unique Identifer.
        .DESCRIPTION
        The Set-B42Globals function sets some helper values with a Module Global scope.
        .NOTES
        The unique identifer is used to relate default resource names.
    #>
    param (
        # The default unique identifer used in name generation
        [Parameter(Mandatory=$false)]
        [string] $UID = (Get-DateTime15),

        # The default destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location = "East US",

        # The default search path for templates
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath = (Resolve-Path "$PSScriptRoot\..\Templates").ToString()
    )

    begin {}

    process {
        $Script:uid = $UID
        $Script:location = $Location
        $Script:templatePath = $TemplatePath
    }

    end {}
}
