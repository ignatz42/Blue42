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
Deploy-B42VMSS [-ResourceGroupName] <String> [[-Location] <String>] [-ImageOsDiskBlobUri] <String>
 [[-VMSSParameters] <OrderedDictionary>] [-IsLinux] [<CommonParameters>]
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

### -ImageOsDiskBlobUri
The URI of the Blob where a disk image is store

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMSSParameters
Parameters used for VM creation

```yaml
Type: OrderedDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: [ordered]@{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsLinux
If true, the vm will use linux specific configuraiton settings.
If false, the vm will use windows specific configuration settings.

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
You need to run this function after establishing an AzureRm context using Login-AzureRmAccount

## RELATED LINKS
