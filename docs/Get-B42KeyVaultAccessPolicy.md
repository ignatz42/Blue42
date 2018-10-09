---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Get-B42KeyVaultAccessPolicy

## SYNOPSIS
Creates a hashtable that is suitable to pass to a KeyVault during creation.

## SYNTAX

```
Get-B42KeyVaultAccessPolicy [[-UserPrincipalName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-B42KeyVaultAccessPolicy function returns a hashtable that represents all possible permissions to an Azure KeyVault.
Remove the unwanted permissions before passing it along to a KeyVault template as a parameter.

## EXAMPLES

### EXAMPLE 1
```
Get-B42KeyVaultAccessPolicy -UserPrincipalName user@domain.com
```

## PARAMETERS

### -UserPrincipalName
The user principal name to add to an access policy. 
If none is supplied, the current user will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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
This function is mostly useful for assigning the KeyVault creator instat access.

## RELATED LINKS
