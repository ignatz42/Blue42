---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Deploy-B42SQL

## SYNOPSIS
Deploys a SQL instance.

## SYNTAX

```
Deploy-B42SQL [-ResourceGroupName] <String> [[-Location] <String>] [[-SQLParameters] <OrderedDictionary>]
 [[-DBs] <OrderedDictionary[]>] [[-AADDisplayName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Deploy-B42SQL function serves as a one touch deploy point for an Azure SQL Instance

## EXAMPLES

### EXAMPLE 1
```
Deploy-B42SQL
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

### -SQLParameters
Parameters used for SQL creation

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

### -DBs
An array of database parameters blocks; one per desired database.

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

### -AADDisplayName
Display Name of the Azure Active Directory User or Group that will become the SQL Server Administrator

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
