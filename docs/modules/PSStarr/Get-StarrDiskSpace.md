---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrDiskSpace
---
<!-- markdownlint-disable -->

# Get-StarrDiskSpace

## SYNOPSIS

Retrieves disk-space information from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrDiskSpace [-InstanceName <string>] [-Application <string>]
```

### Explicit

```
Get-StarrDiskSpace -Url <string> -ApiKey <string> [-Application <string>]
```

## DESCRIPTION

This function retrieves disk-space information.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrDiskSpace
```

### EXAMPLE 2

```powershell
Get-StarrDiskSpace -InstanceName 'Main'
```

### EXAMPLE 3

```powershell
'
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with the Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Application

The expected application type.
This filters inferred instances and validates named or explicit targets.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -InstanceName

The optional name of a saved Starr instance.
When omitted, the only matching instance is used.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Name
ParameterSets:
- Name: Named
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Url

The absolute base URL of the Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: true
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

PSStarr.DiskSpace\

This function returns response objects retrieved from the Starr API.

PSStarr.DiskSpace

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrDiskSpace/](https://psstarr.xyz/modules/PSStarr/Get-StarrDiskSpace/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrDiskSpace.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrDiskSpace.ps1)
