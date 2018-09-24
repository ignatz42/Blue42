function New-Deployment {
    <#
        .SYNOPSIS
        Retrieves service pack and operating system information from one or more remote computers.
        .DESCRIPTION
        The New-Deployment function uses the AzureRM module to perform a New-AzureRmResourceGroupDeployment into a Resource Group.
        If the Resource Group doesn't exist, the function will create it before performing the deployment.
        .NOTES
        You need to run this function after establishing an AzureRm context using Login-AzureRmAccount.
    #>
    [CmdletBinding()]
    param (
        # The destination Resource Group Name
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,

        # The destination Azure region
        [Parameter(Mandatory=$true)]
        [string] $Location,

        # The full path to the source ARM template
        [Parameter(Mandatory=$true)]
        [string] $TemplatePath,

        # The collection of template parameters
        [Parameter(Mandatory=$true)]
        [hashtable] $TemplateParams,

        # The name of the Azure Deployment
        [Parameter(Mandatory=$false)]
        [string] $Name = ("B42{0}" -f (Get-DateTime15)),

        # The deployment mode
        [Parameter(Mandatory=$false)]
        [ValidateSet('Incremental', 'Complete')]
        [string] $Mode = "Incremental",

        # The debug level for the deployment
        [Parameter(Mandatory=$false)]
        [ValidateSet('RequestContent', 'ResponseContent', 'All', 'None')]
        [string] $DeploymentDebugLogLevel = "None"
    )

    begin {
        Write-Verbose "Starting New-Deployment"
    }

    process {
        $rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction 0
        if ($null -eq $rg) {
            $rg = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
        }

        $deploymentParameters = @{
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = $TemplatePath
            TemplateParameterObject = $TemplateParams
            Name                    = $Name
            Mode                    = $Mode
            DeploymentDebugLogLevel = $DeploymentDebugLogLevel
        }
        New-AzureRmResourceGroupDeployment @deploymentParameters -Confirm:$false -Force
    }

    end {
        Write-Verbose "Ending New-Deployment"
    }
}
