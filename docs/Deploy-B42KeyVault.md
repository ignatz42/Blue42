---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42KeyVault

## SYNOPSIS
Deploys a KeyVault.

## SYNTAX

```
Deploy-B42KeyVault [-ResourceGroupName] <String> [[-Location] <String>]
 [[-KeyVaultParameters] <OrderedDictionary>] [-IncludeCurrentUserAccess] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42KeyVault function serves as a one touch deploy point for an Azure Application Service Environment

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42KeyVault
```

## PARAMETERS

### -ResourceGroupName
The destination Resource Group Name

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

### -Location
The destination Azure region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyVaultParameters
Parameters used for KeyVault creation

```yaml
Type: OrderedDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: [ordered]@{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeCurrentUserAccess
{{Fill IncludeCurrentUserAccess Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Run this function after establishing an Az context using Connect-AzAccount.

## RELATED LINKS
