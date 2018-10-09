---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Get-B42Template

## SYNOPSIS
Retrieves an ARM template in native PowerShell objects.

## SYNTAX

```
Get-B42Template [-Templates] <Array> [[-TemplatePath] <String>] [-AsJson] [-SkipTokenReplacement]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-B42Template function creates a new template by combining the supplied atomic templates and returns it in Hashtable/array format.

## EXAMPLES

### EXAMPLE 1
```
Get-B42Template -Templates @("Vnet", "Subnet")
```

## PARAMETERS

### -Templates
An array of template names that will be combined into a single template then deployed to Azure

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplatePath
This parameter overrides the default search path.
See Set/Get-B42Globals for the default path

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

### -AsJson
Return object in JSON format

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

### -SkipTokenReplacement
Skip token replacement.

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
This function is mostly useful for creating templates by stacking the atomic elements.

## RELATED LINKS
