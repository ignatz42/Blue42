---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42AppService

## SYNOPSIS
Deploys an App Service, either a Plan or an Environment optionally

## SYNTAX

```
Deploy-B42AppService [-ResourceGroupName] <String> [[-Location] <String>]
 [[-AppServicePlanParameters] <OrderedDictionary>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42AppService function serves as a one touch deploy point for an Azure App Service.
Both plan and environment supported.

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42AppService
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

### -AppServicePlanParameters
Parameters used for App Service creation

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Run this function after establishing an Az context using Connect-AzAccount

## RELATED LINKS
