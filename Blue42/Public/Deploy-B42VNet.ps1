function Deploy-B42VNet {
    <#
        .SYNOPSIS
        Deploys a VNet.
        .DESCRIPTION
        The Deploy-B42VNet function serves as a one touch deploy point for an Azure Virtual Network
        .EXAMPLE
        Deploy-B42VNet
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
        [string] $Location = $null,

        # Parameters used for VNet creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $VNetParameters = [ordered]@{},

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
        $templates = @()
        if ($IncludeDDos) {
            $templates += "DDosPlan"
        }
        $templates += "VNet"

        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $VNetParameters
        $reportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $VNetParameters -Deployments $deployments

        if ($reportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy VNet"
        }
        $vnetName = $reportCard.Parameters.vnetName

        # This must be done before any subnets are added to the vnet.
        if (![string]::IsNullOrEmpty($PrivateDNSZone)) {
            $thisVnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName
            $null = New-AzDnsZone -Name $PrivateDNSZone -ResourceGroupName $ResourceGroupName -ZoneType Private -ResolutionVirtualNetworkId @($thisVnet.Id)
            $null = Set-AzDnsZone -Name $PrivateDNSZone -ResourceGroupName $ResourceGroupName -ResolutionVirtualNetworkId @($thisVnet.Id)
        }

        # Take advantage of incremental ARM deployment for clarity.  Only the subnet will be added the then the report card will be returned.
        $templates += "Subnet"
        $deployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $reportCard.Parameters
        Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -TemplateParameters $VNetParameters -Deployments $deployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
