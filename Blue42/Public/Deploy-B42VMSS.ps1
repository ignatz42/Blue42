function Deploy-B42VMSS {
    <#
        .SYNOPSIS
        Deploys a VMSS.
        .DESCRIPTION
        The Deploy-B42VMSS function serves as a one touch deploy point for an Azure Virtual Machine Scale Set
        .EXAMPLE
        Deploy-B42VMSS
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

        # Parameters used for VMSS creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $VMSSParameters = [ordered]@{},

        # An array of script extensions parameters blocks; one per desired extension.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $ScriptExtensions = @()
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("WinVMSS")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Location "$Location"
        $vmssName = $deploymentResult.Parameters.vmssName.Value
        if ([string]::IsNullOrEmpty($vmssName)) {throw "Failed to obtain VMSS name"}

        foreach ($scriptExtension in $scriptExtensions) {
            if (!$scriptExtension.Contains("vmssName")) {
                $scriptExtension.Add("vmssName", $vmssName)
            }
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates @("VMSSExtension") -Location "$Location"
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
