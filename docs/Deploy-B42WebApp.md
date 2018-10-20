---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42WebApp

## SYNOPSIS
Deploys a Web App.

## SYNTAX

```
Deploy-B42WebApp [-ResourceGroupName] <String> [[-Location] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42WebApp function serves as a one touch deploy point for an Azure Web Application

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42WebApp
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
You need to run this function after establishing an AzureRm context using Login-AzureRmAccount

## RELATED LINKS
