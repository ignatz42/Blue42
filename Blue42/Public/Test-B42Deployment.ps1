function Test-B42Deployment {
    [OutputType('B42DeploymentReport')]
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Test a Deployment
        .DESCRIPTION
        The Test-B42Deployment function tests a deployment and attempts to return a go/no-go value
        .NOTES
        I'm not sure how to test this in the abstract.
    #>
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location,

        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory=$true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath,

        # A list of override parameters. If empty, the default parameters supplied in the template will be used insted
        [Parameter(Mandatory=$false)]
        [hashtable] $TemplateParams
    )

    begin {
        Write-Verbose "Starting Test-B42Deployment"

        $combinedParameters = Get-B42TemplateParameters -Templates $Templates -TemplatePath $TemplatePath -TemplateParams $TemplateParams
    }

    process {
        $finalReport = [B42DeploymentReport]::new()
        $finalReport.Deployments = Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName
        foreach ($deployment in $finalReport.Deployments) {
            $finalReport.SuccessfulDeploymentCount += [int]($deployment.ProvisioningState -eq "Succeeded")

            foreach ($parameter in $deployment.Parameters.Keys) {
                if ($combinedParameters.Contains($parameter)) {
                    $finalReport.MismatchedParameters += [int] !($combinedParameters.$parameter -eq $deployment.Parameters.$parameter)
                }
            }

        }
        $finalReport
    }

    end {
        Write-Verbose "Ending Test-B42Deployment"
    }
}
