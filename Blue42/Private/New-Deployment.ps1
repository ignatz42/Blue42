function New-Deployment {
    <#
        .SYNOPSIS
        Retrieves service pack and operating system information from one or more remote computers.
        .DESCRIPTION
        The New-Deployment function uses the Az module to perform a New-AzResourceGroupDeployment into a Resource Group.
        If the Resource Group doesn't exist, the function will create it before performing the deployment.
        .NOTES
        Run this function after establishing an Az context using Connect-AzAccount
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
        [hashtable] $TemplateParameters,

        # The name of the Azure Deployment
        [Parameter(Mandatory=$true)]
        [string] $Name,

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
        Write-Verbose "B42 - Starting new deployment: $TemplatePath"
    }

    process {
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction 0
        if ($null -eq $rg) {
            $rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        }

        $deploymentParameters = @{
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = $TemplatePath
            TemplateParameterObject = $TemplateParameters
            Name                    = $Name
            Mode                    = $Mode
            DeploymentDebugLogLevel = $DeploymentDebugLogLevel
        }
        New-AzResourceGroupDeployment @deploymentParameters -Confirm:$false -Force
    }

    end {}
}
