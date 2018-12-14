function Deploy-B42VMSS {
    <#
        .SYNOPSIS
        Deploys a VMSS.
        .DESCRIPTION
        The Deploy-B42VMSS function serves as a one touch deploy point for an Azure Virtual Machine Scale Set
        .EXAMPLE
        Deploy-B42VMSS
        .NOTES
        Run this function after establishing an Az context using Connect-AzAccount
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
        # The parameters in VirtualNetworkParameters are required. If not provided, create some defaults.
        if (!($VMSSParameters.Contains("vnetResourceGroupName") -and $VMSSParameters.Contains("vnetName") -and $VMSSParameters.Contains("subnetName"))) {
            $vnetReportCard = Deploy-B42VNet -ResourceGroupName $ResourceGroupName -Location "$Location" -VNetParameters $VMSSParameters
            # Carry along these values to the VMDeployment.
            $VMSSParameters.Add("vnetResourceGroupName", $ResourceGroupName)
            $VMSSParameters.Add("vnetName", $vnetReportCard.Parameters.vnetName)
            $VMSSParameters.Add("subnetName", $vnetReportCard.Parameters.subnetName)
        }

        # A KeyVault is required, if one wasn't supplied create it then add the admin user and password.
        if (!($VMSSParameters.Contains("keyVaultResourceGroupName") -and $VMSSParameters.Contains("keyVaultName"))) {
            $keyVaultReportCard = Deploy-B42KeyVault -ResourceGroupName $ResourceGroupName -Location "$Location" -IncludeCurrentUserAccess -KeyVaultParameters ([ordered]@{keyVaultEnabledForDeployment = $true; keyVaultEnabledForTemplateDeployment = $true})
            # These values are required
            $VMSSParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $VMSSParameters.Add("keyVaultName", $keyVaultReportCard.Parameters.keyVaultName)
        }
        # Should the VMSS just reference the password in the keyVault?
        $userSecret = Add-Secret -KeyVaultName $VMSSParameters.keyVaultName -SecretName "AdminUsername" -SecretValue "azdam"
        $passSecret = Add-Secret -KeyVaultName $VMSSParameters.keyVaultName -SecretName "AdminPassword" -SecretValue (New-B42Password)
        $VMSSParameters.Add("vmssAdminUsername", $userSecret.SecretValueText)
        $VMSSParameters.Add("vmssAdminPassword", $passSecret.SecretValueText)

        if (!($VMSSParameters.Contains("imageOsDiskBlobUri"))) {
            # Maybe just check to see if this here? idk.
            $VMSSParameters.Add("imageOsDiskBlobUri", $ImageOsDiskBlobUri)
        }

        $prereqTemplates = @("Image", "PublicIP", "LoadBalancer")
        $prereqDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location $Location -Templates $prereqTemplates -TemplateParameters $VMSSParameters
        $prereqReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $prereqTemplates -Deployments $prereqDeployments -TemplateParameters $VMSSParameters
        $VMSSParameters.Add("imageName", $prereqReportCard.Parameters.imageName)
        $VMSSParameters.Add("imageResourceGroupName", $ResourceGroupName)
        $VMSSParameters.Add("loadBalancerName", $prereqReportCard.Parameters.imageName)
        $VMSSParameters.Add("loadBalancerResourceGroupName", $ResourceGroupName)

        $requiredTemplates = @()
        if ($IsLinux) {
            # TODO SSH bits
        } else {
            $requiredTemplates += @("WinVMSS")

            # Create a self-signed cert for use with WinRM over HTTPS
            $certPath = ("{0}\Blue42VM.pfx" -f (Convert-Path -Path ".\"))
            $certForms = Get-B42CertificateForms -CertificatePath $certPath -DomainNames @("testing.local")
            # TODO Why is this still here?  Should the helper delete it?
            $null = Remove-Item $certPath

            $null = Add-Secret -KeyVaultName $VMSSParameters.keyVaultName -SecretName "CertPassword" -SecretValue $certForms.Password
            $certSecret = Add-Secret -KeyVaultName $VMSSParameters.keyVaultName -SecretName "Cert" -SecretValue $certForms.JsonArray
            $VMSSParameters.Add("vmssCertificateSecretUrl", $certSecret.Id)
        }

        $requiredDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $requiredTemplates -TemplateParameters $VMSSParameters
        $requiredReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $requiredTemplates -TemplateParameters $VMSSParameters -Deployments $requiredDeployments

        if ($requiredReportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the VMSS"
        }

        if($requiredReportCard.Parameters.vmIdentity.Value -eq "SystemAssigned"){
            # Find the Managed Service Identity PrincipalId and grant it permission to query the secrets.
            $vmssInfoPS = Get-AzVmss -ResourceGroupName $ResourceGroupName -Name $requiredReportCard.Parameters.vmssName
            if (![string]::IsNullOrEmpty($vmInfoPS.Identity.PrincipalId)) {
                Set-AzKeyVaultAccessPolicy -VaultName $VMSSParameters.keyVaultName -PermissionsToSecrets get, list -ObjectId $vmssInfoPS.Identity.PrincipalId
            }
        }

        $requiredReportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
