function New-B42Password {
    <#
        .SYNOPSIS
        Generates a reasonable secure password.
        .DESCRIPTION
        The New-B42Password function creates a GUID, splits it by the hyphen charater, then randomly capitalizes the blocks and reassemables them with random special character seperators.
        .EXAMPLE
        New-B42Password
        .NOTES
        The function verifies the output before returning.
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param ()

    begin {}

    process {
        $newPassword = ""
        do {
            Write-Verbose "B42 - Generating new password."
            $specialChars = "!@#$%^&*-+=`|\(){}[]:;`"'<>,.?/"
            foreach ($part in ([guid]::NewGuid()).Guid.Split('-')) {
                $rand = Get-Random -Minimum 0 -Maximum ($specialChars.Length - 1)
                if ($rand % 2 -eq 0) {
                    $newPassword += $part.ToUpper()
                } else {
                    $newPassword += $part.ToLower()
                }
                $newPassword += $specialChars[$rand]
                $specialChars = $specialChars.Remove($rand, 1)
            }
        } while (!(($newPassword -match "\W") -and ($newPassword -match "\d") -and ($newPassword -match "[A-Z]") -and ($newPassword -match "[a-z]")))
        $newPassword
    }

    end {}
}
