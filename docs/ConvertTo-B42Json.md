---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# ConvertTo-B42Json

## SYNOPSIS
Just enough JSON beauty for human readable output

## SYNTAX

```
ConvertTo-B42Json [-InputObject] <OrderedDictionary> [<CommonParameters>]
```

## DESCRIPTION
The ConvertTo-B42Json function formats json for use as an Arm template.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-B42Json -InputObject (ConvertTo-Json -InputObject $object)
```

### EXAMPLE 2
```
$object | ConvertTo-Json | ConvertTo-B42Json
```

## PARAMETERS

### -InputObject
Powershell object in ordered dictionary collection

```yaml
Type: OrderedDictionary
Parameter Sets: (All)
Aliases:

Required: True
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

### System.String
## NOTES
This function removes extra unicode formatting leftove from ConvertTo-Json

## RELATED LINKS
