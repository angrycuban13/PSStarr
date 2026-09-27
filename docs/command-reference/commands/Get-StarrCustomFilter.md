---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrCustomFilter
---
<!-- markdownlint-disable -->

# Get-StarrCustomFilter

## SYNOPSIS

Retrieves custom filter settings from Radarr or Sonarr.

## SYNTAX

### Named (Default)

```
Get-StarrCustomFilter [-InstanceName <string>] [-Application <string>] [-CustomFilterId <int>]
```

### Explicit

```
Get-StarrCustomFilter -Url <string> -ApiKey <string> [-Application <string>] [-CustomFilterId <int>]
```

## DESCRIPTION

This function retrieves custom-filter settings.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrCustomFilter -InstanceName 'Main'
```

### EXAMPLE 2

```powershell
Get-StarrCustomFilter -InstanceName 'Main' -CustomFilterId 1
```

### EXAMPLE 3

```powershell
Get-StarrCustomFilter -Url 'http://localhost:8989' -ApiKey 'example-api-key'
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with the instance.

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
Specify Prowlarr with explicit credentials to use API v1.

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

### -CustomFilterId

The positive resource identifier for an individual custom filter.

```yaml
Type: System.Int32
DefaultValue: 0
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

The saved instance name.
When omitted, the only configured instance is used.

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

The absolute base URL of the instance.

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

PSStarr.CustomFilter

This function returns deserialized custom filter objects.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrCustomFilter/](https://psstarr.xyz/command-reference/commands/Get-StarrCustomFilter/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrCustomFilter.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrCustomFilter.ps1)
