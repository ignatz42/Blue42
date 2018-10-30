function ConvertFrom-PFX {
    <#
        .SYNOPSIS
        Converts a PFX certificate into one of the forms useful with Azure
        .DESCRIPTION
        The ConvertFrom-PFX function returns a bin64 encode string for use with Azure.
        .NOTES
        The possible return types have these uses
        PKCS12  - A container for the PFX with its' password. For use when the certificate must be fetchable from a keyvault
        JSON    - A JSON object container for the PFX and its' password. For use with Azure VMs
        INTEGER - A representation of only the certificate. For use with ASE and Web Apps
    #>
    [CmdletBinding()]
    param (
        # The path to the certificate.
        [Parameter (Mandatory = $true)]
        [string] $CertificatePath,

        # The password for the certificate.
        [Parameter (Mandatory = $true)]
        [securestring] $CertificatePassword,

        # The PFX file will be converted into one of these types: PKCS12, JSON, INTEGER
        [Parameter (Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("PKCS12", "JSON", "INTEGER")]
        [string] $ReturnType
    )

    begin {
    }

    process {
        # Decode the password for as little time as possible.
        $credentials = New-Object System.Net.NetworkCredential("UnusedUser", $CertificatePassword, "UnusedDomain")
        $returnBytes = $null
        if ($ReturnType -eq "PKSC12") {
            # PKSC12
            $collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            $collection.Import($CertificatePath, $credentials.Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
            $pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12

            $returnBytes = $collection.Export($pkcs12ContentType)
        } else {
            # The parameter set change between 5.1 and 6.1
            $params = @{Encoding = "Byte"}
            if($PSEdition -eq "Core") {
                $params = @{AsByteStream = $true}
            }
            $fileContentBytes = Get-Content $CertificatePath @params
            $fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
            # INTEGER
            if ($ReturnType -eq "INTEGER") {return $fileContentEncoded}
            # JSON
            $jsonObject = ConvertTo-Json -InputObject @{
                data     = "$fileContentEncoded";
                dataType = "pfx";
                password = "$credentials.Password";
            }

            $returnBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
        }

        [System.Convert]::ToBase64String($returnBytes)
    }

    end {
    }
}
