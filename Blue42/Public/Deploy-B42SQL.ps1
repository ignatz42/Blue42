function Deploy-B42SQL {
    <#
        .SYNOPSIS
        Deploys a SQL instance.
        .DESCRIPTION
        The Deploy-B42SQL function serves as a one touch deploy point for an Azure SQL Instance
        .EXAMPLE
        Deploy-B42SQL
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

        # Parameters used for SQL creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $SQLParameters = [ordered]@{},

        # An array of database parameters blocks; one per desired database.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $DBs = @(),

        # Display Name of the Azure Active Directory User or Group that will become the SQL Server Administrator
        [Parameter(Mandatory = $false)]
        [string] $AADDisplayName = ""
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $accumulatedDeployments = @()
        $templates = @("SQL")
        $thisSQLParameters = Get-B42TemplateParameters -Templates $templates -TemplateParameters $SQLParameters
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $thisSQLParameters
        $accumulatedDeployments += $deploymentResult
        $sqlName = $deploymentResult.Parameters.sqlName.Value
        if ([string]::IsNullOrEmpty($sqlName)) {throw "Failed to obtain SQL name"}

        # Add a KeyVault.
        $currentContext = Get-AzContext
        $TenantID = $currentContext.Tenant.Id
        $ObjectID = (Get-AzADUser -StartsWith $currentContext.Account.Id).Id
        $kvParams = @{
            keyVaultName           = $sqlName
            keyVaultTenantID       = $TenantID
            keyVaultAccessPolicies = @((Get-B42KeyVaultAccessPolicy -ObjectID $ObjectID -TenantID $TenantID))
        }
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("KeyVault") -TemplateParameters $kvParams
        $accumulatedDeployments += $deploymentResult
        $keyVaultName = $deploymentResult.Parameters.keyVaultName.Value

        $null = Add-Secret -SecretName "sqlAdminUser" -SecretValue $thisSQLParameters.sqlAdminName -KeyVaultName $keyVaultName
        $null = Add-Secret -SecretName "sqlAdminPass" -SecretValue $thisSQLParameters.sqlAdminPassword -KeyVaultName $keyVaultName

        if (![string]::IsNullOrEmpty($DisplayName)) {
            Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName $ResourceGroupName -ServerName $sqlName -DisplayName "$AADDisplayName"
        }

        foreach ($db in $DBs) {
            if (!$db.Contains("sqlName")) {
                $db.Add("sqlName", $sqlName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("DB") -TemplateParameters $db
            $accumulatedDeployments += $deploymentResult
        }

        # TODO: Return a report card here instead.
        $accumulatedDeployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
