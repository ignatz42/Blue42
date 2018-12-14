---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42WebApp

## SYNOPSIS
Deploys an Web App with additional common support option and optional SQL database.

## SYNTAX

```
Deploy-B42WebApp [-ResourceGroupName] <String> [[-Location] <String>] [[-WebAppParameters] <OrderedDictionary>]
 [[-SQLParameters] <OrderedDictionary>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42WebApp function serves as a one touch deploy point for an Azure Web App.

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

### -WebAppParameters
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

### -SQLParameters
If $null, no database will be created.
If an empty \[ordered\] list is supplied, a new SQL Local instance and database will be created.
If the \[ordered\] list contains, sqlServerName, sqlAdminUser, sqlAdminPass a new database will be deployed to the specified local instance.

```yaml
Type: OrderedDictionary
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
