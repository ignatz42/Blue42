---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42VNet

## SYNOPSIS
Deploys a VNet.

## SYNTAX

```
Deploy-B42VNet [-ResourceGroupName] <String> [[-Location] <String>] [[-VNetParameters] <OrderedDictionary>]
 [-IncludeDDos] [[-PrivateDNSZone] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42VNet function serves as a one touch deploy point for an Azure Virtual Network

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42VNet
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

### -VNetParameters
Parameters used for VNet creation

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

### -IncludeDDos
Include a Distributed Denial of Service plan

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

### -PrivateDNSZone
If supplied, a private DNS Zone will be created using the parameter's value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Run this function after establishing an Az context using Connect-AzAccount

## RELATED LINKS
