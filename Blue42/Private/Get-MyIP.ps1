function Get-MyIP {
    <#
    .SYNOPSIS
    Find current external IP Address
    .DESCRIPTION
    The Get-MyIP function gets the current external IP as a string
    .NOTES
    Get-MyIP
    #>
    [CmdletBinding()]
    param (
        # Resolve using DNS
        [Parameter (Mandatory = $false)]
        [switch] $UseDNSName,

        # Resolve using a non-secure provider outside of OpenDNS
        [Parameter (Mandatory = $false)]
        [switch] $SkipOpenDNS
    )

    begin {}

    process {
        if ($UseDNSName) {
            (Resolve-DnsName -Name "myip.opendns.com" -Server "resolver1.opendns.com").IPAddress
        } else {
            $url = "https://diagnostic.opendns.com/myip"
            if ($SkipOpenDNS) {
                $url = "http://ifconfig.me/ip"
            }
            (Invoke-WebRequest $url).Content.Trim()
        }
    }

    end {}
}