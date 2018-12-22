---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Set-B42Globals

## SYNOPSIS
Sets the default values for Location, TemplatePath, and a Unique Identifer.

## SYNTAX

```
Set-B42Globals [[-UID] <String>] [[-Location] <String>] [[-TemplatePath] <String>] [[-Date] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-B42Globals function sets some helper values with a Module Global scope.

## EXAMPLES

### EXAMPLE 1
```
Set-B42Globals -UID "uniqueString" -Location "azureLocation" -TemplatePath "pathToCustomTemplates"
```

## PARAMETERS

### -UID
The default unique identifer used in name generation

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location
The default destination Azure region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: East US
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplatePath
The default search path for templates

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Resolve-Path "$PSScriptRoot\..\Templates").ToString()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
The date

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
The unique identifer is used to relate default resource names.

## RELATED LINKS
