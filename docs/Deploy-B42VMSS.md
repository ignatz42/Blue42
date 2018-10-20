---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42VMSS

## SYNOPSIS
Deploys a VMSS.

## SYNTAX

```
Deploy-B42VMSS [-ResourceGroupName] <String> [[-Location] <String>] [[-VMSSParameters] <OrderedDictionary>]
 [[-ScriptExtensions] <OrderedDictionary[]>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42VMSS function serves as a one touch deploy point for an Azure Virtual Machine Scale Set

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42VMSS
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

### -VMSSParameters
Parameters used for VMSS creation

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

### -ScriptExtensions
An array of script extensions parameters blocks; one per desired extension.

```yaml
Type: OrderedDictionary[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
You need to run this function after establishing an AzureRm context using Login-AzureRmAccount

## RELATED LINKS
