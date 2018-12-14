---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Get-B42CertificateForms

## SYNOPSIS
Gets a certificate in various forms for use with Azure

## SYNTAX

```
Get-B42CertificateForms [[-CertificatePath] <String>] [[-CertificatePassword] <SecureString>]
 [[-DomainNames] <Array>] [<CommonParameters>]
```

## DESCRIPTION
The Get-B42CertificateForms function returns a certificate in various forms for use with Azure.

## EXAMPLES

### EXAMPLE 1
```
$certificateDetails = Get-B42CertificateForms
```

## PARAMETERS

### -CertificatePath
Path to an existing PFX certificate

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ("{0}.pfx" -f ([guid]::NewGuid()).Guid.Replace('-', '').SubString(0, 8))
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificatePassword
Path to an existing PFX certificate

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainNames
An array of domain names used while creating the certificate

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Hashtable
## NOTES
This should likely be replaces with an LetsEncrypt call?

## RELATED LINKS
