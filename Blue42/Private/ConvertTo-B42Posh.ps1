function ConvertTo-B42Posh {
    <#
        .SYNOPSIS
        Convert Json to PowerShell objects.
        .DESCRIPTION
        The ConvertTo-B42Posh function converts Json into PowerShell lists and ordered hashtables.
        .NOTES
        The native ConvertFrom-Json implementation of -AsHashTables does not use ordered hashtables which breaks tests.
    #>
    [CmdletBinding()]
    param (
        # Input object in Json format
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    begin {
        Write-Verbose "Starting ConvertTo-B42Posh"
    }

    process {
        $resultObject = $null
        if ( $InputObject -is [System.Management.Automation.PSCustomObject] ) {
            $resultObject = [ordered]@{}
            foreach ($property in $InputObject.psobject.properties) {
                $resultObject[$property.Name] = ConvertTo-B42Posh -InputObject $property.Value
            }
        } elseif ($InputObject -is [System.Object[]]) {
            $list = @()
            foreach ($item in $InputObject) {
                $list += (ConvertTo-B42Posh -InputObject $item)
            }
            # The , is used here to workaround Powershell's tendancy to convert an array of 1 into that single element.
            $resultObject = ,$list
        } else {
            $resultObject = $InputObject
        }
        $resultObject
    }

    end {
        Write-Verbose "Ending ConvertTo-B42Posh"
    }
}
