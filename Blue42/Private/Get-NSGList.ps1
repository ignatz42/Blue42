function Get-NSGList {
    <#
        .SYNOPSIS
        Gets an NSG for use with same template
        .DESCRIPTION
        The Get-NSGList function gets an os appropriate NSG list.
        .NOTES
        Linux Port 22; Windows 5986;
    #>
    [CmdletBinding()]
    param (
        # If true, the nsg will allow traffic on port 22 else on port 5986
        [Parameter (Mandatory = $false)]
        [switch] $IsLinux
    )

    begin {}

    process {
        $nsg = @()
        if ($IsLinux) {
            $nsg += @{
                name                     = "Inbound-SSH";
                description              = "Allow SSH";
                protocol                 = "Tcp";
                sourcePortRange          = "*";
                destinationPortRange     = "22";
                sourceAddressPrefix      = "*";
                destinationAddressPrefix = "*";
                access                   = "Allow";
                priority                 = 100;
                direction                = "Inbound";
            }
        } else {
            $nsg += @{
                name                     = "Inbound-WinRM-HTTPS";
                description              = "Allow WinRM HTTPS";
                protocol                 = "Tcp";
                sourcePortRange          = "*";
                destinationPortRange     = "5986";
                sourceAddressPrefix      = "*";
                destinationAddressPrefix = "*";
                access                   = "Allow";
                priority                 = 100;
                direction                = "Inbound";
            }
        }
        ,$nsg
    }

    end {}
}
