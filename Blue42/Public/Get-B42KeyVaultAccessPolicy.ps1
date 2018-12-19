function Get-B42KeyVaultAccessPolicy {
    <#
        .SYNOPSIS
        Creates a hashtable that is suitable to pass to a KeyVault during creation.
        .DESCRIPTION
        The Get-B42KeyVaultAccessPolicy function returns a hashtable that represents all possible permissions to an Azure KeyVault.
        Remove the unwanted permissions before passing it along to a KeyVault template as a parameter.
        .EXAMPLE
        Get-B42KeyVaultAccessPolicy -ObjectID "2dd39430-f77b-4f9e-83dd-61c26e222df1" -TenantID "52154619-1815-4178-a7e7-44a1ac3a5f98"
        .NOTES
        This function is mostly useful for assigning the KeyVault creator instat access.
    #>
    [OutputType('System.Collections.Specialized.OrderedDictionary')]
    [CmdletBinding()]
    param (
        # The ObjectId to add to an access policy.
        [Parameter(Mandatory = $true)]
        [string] $ObjectID,

        # The TenantId to add to an access policy.
        [Parameter(Mandatory = $true)]
        [string] $TenantID
    )

    begin {}

    process {
        [ordered] @{
            objectId    = $ObjectID
            tenantId    = $TenantID
            permissions = @{
                keys         = @("Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore")
                secrets      = @("Get", "List", "Set", "Delete", "Recover", "Backup", "Restore")
                certificates = @("Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers")
            }
        }
    }

    end {}
}
