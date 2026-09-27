---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrLogEntry
---
<!-- markdownlint-disable -->

# Get-StarrLogEntry

## SYNOPSIS

Retrieves application log records from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrLogEntry [-InstanceName <string>] [-Application <string>] [-Page <int>] [-PageSize <int>]
 [-SortKey <string>] [-SortDirection <string>] [-Level <string>]
```

### Explicit

```
Get-StarrLogEntry -Url <string> -ApiKey <string> [-Application <string>] [-Page <int>]
 [-PageSize <int>] [-SortKey <string>] [-SortDirection <string>] [-Level <string>]
```

## DESCRIPTION

This function retrieves one page of application log records and its paging metadata.
Logs can contain sensitive operational data.
The function redacts the current API key but may not identify other secrets.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrLogEntry
```

### EXAMPLE 2

```powershell
Get-StarrLogEntry -InstanceName 'Main'
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

### -Level

Filters results by the server log level.

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

### -Page

The one-based result page.

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

### -PageSize

The maximum number of records returned per page.

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

### -SortDirection

The result sort direction.

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

### -SortKey

The field used to sort results.

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

PSStarr.PagedResult\

This function returns response objects retrieved from the Starr API.

PSStarr.PagedResult

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrLogEntry/](https://psstarr.xyz/modules/PSStarr/Get-StarrLogEntry/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrLogEntry.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrLogEntry.ps1)
