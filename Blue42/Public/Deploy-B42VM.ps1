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

        # If true, a Public IP and NSG will be created for the VM
        [Parameter(Mandatory = $false)]
        [switch] $IncludePublicInterface,

        # If true, the vm will use linux specific configuraiton settings. If false, the vm will use windows specific configuration settings.
        [Parameter (Mandatory = $false)]
        [switch] $IsLinux
    )

    begin {
        Write-Verbose ("{0} started at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }

    process {
        $accumulatedDeployments = @()
        # The parameters in VirtualNetworkParameters are required. If not provided, create some defaults.
        if (!($VMParameters.Contains("vnetResourceGroupName") -and $VMParameters.Contains("vnetName") -and $VMParameters.Contains("subnetName"))) {
            $vnetParams = Get-B42TemplateParameters -Templates @("VNet")
            $subnetParams = Get-B42TemplateParameters -Templates @("Subnet")
            $accumulatedDeployments += Deploy-B42VNet -ResourceGroupName $ResourceGroupName -Location $Location -VNetParameters $vnetParams -Subnets @($subnetParams)
            # Carry along these values to the VMDeployment.
            $VMParameters.Add("vnetResourceGroupName", $ResourceGroupName)
            $VMParameters.Add("vnetName", $vnetParams.vnetName)
            $VMParameters.Add("subnetName", $subnetParams.subnetName)
        }

        if (!($VMParameters.Contains("keyVaultResourceGroupName") -and $VMParameters.Contains("keyVaultName"))) {
            $currentContext = Get-AzureRmContext
            $TenantID = $currentContext.Tenant.Id
            $ObjectID = (Get-AzureRmADUser -StartsWith $currentContext.Account.Id).Id
            $kvParams = @{
                keyVaultTenantID                     = $TenantID
                keyVaultAccessPolicies               = @((Get-B42KeyVaultAccessPolicy -ObjectID $ObjectID -TenantID $TenantID))
                keyVaultEnabledForDeployment         = $true
                keyVaultEnabledForTemplateDeployment = $true
            }
            $keyVaultResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("KeyVault") -TemplateParameters $kvParams
            $accumulatedDeployments += $keyVaultResult
            # Carry along these values to the VMDeployment.
            $VMParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $VMParameters.Add("keyVaultName", $keyVaultResult.Parameters.keyVaultName.Value)

            # TODO Linux.
            $certPath = ("{0}\Blue42VM.pfx" -f (Convert-Path -Path ".\"))
            $certForms = Get-B42CertificateForms -CertificatePath $certPath -DomainNames @("testing.local")
            Remove-Item $certPath

            $null = Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "CertPassword" -SecretValue $certForms.Password
            $certSecret = Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "Cert" -SecretValue $certForms.JsonArray
            $VMParameters.Add("vmCertificateSecretUrl", $certSecret.Id)

            # Add the admin user and password.
            # Should the VM just reference the password in the keyVault?
            $aUser = "azdam"
            $aPass = (New-B42Password)
            $VMParameters.Add("vmAdminUsername", $aUser)
            $VMParameters.Add("vmAdminPassword", $aPass)
            Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "AdminUsername" -SecretValue $aUser
            Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "AdminPassword" -SecretValue $aPass
        }
        # Create a NIC here
        $templates = @("NetworkInterface")
        $nicParams = Get-B42TemplateParameters -Templates $templates -TemplateParameters $VMParameters
        if ($IncludePublicInterface) {
            # Ok.  This should probably be more simple. Not sure that the $pipnsgResult order is guaranteed. The alternative
            # may be simply to Test-B42Deployment to combine the parameter sets?
            $pipnsgParameters = Get-B42TemplateParameters -Templates @("PublicIP", "NSG") -TemplateParameters $nicParams
            $list = Get-NSGList -IsLinux:$IsLinux
            $pipnsgParameters.nsgSecurityRules = $list
            $accumulatedDeployments += New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("PublicIP", "NSG") -TemplateParameters $pipnsgParameters
            $nicParams.publicIPName = $pipnsgParameters.publicIPName
            $nicParams.nsgName = $pipnsgParameters.nsgName
        }
        $nicDeploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $nicParams
        $accumulatedDeployments += $nicDeploymentResult
        $VMParameters.Add("networkInterfaceName", $nicDeploymentResult.Parameters.networkInterfaceName.Value)

        # TODO: More tokens for resourceid
        if ($VMParameters.Contains("imageName")) {
            $VMParameters.Add("vmImagePublisher", "")
            $VMParameters.Add("vmImageOffer", "")
            $VMParameters.Add("vmImageSKU", "")
        }

        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("WinVM") -TemplateParameters $VMParameters
        $accumulatedDeployments += $deploymentResult
        $vmName = $deploymentResult.Parameters.vmName.Value
        if ([string]::IsNullOrEmpty($vmName)) {throw "Failed to obtain VM name"}

        if($deploymentResult.Parameters.vmIdentity.Value -eq "SystemAssigned"){
            # Find the Managed Service Identity PrincipalId and grant it permission to query the secrets.
            $vmInfoPS = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
            if (![string]::IsNullOrEmpty($vmInfoPS.Identity.PrincipalId)) {
                Set-AzureRmKeyVaultAccessPolicy -VaultName $VMParameters.keyVaultName -PermissionsToSecrets get, list -ObjectId $vmInfoPS.Identity.PrincipalId
            }
        }

        # TODO: Return a report card here instead.
        $accumulatedDeployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
