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
        [hashtable] $TemplateParams = @{}
    )

    begin {
        Write-Verbose "Starting Test-B42Deployment"
        $globals = Get-B42Globals
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $TemplatePath = $globals.TemplatePath
        }
        if ([string]::IsNullOrEmpty($Location)) {
            $Location = $globals.Location
        }

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
                if ($combinedParameters.Contains($parameter)) {
                    $deploymentValue = $deployment.Parameters.$parameter.Value
                    $matched = ($combinedParameters.$parameter -eq $deploymentValue)
                    # This works around a bug where the value is an emtpy JArray. Should look into writing a bug report.
                    if ($deployment.Parameters.$parameter.Type -eq "Array") {
                        Write-Verbose "Comparing an array."
                        $deploymentValue = ($deployment.Parameters.$parameter.Value.ToString() | ConvertFrom-Json)
                        $matched = ($null -eq (Compare-Object -ReferenceObject $deploymentValue -DifferenceObject $combinedParameters.$parameter))
                    }
                    # Both the Array and Object entries should be done with the internal B42 POSH function
                    # And the POSH function should be made public and renamed.
                    if ($deployment.Parameters.$parameter.Type -eq "Object") {
                        Write-Verbose "Comparing an object."
                        $deploymentValue = ($deployment.Parameters.$parameter.Value.ToString() | ConvertFrom-Json -AsHashtable)
                        $matched = ($null -eq (Compare-Object -ReferenceObject $deploymentValue -DifferenceObject $combinedParameters.$parameter))
                    }

                    if (!($matched)) {
                        $finalReport.MismatchedParameters += 1
                        Write-Verbose ("Found mismatched parameter {0} with value {1}" -f $parameter, $deploymentValue)
                    }
                }
            }
        }
        $finalReport
    }

    end {
        Write-Verbose "Ending Test-B42Deployment"
    }
}
