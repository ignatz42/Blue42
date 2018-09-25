function New-B42Deployment {
    <#
        .SYNOPSIS
        Retrieves service pack and operating system information from one or more remote computers.
        .DESCRIPTION
        The New-B42Deployment function uses the AzureRM module to perform a New-AzureRmResourceGroupDeployment using the supplied
        template and a (partial) parameter set. If no parameter set is supplied, the templates default parameters will be used.
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

        # An array of template names that will be combined into a single template then deployed to Azure
        [Parameter(Mandatory=$true)]
        [array] $Templates,

        # This parameter overrides the default search path. See Set/Get-B42Globals for the default path
        [Parameter(Mandatory=$false)]
        [string] $TemplatePath,

        # A list of override parameters. If empty, the default parameters supplied in the template will be used insted
        [Parameter(Mandatory=$false)]
        [hashtable] $TemplateParams = @{},

        # Perform a 'Complete' deployment instead of the default 'Incremental'
        [Parameter(Mandatory=$false)]
        [switch] $Complete
    )

    begin {
        Write-Verbose "Starting New-B42Deployment"
        $globals = Get-B42Globals
        if ([string]::IsNullOrEmpty($TemplatePath)) {
            $TemplatePath = $globals.TemplatePath
        }
        if ([string]::IsNullOrEmpty($Location)) {
            $Location = $globals.Location
        }
        $combinedParameters = Get-B42TemplateParameters -Templates $Templates -TemplatePath $TemplatePath -TemplateParams $TemplateParams
        $mode = "Incremental"
        if ($Complete) {
            $mode = "Complete"
        }
    }

    process {
        foreach ($template in $Templates) {
            $deploymentParameters = @{
                ResourceGroupName       = $ResourceGroupName
                Location                = $Location
                TemplatePath            = ("{0}\{1}.json" -f $TemplatePath, $template)
                TemplateParams          = (Get-B42TemplateParameters -Templates @($template) -TemplatePath $TemplatePath -TemplateParams $combinedParameters)
                Mode                    = $mode
                DeploymentDebugLogLevel = "None"
                Name                    = ("{0}_{1}" -f $template, (Get-DateTime15))
            }
            New-Deployment @deploymentParameters
        }
    }

    end {
        Write-Verbose "Ending New-B42Deployment"
    }
}
