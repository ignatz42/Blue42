function Deploy-B42AppService {
    <#
        .SYNOPSIS
        Deploys an App Service, either a Plan or an Environment optionally
        .DESCRIPTION
        The Deploy-B42AppService function serves as a one touch deploy point for an Azure App Service. Both plan and environment supported.
        .EXAMPLE
        Deploy-B42AppService
        .NOTES
        Run this function after establishing an Az context using Connect-AzAccount
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory = $false)]
        [string] $Location,

        # Parameters used for App Service creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $AppServicePlanParameters = [ordered]@{}
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        if ($AppServicePlanParameters.Contains("aspSkuName") -and ($AppServicePlanParameters.aspSkuName).StartsWith("I") -and !($AppServicePlanParameters.Contains("aseName"))) {
            $aseReportCard = Deploy-B42ASE -ResourceGroupName $ResourceGroupName -Location "$Location"
            $AppServicePlanParameters.Add("aseName", $aseReportCard.Parameters.subnetName)
        }

        $templates = @("AppServicePlan")
        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $AppServicePlanParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $AppServicePlanParameters -Deployments $deployments

        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the App Service Plan"
        }
        if (!($AppServicePlanParameters.Contains("aspResourceGroupName"))) {
            $AppServicePlanParameters.Add("aspResourceGroupName", $ResourceGroupName)
        }
        if (!($AppServicePlanParameters.Contains("aspName"))) {
            $AppServicePlanParameters.Add("aspName", $reportCard.Parameters.aspName)
        }
        $reportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
