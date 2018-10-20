function Deploy-B42VM {
    <#
        .SYNOPSIS
        Deploys a VM.
        .DESCRIPTION
        The Deploy-B42VM function serves as a one touch deploy point for an Azure Virtual Machine
        .EXAMPLE
        Deploy-B42VM
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

        # Parameters used for VM creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $VMParameters = [ordered]@{},

        # An array of script extensions parameters blocks; one per desired extension.
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary[]] $ScriptExtensions = @()
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $templates = @("WinVM")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $templates -Location "$Location"
        $vmName = $deploymentResult.Parameters.vmName.Value
        if ([string]::IsNullOrEmpty($vmName)) {throw "Failed to obtain VM name"}

        foreach ($scriptExtension in $ScriptExtensions) {
            if (!$scriptExtension.Contains("vmName")) {
                $scriptExtension.Add("vmName", $vmName)
            }
            Write-Verbose "Etension"
            $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Templates @("VMExtension") -Location "$Location"
        }
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
