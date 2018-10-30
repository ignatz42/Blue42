function Get-B42CertificateForms {
    <#
        .SYNOPSIS
        Gets a certificate in various forms for use with Azure
        .DESCRIPTION
        The Get-B42CertificateForms function returns a certificate in various forms for use with Azure.
        .EXAMPLE
        $certificateDetails = Get-B42CertificateForms
        .NOTES
        This should likely be replaces with an LetsEncrypt call?
    #>
    [CmdletBinding()]
    param (
        # Path to an existing PFX certificate
        [Parameter (Mandatory = $false)]
        [string] $CertificatePath = ("{0}.pfx" -f ([guid]::NewGuid()).Guid.Replace('-', '').SubString(0, 8)),

        # Path to an existing PFX certificate
        [Parameter (Mandatory = $false)]
        [securestring] $CertificatePassword = $null,

        # An array of domain names used while creating the certificate
        [Parameter (Mandatory = $false)]
        [array] $DomainNames = @()
    )

    begin {
        if($PSEdition -eq "Core") {
            Write-Host "Calling the import maybe?"
            Import-WinModule PKI -ComputerName "$Env:USERDOMAIN" -NoClobber -Verbose
        }
     }

    process {
        if ($null -eq $CertificatePassword) {
            $password = New-B42Password
            Write-Host $password
            $CertificatePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        }

        $certificate = $null # TODO Is this posh or c#?
        if (!(Test-Path -Path $CertificatePath -PathType Leaf)) {
            # TODO Let's Encrypt
            [System.Security.Cryptography.X509Certificates.X509Certificate2] $certificate = New-SelfSignedCertificate -CertStoreLocation "Cert:\CurrentUser\My" -DnsName $DomainNames
            $null = Export-PfxCertificate -Cert $certificate -FilePath $CertificatePath -Password $CertificatePassword
        } else {
            $certificate = Import-PfxCertificate -CertStoreLocation "Cert:\LocalMachine\My" -FilePath $CertificatePath -Password $CertificatePassword
        }

        @{
            Path           = $CertificatePath
            Password       = $CertificatePassword
            Thumbprint     = $certificate.Thumbprint
            JsonArray      = (ConvertFrom-PFX -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ReturnType "JSON")
            IntegerEncoded = (ConvertFrom-PFX -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ReturnType "INTEGER")
            PkcsSecret     = (ConvertFrom-PFX -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ReturnType "PKCS12")
        }
    }

    end { }
}
