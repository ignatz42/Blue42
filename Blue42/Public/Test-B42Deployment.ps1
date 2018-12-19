function Test-B42Deployment {
    <#
        .SYNOPSIS
        Test the Resource Group Deployments
        .DESCRIPTION
        The Test-B42Deployment function tests a group of resource deployment and attempts to return a go/no-go value
        First it verifies that each deployment is successful, then it compares the expected parameter values for each
        deployment match expected.
        .EXAMPLE
        Test-B42Deployment -Templates @("Vnet", "Subnet")
        .NOTES
        The custom class B42DeploymentReport has additonal details.
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
        [hashtable] $TemplateParameters = @{},

        # A list of deployments. If empty, the list will be fetched from the Resource Group.
        [Parameter(Mandatory=$false)]
        [System.Object[]] $Deployments = @()
    )

    begin {
        Write-Verbose "Starting Test-B42Deployment"
        $combinedParameters = Get-B42TemplateParameters -Templates $Templates -TemplatePath $TemplatePath -TemplateParameters $TemplateParameters
    }

    process {
        if ($Deployments.Count -eq 0) {
            $Deployments = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName
        }

        $finalReport = [B42DeploymentReport]::new()
        $finalReport.Deployments = $Deployments
        $finalReport.Parameters = $combinedParameters
        foreach ($deployment in $finalReport.Deployments) {
            # Count the successful deployments.
            $deploymentResult = ($deployment.ProvisioningState -eq "Succeeded")
            $finalReport.SuccessfulDeploymentCount += [int]$deploymentResult
            Write-Verbose ("Deployment {0} was successful?  {1}" -f $deployment.DeploymentName, $deploymentResult.ToString())

            foreach ($parameter in $deployment.Parameters.Keys) {
                if (!($combinedParameters.Contains($parameter))) { continue }

                $deploymentValue = $deployment.Parameters.$parameter.Value
                # This works around issue https://github.com/Azure/azure-powershell/issues/7410
                if (($deployment.Parameters.$parameter.Type -eq "Array") -or ($deployment.Parameters.$parameter.Type -eq "Object")) {
                    $deploymentValue = ($deployment.Parameters.$parameter.Value.ToString() | ConvertFrom-Json | ConvertFrom-B42Json)
                }

                # Count the mismatched parameters.
                $comparisionResult = Compare-Object -ReferenceObject $deploymentValue -DifferenceObject $combinedParameters.$parameter
                $finalReport.MismatchedParameters += [int]($null -ne $comparisionResult)
                Write-Verbose ("Parameter {0} has value {1} mismatch? {2}" -f $parameter, $deploymentValue, ($null -ne $comparisionResult).ToString())
            }
        }
        $finalReport
    }

    end {
        Write-Verbose "Ending Test-B42Deployment"
    }
}
