function Deploy-B42ASE {
    <#
        .SYNOPSIS
        Deploys an ASE.
        .DESCRIPTION
        The Deploy-B42ASE function serves as a one touch deploy point for an Azure Application Service Environment
        .EXAMPLE
        Deploy-B42ASE
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
        [string] $Location
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("ASE")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Location "$Location"
        $aseName = $deploymentResult.Parameters.aseName.Value
        if ([string]::IsNullOrEmpty($aseName)) {throw "Failed to obtain App Service Environment name"}
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
