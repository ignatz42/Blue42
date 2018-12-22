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
        # An App Service Plan is required
        if (!($WebAppParameters.Contains("aspResourceGroupName") -and $WebAppParameters.Contains("aspName"))) {
            $appServivePlanReportCard = Deploy-B42AppService -ResourceGroupName $ResourceGroupName -Location "$Location" -AppServicePlanParameters $WebAppParameters
        }

        $templates = @("AppInsights", "WebApp")
        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $WebAppParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $WebAppParameters -Deployments $deployments
        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the WebApp"
        }
        $WebAppParameters.Add("webAppName", $reportCard.Parameters.webAppName)

        # A KeyVault is required
        if (!($WebAppParameters.Contains("keyVaultResourceGroupName") -and $WebAppParameters.Contains("keyVaultName"))) {
            $keyVaultReportCard = Deploy-B42KeyVault -ResourceGroupName $ResourceGroupName -Location "$Location" -IncludeCurrentUserAccess -KeyVaultParameters ([ordered]@{keyVaultName = $WebAppParameters.webAppName})
            $WebAppParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $WebAppParameters.Add("keyVaultName", $keyVaultReportCard.Parameters.keyVaultName)
        }

        if ($null -ne $SQLParameters) {
            if (!($SQLParameters.Contains("sqlName"))) {
                $sqlReportCard = Deploy-B42SQL -ResourceGroupName $ResourceGroupName -Location "$Location" -SQLParameters $SQLParameters
            }
            # The SQL Server should have an accompanying KV with the same name where the admin/user pass is stored from the previous step.
            # TODO: Fetch them.

            $SQLParameters.Add("dbName", $WebAppParameters.webAppName)
            $dbDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("DB") -TemplateParameters $SQLParameters
            $dbReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $SQLParameters -Deployments $dbDeployments
            if ($dbReportCard.SimpleReport() -ne $true) {
                throw "Failed to deploy the DB"
            }

            $sqlAppUser = $WebAppParameters.webAppName
            $sqlAppPass = New-B42Password
            $null = Add-Secret -SecretName "sqlAppUser" -SecretValue $sqlAppUser -KeyVaultName $WebAppParameters.keyVaultName
            $null = Add-Secret -SecretName "sqlAppPass" -SecretValue $sqlAppPass -KeyVaultName $WebAppParameters.keyVaultName

            # Create a user for the webAppName to use for connection.
            $steps = @(
                @{
                    database   = "master"
                    sqlCommand = ("CREATE LOGIN [{0}] WITH PASSWORD = N'{1}'" -f $sqlAppUser, $sqlAppPass)
                }, # Creating Login
                @{
                    database   = $SQLParameters.dbName
                    sqlCommand = ("CREATE USER [{0}] FOR LOGIN [{0}]" -f $sqlAppUser)
                }, # Creating User
                @{
                    database   = $SQLParameters.dbName
                    sqlCommand = ("ALTER ROLE [db_owner] ADD MEMBER [{0}]" -f $sqlAppUser)
                } # Making User dbo
            )

            $sqlUserPassword = (ConvertTo-SecureString -AsPlainText -Force -String $SQLParameters.sqlAdminPassword)
            $ip = Get-MyIP
            $null = New-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -StartIpAddress $ip -EndIpAddress $ip -ResourceGroupName $ResourceGroupName -ServerName $SQLParameters.sqlName
            foreach ($step in $steps) {
                New-SQLCommand -SqlServerName $SQLParameters.sqlName -SqlDatabaseName $step.database -SqlUserName $SQLParameters.sqlAdminName -SqlUserPassword $sqlUserPassword -SqlCommand $step.sqlCommand
            }
            $null = Remove-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -ResourceGroupName $ResourceGroupName -ServerName $SQLParameters.sqlName
        }
        $reportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
