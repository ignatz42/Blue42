---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# Test-B42Deployment

## SYNOPSIS
Test the Resource Group Deployments

## SYNTAX

```
Test-B42Deployment [-ResourceGroupName] <String> [-Templates] <Array> [[-TemplatePath] <String>]
 [[-TemplateParameters] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
The Test-B42Deployment function tests a group of resource deployment and attempts to return a go/no-go value
First it verifies that each deployment is successful, then it compares the expected parameter values for each
deployment match expected.

## EXAMPLES

### EXAMPLE 1
```
Test-B42Deployment -Templates @("Vnet", "Subnet")
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

### -Templates
An array of template names that will be combined into a single template then deployed to Azure

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
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
Position: 4
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### B42DeploymentReport

## NOTES
The custom class B42DeploymentReport has additonal details.

## RELATED LINKS
