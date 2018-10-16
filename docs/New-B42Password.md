---
external help file: Blue42-help.xml
Module Name: Blue42
online version:
schema: 2.0.0
---

# New-B42Password

## SYNOPSIS
Generates a reasonable secure password.

## SYNTAX

```
New-B42Password [<CommonParameters>]
```

## DESCRIPTION
The New-B42Password function creates a GUID, splits it by the hyphen charater, then randomly capitalizes the blocks and reassemables them with random special character seperators.

## EXAMPLES

### EXAMPLE 1
```
New-B42Password
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES
The function verifies the output before returning.

## RELATED LINKS
