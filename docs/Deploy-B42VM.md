---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42VM

## SYNOPSIS
Deploys a VM.

## SYNTAX

```
Deploy-B42VM [-ResourceGroupName] <String> [[-Location] <String>] [[-VMParameters] <OrderedDictionary>]
 [[-ScriptExtensions] <OrderedDictionary[]>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42VM function serves as a one touch deploy point for an Azure Virtual Machine

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42VM
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

### -VMParameters
Parameters used for VM creation

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
