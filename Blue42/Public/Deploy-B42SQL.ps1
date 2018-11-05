function Deploy-B42SQL {
    <#
        .SYNOPSIS
        Deploys a SQL instance.
        .DESCRIPTION
        The Deploy-B42SQL function serves as a one touch deploy point for an Azure SQL Instance
        .EXAMPLE
        Deploy-B42SQL
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
        $templates = @("SQL")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $SQLParameters
        $sqlName = $deploymentResult.Parameters.sqlName.Value
        if ([string]::IsNullOrEmpty($sqlName)) {throw "Failed to obtain SQL name"}

        if (![string]::IsNullOrEmpty($DisplayName)) {
            Set-AzureRmSqlServerActiveDirectoryAdministrator -ResourceGroupName $ResourceGroupName -ServerName $sqlName -DisplayName "$AADDisplayName"
        }

        foreach ($db in $DBs) {
            if (!$db.Contains("sqlName")) {
                $db.Add("sqlName", $sqlName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("DB") -TemplateParameters $db
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
