function Add-Secret {
    <#
        .SYNOPSIS
        Adds a secret to a keyvault
        .DESCRIPTION
        The Add-Secret function adds a secret to a key vault.
        .NOTES
        Converts string to securestring before storing in the vault
    #>
    [CmdletBinding()]
    param (
        # The name of a the destination key vault
        [Parameter (Mandatory = $true)]
        [string] $KeyVaultName,

        # The secret name
        [Parameter (Mandatory = $true)]
        [string] $SecretName,

        # The secret value
        [Parameter (Mandatory = $true)]
        [object] $SecretValue
    )

    begin {}

    process {
        if ($SecretValue.GetType().Name -ne "SecureString") {
            $SecretValue = (ConvertTo-SecureString -AsPlainText -Force -String $SecretValue)
        }
        Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecretValue
    }

    end {}
}
