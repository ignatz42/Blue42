---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Find-B42Template

## SYNOPSIS
Retrieves a list of templates (files with json extension) in the path.

## SYNTAX

```
Find-B42Template [[-TemplatePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Find-B42Template function lists the json file names in the given directory.
Use Get-B42Globals to view the default directory.

## EXAMPLES

### EXAMPLE 1
```
Find-B42Template
```

## PARAMETERS

### -TemplatePath
The template search path.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function is mostly useful for listing templates in the default directory.

## RELATED LINKS
