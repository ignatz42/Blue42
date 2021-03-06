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

        # Display Name of the Azure Active Directory User or Group that will become the SQL Server Administrator
        [Parameter(Mandatory = $false)]
        [string] $AADDisplayName = ""
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        if (!($SQLParameters.Contains("sqlAdminPassword"))) {
            $SQLParameters.Add("sqlAdminPassword", (New-B42Password))
        }

        $templates = @("SQL")
        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $SQLParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $SQLParameters -Deployments $deployments
        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the SQL Server local instance"
        }
        if (!($SQLParameters.Contains("sqlName"))) {
            $SQLParameters.Add("sqlName", $reportCard.Parameters.sqlName)
        }
        if (!($SQLParameters.Contains("sqlAdminName"))) {
            $SQLParameters.Add("sqlAdminName", $reportCard.Parameters.sqlAdminName)
        }

        # Add a KeyVault.
        $null = Deploy-B42KeyVault -ResourceGroupName $ResourceGroupName -Location "$Location" -IncludeCurrentUserAccess -KeyVaultParameters ([ordered]@{keyVaultName = $SQLParameters.sqlName})
        $null = Add-Secret -SecretName "sqlAdminUser" -SecretValue $SQLParameters.sqlAdminName -KeyVaultName $SQLParameters.sqlName
        $null = Add-Secret -SecretName "sqlAdminPass" -SecretValue $SQLParameters.sqlAdminPassword -KeyVaultName $SQLParameters.sqlName

        if (![string]::IsNullOrEmpty($AADDisplayName)) {
            $null = Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName $ResourceGroupName -ServerName $SQLParameters.sqlName -DisplayName "$AADDisplayName"
        }

        $reportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
