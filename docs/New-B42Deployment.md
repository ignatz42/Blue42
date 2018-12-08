---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# New-B42Deployment

## SYNOPSIS
Retrieves service pack and operating system information from one or more remote computers.

## SYNTAX

```
New-B42Deployment [-ResourceGroupName] <String> [[-Location] <String>] [-Templates] <Array>
 [[-TemplatePath] <String>] [[-TemplateParameters] <Hashtable>] [-Complete] [<CommonParameters>]
```

## DESCRIPTION
The New-B42Deployment function uses the Az module to perform a New-AzResourceGroupDeployment using the supplied
template and a (partial) parameter set.
If no parameter set is supplied, the templates default parameters will be used.

## EXAMPLES

### EXAMPLE 1
```
New-B42Deployment -Templates @("Vnet", "Subnet")
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

### -Templates
An array of template names that will be combined into a single template then deployed to Azure

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateParameters
A list of override parameters.
If empty, the default parameters supplied in the template will be used insted

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -Complete
Perform a 'Complete' deployment instead of the default 'Incremental'

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
Run this function after establishing an Az context using Connect-AzAccount

## RELATED LINKS
