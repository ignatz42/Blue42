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

        # The URI of the Blob where a disk image is store
        [Parameter(Mandatory=$true)]
        [string] $ImageOsDiskBlobUri,

        # Parameters used for VM creation
        [Parameter(Mandatory = $false)]
        [System.Collections.Specialized.OrderedDictionary] $VMSSParameters = [ordered]@{},

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
        if (!($VMSSParameters.Contains("vnetResourceGroupName") -and $VMSSParameters.Contains("vnetName") -and $VMSSParameters.Contains("subnetName"))) {
            $vnetParams = Get-B42TemplateParameters -Templates @("VNet")
            $subnetParams = Get-B42TemplateParameters -Templates @("Subnet")
            $accumulatedDeployments += Deploy-B42VNet -ResourceGroupName $ResourceGroupName -Location $Location -VNetParameters $vnetParams -Subnets @($subnetParams)
            # Carry along these values to the VMDeployment.
            $VMSSParameters.Add("vnetResourceGroupName", $ResourceGroupName)
            $VMSSParameters.Add("vnetName", $vnetParams.vnetName)
            $VMSSParameters.Add("subnetName", $subnetParams.subnetName)
        }

        if (!($VMSSParameters.Contains("keyVaultResourceGroupName") -and $VMSSParameters.Contains("keyVaultName"))) {
            $keyVaultResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates @("KeyVault")
            $accumulatedDeployments += $keyVaultResult
            # Carry along these values to the VMDeployment.
            $VMSSParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $VMSSParameters.Add("keyVaultName", $keyVaultResult.Parameters.keyVaultName)

            # TODO Linux.
            $certPath = ("{0}\Blue42VM.pfx" -f (Convert-Path -Path ".\"))
            $certForms = Get-B42CertificateForms -CertificatePath $certPath -DomainNames @("testing.local")
            Remove-Item $certPath

            $null = Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "CertPassword" -SecretValue $certForms.Password
            $certSecret = Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "Cert" -SecretValue $certForms.JsonArray
            $VMSSParameters.Add("vmCertificateSecretUrl", $certSecret.Id)

            # Add the admin user and password.
            # Should the VMSS just reference the password in the keyVault?
            $aUser = "azdam"
            $aPass = (New-B42Password)
            $VMSSParameters.Add("vmAdminUsername", $aUser)
            $VMSSParameters.Add("vmAdminPassword", $aPass)
            Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "AdminUsername" -SecretValue $aUser
            Add-Secret -KeyVaultName $keyVaultResult.Parameters.keyVaultName.Value -SecretName "AdminPassword" -SecretValue $aPass
        }

        $imageDeploymentResults = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location $Location -Templates @("Image") -TemplateParameters @{ imageOsDiskBlobUri = $ImageOsDiskBlobUri}
        $accumulatedDeployments += $imageDeploymentResults
        $VMSSParameters.Add("imageName", $imageDeploymentResults.Parameters.imageName)
        $VMSSParameters.Add("imageResourceGroupName", $ResourceGroupName)

        $publicIPResults = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location $Location -Templates @("PublicIP") -TemplateParameters @{ imageOsDiskBlobUri = $ImageOsDiskBlobUri}
        $accumulatedDeployments += $publicIPResults
        $loadBalancerResults = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location $Location -Templates @("LoadBalancer") -TemplateParameters $publicIPResults.Parameters
        $accumulatedDeployments += $loadBalancerResults
        $VMSSParameters.Add("loadBalancerName", $imageDeploymentResults.Parameters.imageName)
        $VMSSParameters.Add("loadBalancerResourceGroupName", $ResourceGroupName)

        $templates = @("WinVMSS")
        $deploymentResult = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $templates -TemplateParameters $VMSSParameters
        $accumulatedDeployments += $deploymentResult
        $vmssName = $deploymentResult.Parameters.vmssName.Value
        if ([string]::IsNullOrEmpty($vmssName)) {throw "Failed to obtain VMSS name"}

        if($deploymentResult.Parameters.vmIdentity.Value -eq "SystemAssigned"){
            # Find the Managed Service Identity PrincipalId and grant it permission to query the secrets.
            $vmInfoPS = Get-AzureRMVM -ResourceGroupName $ResourceGroupName -Name $vmssName
            if (![string]::IsNullOrEmpty($vmInfoPS.Identity.PrincipalId)) {
                Set-AzureRmKeyVaultAccessPolicy -VaultName $VMSSParameters.keyVaultName -PermissionsToSecrets get, list -ObjectId $vmInfoPS.Identity.PrincipalId
            }
        }

        # TODO: Return a report card here instead.
        $accumulatedDeployments
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
