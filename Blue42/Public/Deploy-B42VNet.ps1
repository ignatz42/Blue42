function Deploy-B42VNet {
    <#
        .SYNOPSIS
        Deploys a VNet.
        .DESCRIPTION
        The Deploy-B42VNet function serves as a one touch deploy point for an Azure Virtual Network
        .EXAMPLE
        Deploy-B42VNet
        .NOTES
        You need to run this function after establishing an AzureRm context using Login-AzureRmAccount
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory = $false)]
        [string] $Location = $null,

        # Parameters used for VNet creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $VNetParameters = [ordered]@{},

        # An array of subnet parameters blocks; one per desired subnet.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $Subnets = @(),

        # Include a Distributed Denial of Service plan
        [Parameter(Mandatory = $false)]
        [switch] $IncludeDDos
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("VNet")
        if ($IncludeDDos) {
            $templates = @("DDosPlan", "VNet")
        }
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Location "$Location"
        $vnetName = $deploymentResult.Parameters.vnetName.Value
        if ([string]::IsNullOrEmpty($vnetName)) {throw "Failed to obtain VNet name"}

        foreach ($subnet in $Subnets) {
            if (!$subnet.Contains("vnetName")) {
                $subnet.Add("vnetName", $vnetName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates @("Subnet") -Location "$Location"
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
