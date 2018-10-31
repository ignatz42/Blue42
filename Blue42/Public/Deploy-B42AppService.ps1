function Deploy-B42AppService {
    <#
        .SYNOPSIS
        Deploys an App Service with optional Web Apps.
        .DESCRIPTION
        The Deploy-B42AppService function serves as a one touch deploy point for an Azure App Services
        .EXAMPLE
        Deploy-B42AppService
        .NOTES
        You need to run this function after establishing an AzureRm context using Login-AzureRmAccount
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location,

        # Parameters used for App Service creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $AppServiceParameters = [ordered]@{},

        # An array of web application parameters blocks; one per desired web app.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $WebApps = @()
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("AppServicePlan")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates
        $aspName = $deploymentResult.Parameters.aspName.Value
        if ([string]::IsNullOrEmpty($aspName)) {throw "Failed to obtain App Service name"}

        foreach ($webApp in $webApps) {
            if (!$webApp.Contains("aspName")) {
                $webApp.Add("aspName", $aspName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("webApp") -TemplateParameters $webApp
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
