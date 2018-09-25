function Test-B42Deployment {
    <#
        .SYNOPSIS
        Test a Deployment
        .DESCRIPTION
        The Test-B42Deployment function tests a deployment and attempts to return a go/no-go value
        .NOTES
        I'm not sure how to test this in the abstract.
    #>
    [OutputType('B42DeploymentReport')]
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory=$true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath,

        # A list of override parameters. If empty, the default parameters supplied in the template will be used insted
        [Parameter(Mandatory=$false)]
        [hashtable] $TemplateParams = @{}
    )

    begin {
        Write-Verbose "Starting Test-B42Deployment"
        $combinedParameters = Get-B42TemplateParameters -Templates $Templates -TemplatePath $TemplatePath -TemplateParams $TemplateParams
    }

    process {
        $finalReport = [B42DeploymentReport]::new()
        $finalReport.Deployments = Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName
        foreach ($deployment in $finalReport.Deployments) {
            if ($deployment.ProvisioningState -eq "Succeeded") {
                $finalReport.SuccessfulDeploymentCount += 1
            } else {
                Write-Verbose ("{0} was not Successful" -f $deployment.DeploymentName)
            }

            foreach ($parameter in $deployment.Parameters.Keys) {
                if (!($combinedParameters.Contains($parameter))) { continue }

                $deploymentValue = $deployment.Parameters.$parameter.Value
                # This works around a bug where the value is an emtpy JArray. Should look into writing a bug report.
                if (($deployment.Parameters.$parameter.Type -eq "Array") -or ($deployment.Parameters.$parameter.Type -eq "Object")) {
                    $deploymentValue = ($deployment.Parameters.$parameter.Value.ToString() | ConvertFrom-Json -AsHashtable)
                }

                if (!(($null -eq (Compare-Object -ReferenceObject $deploymentValue -DifferenceObject $combinedParameters.$parameter)))) {
                    $finalReport.MismatchedParameters += 1
                    Write-Verbose ("Found mismatched parameter {0} with value {1}" -f $parameter, $deploymentValue)
                }
            }
        }
        $finalReport
    }

    end {
        Write-Verbose "Ending Test-B42Deployment"
    }
}
