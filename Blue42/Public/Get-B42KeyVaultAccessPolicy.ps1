function Get-B42KeyVaultAccessPolicy {
    <#
        .SYNOPSIS
        Creates a hashtable that is suitable to pass to a KeyVault during creation.
        .DESCRIPTION
        The Get-B42KeyVaultAccessPolicy function returns a hashtable that represents all possible permissions to an Azure KeyVault.
        Remove the unwanted permissions before passing it along to a KeyVault template as a parameter.
        .NOTES
        This function is mostly useful for assigning the KeyVault creator instat access.
    #>
    [OutputType('System.Collections.Hashtable')]
    [CmdletBinding()]
    param (
        # The user principal name to add to an access policy.  If none is supplied, the current user will be used.
        [Parameter(Mandatory = $false)]
        [string] $UserPrincipalName
    )

    begin {
        $currentContext = Get-AzureRmContext
        if ($null -eq $currentContext) {
            throw "Must establish an Azure Context to the tenant where the User Principal lives"
        }
        $TenantID = $currentContext.Tenant.Id
        if ([string]::IsNullOrEmpty($UserPrincipalName)) {
            $UserPrincipalName = $currentContext.Account.Id
        }
        $ObjectID = (Get-AzureRmADUser -UserPrincipalName $UserPrincipalName).Id.ToString()
        if ([string]::IsNullOrEmpty($ObjectID)) {
            throw ("User Principal {0} not found in Tenant {1}" -f $UserPrincipalName, $TenantID)
        }
    }

    process {
        @{
            objectId    = $ObjectID
            tenantId    = $TenantID
            permissions = @{
                keys         = @("Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore")
                secrets      = @("Get", "List", "Set", "Delete", "Recover", "Backup", "Restore")
                certificates = @("Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers")
            }
        }
    }

    end {
    }
}
