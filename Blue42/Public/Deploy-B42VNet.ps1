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
        [switch] $IncludeDDos,

        # If supplied, a private DNS Zone will be created using the parameter's value
        [Parameter(Mandatory = $false)]
        [string] $PrivateDNSZone = ""
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("VNet")
        if ($IncludeDDos) {
            $templates = @("DDosPlan", "VNet")
        }
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates
        $vnetName = $deploymentResult.Parameters.vnetName.Value
        if ([string]::IsNullOrEmpty($vnetName)) {throw "Failed to obtain VNet name"}

        if (![string]::IsNullOrEmpty($PrivateDNSZone)) {
            $thisVnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName
            $null = New-AzureRmDnsZone -Name $PrivateDNSZone -ResourceGroupName $ResourceGroupName -ZoneType Private -ResolutionVirtualNetworkId @($thisVnet.Id)
            $null = Set-AzureRmDnsZone -Name $PrivateDNSZone -ResourceGroupName $ResourceGroupName -ResolutionVirtualNetworkId @($thisVnet.Id)
        }

        foreach ($subnet in $Subnets) {
            if (!$subnet.Contains("vnetName")) {
                $subnet.Add("vnetName", $vnetName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("Subnet") -TemplateParameters $subnet
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
