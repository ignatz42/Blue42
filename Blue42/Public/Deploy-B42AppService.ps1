function Deploy-B42AppService {
    <#
        .SYNOPSIS
        Deploys an App Service with optional Web Apps.
        .DESCRIPTION
        The Deploy-B42AppService function serves as a one touch deploy point for an Azure App Services
        .EXAMPLE
        Deploy-B42AppService
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
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("webApp") -TemplateParameters $webApp
            $accumulatedDeployments += $deploymentResult

            if ($null -ne $SQLParameters) {
                # Do the database here.
                if (!$SQLParameters.Contains("sqlAdminUser")) {
                    $SQLParameters.Add("sqlAdminUser", "azsa")
                }
                if (!$SQLParameters.Contains("sqlAdminPass")) {
                    $SQLParameters.Add("sqlAdminPass", (New-B42Password))
                }
                $sqlDeploymentResult = New-B42SQL -ResourceGroupName $ResourceGroupName -Location "$Location" -SQLParameters $SQLParameters -DBs @{databaseName = $webApp}
                $accumulatedDeployments += $sqlDeploymentResult

                # Create a user for the webApp to use for connection.
                $steps = @(
                    @{
                        database   = "master"
                        sqlCommand = ("CREATE LOGIN [{0}] WITH PASSWORD = N'{1}'" -f $sqlAppUser, $sqlAppPwd)
                    }, # Creating Login
                    @{
                        database   = "$webApp"
                        sqlCommand = ("CREATE USER [{0}] FOR LOGIN [{0}]" -f $sqlAppUser)
                    }, # Creating User
                    @{
                        database   = "$webApp"
                        sqlCommand = ("ALTER ROLE [db_owner] ADD MEMBER [{0}]" -f $sqlAppUser)
                    } # Making User dbo
                )

                foreach ($step in $steps) {
                    New-SQLCommand -SqlServerName $sqlDeploymentResult.Para.sqlName -SqlDatabaseName $step.database -SqlUserName $SQLParameters.sqlAdminUser -SqlUserPassword $SQLParameters.sqlAdminPassword -SqlCommand $step.sqlCommand
                }
            }
        }

        # TODO: Return a report card here instead.
        $accumulatedDeployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
