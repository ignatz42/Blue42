function Deploy-B42ASE {
    <#
        .SYNOPSIS
        Deploys an ASE.
        .DESCRIPTION
        The Deploy-B42ASE function serves as a one touch deploy point for an Azure Application Service Environment
        .EXAMPLE
        Deploy-B42ASE
        .NOTES
        Run this function after establishing an Az context using Connect-AzAccount
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location,

        # Parameters used for App Service Environemtn creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $AppServiceEnvironmentParameters = [ordered]@{}
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        # The parameters in VirtualNetworkParameters are required. If not provided, create some defaults.
        if (!($AppServiceEnvironmentParameters.Contains("vnetResourceGroupName") -and $AppServiceEnvironmentParameters.Contains("vnetName") -and $AppServiceEnvironmentParameters.Contains("subnetName"))) {
            $vnetReportCard = Deploy-B42VNet -ResourceGroupName $ResourceGroupName -Location "$Location"
            # Carry along these values to the VMDeployment.
            $AppServiceEnvironmentParameters.Add("vnetResourceGroupName", $ResourceGroupName)
            $AppServiceEnvironmentParameters.Add("vnetName", $vnetReportCard.Parameters.vnetName)
            $AppServiceEnvironmentParameters.Add("subnetName", $vnetReportCard.Parameters.subnetName)
        }

        $templates = @("ASE")
        Write-Verbose "The next statment may take upwards of an hour to complete."
        $aseDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $AppServiceEnvironmentParameters
        $aseReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $AppServiceEnvironmentParameters -Deployments $aseDeployments

        if ($aseReportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the ASE phase 1"
        }
        $AppServiceEnvironmentParameters.Add("aseName", $aseReportCard.Parameters.aseName)

        # Publish the cert.

        # Incremental deployment to configure the cert.

        $aseReportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
