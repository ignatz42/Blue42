function Deploy-B42VM {
    <#
        .SYNOPSIS
        Deploys a VM.
        .DESCRIPTION
        The Deploy-B42VM function serves as a one touch deploy point for an Azure Virtual Machine
        .EXAMPLE
        Deploy-B42VM
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
        # The parameters in VirtualNetworkParameters are required. If not provided, create some defaults.
        if (!($VMParameters.Contains("vnetResourceGroupName") -and $VMParameters.Contains("vnetName") -and $VMParameters.Contains("subnetName"))) {
            $vnetReportCard = Deploy-B42VNet -ResourceGroupName $ResourceGroupName -Location "$Location" -VNetParameters $VMParameters
            # Carry along these values to the VMDeployment.
            $VMParameters.Add("vnetResourceGroupName", $ResourceGroupName)
            $VMParameters.Add("vnetName", $vnetReportCard.Parameters.vnetName)
            $VMParameters.Add("subnetName", $vnetReportCard.Parameters.subnetName)
        }

        # A KeyVault is required, if one wasn't supplied create it then add the admin user and password.
        if (!($VMParameters.Contains("keyVaultResourceGroupName") -and $VMParameters.Contains("keyVaultName"))) {
            $keyVaultReportCard = Deploy-B42KeyVault -ResourceGroupName $ResourceGroupName -Location "$Location" -IncludeCurrentUserAccess -KeyVaultParameters ([ordered]@{keyVaultEnabledForDeployment = $true; keyVaultEnabledForTemplateDeployment = $true})
            # These values are required
            $VMParameters.Add("keyVaultResourceGroupName", $ResourceGroupName)
            $VMParameters.Add("keyVaultName", $keyVaultReportCard.Parameters.keyVaultName)
        }
        # Should the VM just reference the password in the keyVault?
        $userSecret = Add-Secret -KeyVaultName $VMParameters.keyVaultName -SecretName "AdminUsername" -SecretValue "azdam"
        $passSecret = Add-Secret -KeyVaultName $VMParameters.keyVaultName -SecretName "AdminPassword" -SecretValue (New-B42Password)
        $VMParameters.Add("vmAdminUsername", $userSecret.SecretValueText)
        $VMParameters.Add("vmAdminPassword", $passSecret.SecretValueText)

        # Deploy VM Specific pre-reqs.
        $prereqTemplates = @()
        if ($IncludePublicInterface) {
            $prereqTemplates += "PublicIP"
            $VMParameters.Add("nsgSecurityRules", (Get-NSGList -IsLinux:$IsLinux))
            $prereqTemplates += "NSG"
        }
        $prereqTemplates += "NetworkInterface"
        $prereqDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $prereqTemplates -TemplateParameters $VMParameters
        $prereqReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $prereqTemplates -TemplateParameters $VMParameters -Deployments $prereqDeployments

        if ($prereqReportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy Pre-Reqs"
        }
        $VMParameters.Add("networkInterfaceName", $prereqReportCard.Parameters.networkInterfaceName)

        # TODO: More tokens for resourceid
        if ($VMParameters.Contains("imageName")) {
            $VMParameters.Add("vmImagePublisher", "")
            $VMParameters.Add("vmImageOffer", "")
            $VMParameters.Add("vmImageSKU", "")
        }

        # Deploy the actual VM
        $requiredTemplates = @()
        if ($IsLinux) {
            $requiredTemplates += "LinVM"
            # TODO generate the SSH bits here.
        } else {
            $requiredTemplates += "WinVM"

            # Create a self-signed cert for use with WinRM over HTTPS
            $certPath = ("{0}\Blue42VM.pfx" -f (Convert-Path -Path ".\"))
            $certForms = Get-B42CertificateForms -CertificatePath $certPath -DomainNames @("testing.local")
            # TODO Why is this still here?  Should the helper delete it?
            $null = Remove-Item $certPath

            $null = Add-Secret -KeyVaultName $VMParameters.keyVaultName -SecretName "CertPassword" -SecretValue $certForms.Password
            $certSecret = Add-Secret -KeyVaultName $VMParameters.keyVaultName -SecretName "Cert" -SecretValue $certForms.JsonArray
            $VMParameters.Add("vmCertificateSecretUrl", $certSecret.Id)
        }
        $requiredDeployments = New-B42Deployment -ResourceGroupName $ResourceGroupName -Location "$Location" -Templates $requiredTemplates -TemplateParameters $VMParameters
        $requiredReportCard = Test-B42Deployment -ResourceGroupName $ResourceGroupName -Templates $requiredTemplates -TemplateParameters $VMParameters -Deployments $requiredDeployments

        if ($requiredReportCard.SimpleReport() -ne $true) {
            throw "Failed to deploy the VM"
        }

        if($requiredReportCard.Parameters.vmIdentity -eq "SystemAssigned"){
            # Find the Managed Service Identity PrincipalId and grant it permission to query the secrets.
            $vmInfoPS = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $requiredReportCard.Parameters.vmName
            if (![string]::IsNullOrEmpty($vmInfoPS.Identity.PrincipalId)) {
                Set-AzKeyVaultAccessPolicy -VaultName $VMParameters.keyVaultName -PermissionsToSecrets get, list -ObjectId $vmInfoPS.Identity.PrincipalId
            }
        }
        # This report card only contains the results of the VM deployment.
        $requiredReportCard
    }

    end {
        Write-Verbose ("{0} ended at {1} " -f $MyInvocation.MyCommand, (Get-Date).ToString())
    }
}
