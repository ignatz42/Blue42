function New-SQLCommand {
    <#
    .SYNOPSIS
    Helper wrapper to run SQL Commands
    .DESCRIPTION
    The New-SQLCommand function helper works in the CI pipeline for executing stable SQL commands.
    .EXAMPLE
    New-SQLCommand -SqlServerName SqlServerName -SqlDatabaseName DatabaseName -SqlUserName UserName -SqlUserPassword UserPass
    .NOTES
    This quick and dirty commaned executor has no frills and is not safe.
    #>
    [CmdletBinding()]
    param (
        # The name of the Azure SQL Server
        [Parameter(Mandatory = $true)]
        [string] $SqlServerName,

        # The name of the database
        [Parameter(Mandatory = $true)]
        [string] $SqlDatabaseName,

        # The username
        [Parameter(Mandatory = $true)]
        [string] $SqlUserName,

        # The user password
        [Parameter(Mandatory = $true)]
        [securestring] $SqlUserPassword,

        # Simple SQL Command
        [Parameter(Mandatory = $true)]
        [string] $SqlCommand
    )

    begin {}

    process {
        # Decode the password for as little time as possible.
        $credentials = New-Object System.Net.NetworkCredential("UnusedUser", $SqlUserPassword, "UnusedDomain")
        $clearPassword = $credentials.Password.ToString()

        $connectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Initial Catalog=$SqlDatabaseName;User ID=$SqlUserName;Password=$clearPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
        try {
            $connection.Open()
            $command = New-Object -TypeName System.Data.SqlClient.SqlCommand($SqlCommand, $connection)
            $command.CommandTimeout = 120
            $queryResult = $command.ExecuteNonQuery()
        } catch {
            Write-Error $_.Exception.Message
        } finally {
            Write-Verbose $queryResult
            if (($null -ne $connection) -and ($connection.State.ToString() -eq "Open")) {
                $connection.Close()
            }
        }
    }

    end {}
}
