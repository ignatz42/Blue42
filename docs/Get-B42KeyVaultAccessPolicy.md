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
Get-B42KeyVaultAccessPolicy [-ObjectID] <String> [-TenantID] <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-B42KeyVaultAccessPolicy function returns a hashtable that represents all possible permissions to an Azure KeyVault.
Remove the unwanted permissions before passing it along to a KeyVault template as a parameter.

## EXAMPLES

### EXAMPLE 1
```
Get-B42KeyVaultAccessPolicy -ObjectID "2dd39430-f77b-4f9e-83dd-61c26e222df1" -TenantID "52154619-1815-4178-a7e7-44a1ac3a5f98"
```

## PARAMETERS

### -ObjectID
The ObjectId to add to an access policy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantID
The TenantId to add to an access policy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Specialized.OrderedDictionary
## NOTES
This function is mostly useful for assigning the KeyVault creator instat access.

## RELATED LINKS
