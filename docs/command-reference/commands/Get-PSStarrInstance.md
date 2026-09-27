---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-PSStarrInstance
---
<!-- markdownlint-disable -->

# Get-PSStarrInstance

## SYNOPSIS

Retrieves saved PSStarr instances without exposing API keys.

## SYNTAX

### All

```
Get-PSStarrInstance [[-Name] <string>]
```

## DESCRIPTION

This function retrieves saved Starr instances and their encryption modes.
It does not expose API keys.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PSStarrInstance
```

### EXAMPLE 2

```powershell
Get-PSStarrInstance -Name 'RadarrMain'
```

## PARAMETERS

### -Name

The name of the saved Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None.

You cannot pipe objects to this function.

## OUTPUTS

PSStarr.Instance

This function returns redacted saved-instance configuration objects.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-PSStarrInstance/](https://psstarr.xyz/command-reference/commands/Get-PSStarrInstance/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-PSStarrInstance.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-PSStarrInstance.ps1)
