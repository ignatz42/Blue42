function Deploy-B42WebApp {
    <#
        .SYNOPSIS
        Deploys an Web App with additional common support option and optional SQL database.
        .DESCRIPTION
        The Deploy-B42WebApp function serves as a one touch deploy point for an Azure Web App.
        .EXAMPLE
        Deploy-B42WebApp
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
        [System.Collections.Specialized.OrderedDictionary] $WebAppParameters = [ordered]@{},

        # If $null, no database will be created.
        # If an empty [ordered] list is supplied, a new SQL Local instance and database will be created.
        # If the [ordered] list contains, sqlServerName, sqlAdminUser, sqlAdminPass a new database will be deployed to the specified local instance.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $SQLParameters = $null
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("WebApp")
        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $WebAppParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $WebAppParameters -Deployments $deployments
        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the WebApp"
        }

        # A KeyVault is required.
        if (!($WebAppParameters.Contains("keyVaultResourceGroupName") -and $WebAppParameters.Contains("keyVaultName"))) {
            $keyVaultReportCard = Deploy-B42KeyVault -ResourceGroupName $ResourceGroupName -Location "$Location" -IncludeCurrentUserAccess -KeyVaultParameters ([ordered]@{keyVaultName = $reportCard.Parameters.webAppName})
            $WebAppParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $WebAppParameters.Add("keyVaultName", $keyVaultReportCard.Parameters.keyVaultName)
        }

        if ($null -ne $SQLParameters) {
            $sqlReportCard = Deploy-B42SQL -ResourceGroupName $ResourceGroupName -Location "$Location" -SQLParameters $SQLParameters
            if ($reportCard.SimpleReport() -ne $true) {
                throw "Failed to deploy the SQL Server"
            }

            $dbDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("DB") -TemplateParameters ([ordered] @{sqlName = $sqlReportCard.Parameters.sqlName})
            $dbReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $AppServicePlanParameters -Deployments $dbDeployments
            if ($dbReportCard.SimpleReport() -ne $true) {
                throw "Failed to deploy the DB"
            }

            $sqlAppUser = $reportCard.Parameters.webAppName
            $sqlAppPass = New-B42Password
            $null = Add-Secret -SecretName "sqlAppUser" -SecretValue $sqlAppUser -KeyVaultName $WebAppParameters.keyVaultName
            $passSecret = Add-Secret -SecretName "sqlAppPass" -SecretValue $sqlAppPass -KeyVaultName $WebAppParameters.keyVaultName

            # Create a user for the webAppName to use for connection.
            $steps = @(
                @{
                    database   = "master"
                    sqlCommand = ("CREATE LOGIN [{0}] WITH PASSWORD = N'{1}'" -f $sqlAppUser, $sqlAppPass)
                }, # Creating Login
                @{
                    database   = "$webAppName"
                    sqlCommand = ("CREATE USER [{0}] FOR LOGIN [{0}]" -f $sqlAppUser)
                }, # Creating User
                @{
                    database   = "$webAppName"
                    sqlCommand = ("ALTER ROLE [db_owner] ADD MEMBER [{0}]" -f $sqlAppUser)
                } # Making User dbo
            )

            $ip = Get-MyIP
            $null = New-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -StartIpAddress $ip -EndIpAddress $ip -ResourceGroupName $ResourceGroupName -ServerName $sqlReportCard.Parameters.sqlName
            foreach ($step in $steps) {
                New-SQLCommand -SqlServerName $sqlReportCard.Parameters.sqlName -SqlDatabaseName $step.database -SqlUserName $sqlReportCard.Parameters.sqlAdminName -SqlUserPassword $passSecret.SecretValue -SqlCommand $step.sqlCommand
            }
            $null = Remove-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -ResourceGroupName $ResourceGroupName -ServerName $sqlReportCard.Parameters.sqlName
        }
        $reportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
