function Deploy-B42AppService {
    <#
        .SYNOPSIS
        Deploys an App Service with optional Web Apps.
        .DESCRIPTION
        The Deploy-B42AppService function serves as a one touch deploy point for an Azure App Services
        .EXAMPLE
        Deploy-B42AppService
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

        # Parameters used for App Service creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $AppServiceParameters = [ordered]@{},

        # An array of web application parameters blocks; one per desired web app.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $WebApps = @(),

        # If $null, no database will be created.
        # If an empty [ordered] list is supplied, a new SQL Local instant and database will be created.
        # If the [ordered] list contains, sqlServerName, sqlAdminUser, sqlAdminPass a new database will be deployed to the specified local instance.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $SQLParameters = $null
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $accumulatedDeployments = @()
        $templates = @("AppServicePlan")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates
        $accumulatedDeployments += $deploymentResult
        $aspName = $deploymentResult.Parameters.aspName.Value
        if ([string]::IsNullOrEmpty($aspName)) {throw "Failed to obtain App Service name"}

        foreach ($webApp in $webApps) {
            if (!$webApp.Contains("aspName")) {
                $webApp.Add("aspName", $aspName)
            }
            if (!$webApp.Contains("aspResourceGroupName")) {
                $webApp.Add("aspResourceGroupName", $ResourceGroupName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("webApp") -TemplateParameters $webApp
            $accumulatedDeployments += $deploymentResult
            $webAppName = $deploymentResult.Parameters.webAppName.Value

            $currentContext = Get-AzContext
            $TenantID = $currentContext.Tenant.Id
            $ObjectID = (Get-AzADUser -StartsWith $currentContext.Account.Id).Id
            $kvParams = @{
                keyVaultName           = $webAppName
                keyVaultTenantID       = $TenantID
                keyVaultAccessPolicies = @((Get-B42KeyVaultAccessPolicy -ObjectID $ObjectID -TenantID $TenantID))
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("KeyVault") -TemplateParameters $kvParams
            $accumulatedDeployments += $deploymentResult
            $keyVaultName = $deploymentResult.Parameters.keyVaultName.Value

            if ($null -ne $SQLParameters) {
                # Do the database here.
                $thisSQLParameters = Get-B42TemplateParameters -Templates @("SQL") -TemplateParameters $SQLParameters
                $sqlDeploymentResult = Deploy-B42SQL -ResourceGroupName $ResourceGroupName -Location "$Location" -SQLParameters $thisSQLParameters -DBs @([ordered]@{ dbName = $webAppName })
                $accumulatedDeployments += $sqlDeploymentResult

                $sqlAppUser = $webAppName
                $sqlAppPass = New-B42Password
                $null = Add-Secret -SecretName "sqlAppUser" -SecretValue $sqlAppUser -KeyVaultName $keyVaultName
                $passSecret = Add-Secret -SecretName "sqlAppPass" -SecretValue $sqlAppPass -KeyVaultName $keyVaultName

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
                $null = New-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -StartIpAddress $ip -EndIpAddress $ip -ResourceGroupName $ResourceGroupName -ServerName $thisSQLParameters.sqlName
                foreach ($step in $steps) {
                    New-SQLCommand -SqlServerName $thisSQLParameters.sqlName -SqlDatabaseName $step.database -SqlUserName $thisSQLParameters.sqlAdminName -SqlUserPassword $passSecret.SecretValue -SqlCommand $step.sqlCommand
                }
                $null = Remove-AzSqlServerFirewallRule -FirewallRuleName "OriginalConfiguration" -ResourceGroupName $ResourceGroupName -ServerName $thisSQLParameters.sqlName
            }
        }

        # TODO: Return a report card here instead.
        $accumulatedDeployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
