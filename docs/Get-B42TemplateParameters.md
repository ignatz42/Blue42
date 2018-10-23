---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Get-B42TemplateParameters

## SYNOPSIS
Retrieves a hashtable of template parameters suitable for deployment.

## SYNTAX

```
Get-B42TemplateParameters [-Templates] <Array> [[-TemplatePath] <String>] [[-TemplateParameters] <Hashtable>]
 [-AsJson] [-SkipTokenReplacement] [<CommonParameters>]
```

## DESCRIPTION
The Get-B42TemplateParameters function returns a hashtable of template parameters suitable for deployment.
The template's default values are used as a starting place.
Special tokens are replaced.

## EXAMPLES

### EXAMPLE 1
```
Get-B42TemplateParameters -Templates @("Vnet", "Subnet")
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

### -TemplateParameters
A list of override parameters.
If empty, the default parameters supplied in the template will be used instead

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @{}
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

### System.Collections.Specialized.OrderedDictionary
## NOTES
This function does a token replacement on \[PASSWORD\] and \[UID\] contained in the template's default value field.

## RELATED LINKS
