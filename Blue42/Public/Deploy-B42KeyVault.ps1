function Deploy-B42KeyVault {
    <#
        .SYNOPSIS
        Deploys a KeyVault.
        .DESCRIPTION
        The Deploy-B42KeyVault function serves as a one touch deploy point for an Azure Application Service Environment
        .EXAMPLE
        Deploy-B42KeyVault
        .NOTES
        Run this function after establishing an Az context using Connect-AzAccount.
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory=$false)]
        [string] $Location,

        # Parameters used for KeyVault creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $KeyVaultParameters = [ordered]@{},

        [Parameter(Mandatory = $false)]
        [switch] $IncludeCurrentUserAccess
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        # Used for TenantID and when making an access policy
        $currentContext = Get-AzContext

        $templates = @("KeyVault")
        if (!($KeyVaultParameters.Contains("keyVaultTenantID"))) {
            $KeyVaultParameters.Add("keyVaultTenantID", $currentContext.Tenant.Id)
        }

        if ($IncludeCurrentUserAccess) {
            # First check to see if it's there, if not add a new one.
            $ObjectID = (Get-AzADUser -StartsWith $currentContext.Account.Id).Id
            if (($KeyVaultParameters.Contains("keyVaultAccessPolicies"))) {
            } else {
                $KeyVaultParameters.Add("keyVaultAccessPolicies", @((Get-B42KeyVaultAccessPolicy -ObjectID $ObjectID -TenantID $currentContext.Tenant.Id)))
            }
        }

        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Location "$Location" -TemplateParameters $KeyVaultParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Deployments $deployments -TemplateParameters $KeyVaultParameters

        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the KeyVault"
        }
        if (!($KeyVaultParameters.Contains("keyVaultName"))) {
            $KeyVaultParameters.Add("keyVaultName", $reportCard.Parameters.keyVaultName)
        }
        if (!($KeyVaultParameters.Contains("keyVaultResourceGroupName"))) {
            $KeyVaultParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
        }
        $reportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
