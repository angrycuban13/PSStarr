---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrSearch
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrSearch

## SYNOPSIS

Retrieves Prowlarr search results.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrSearch [-InstanceName <string>] [-Term <string>] [-Type <string>]
 [-IndexerIdFilter <int[]>] [-CategoryIdFilter <int[]>] [-Limit <int>] [-Offset <int>]
```

### Explicit

```
Get-StarrProwlarrSearch -Url <string> -ApiKey <string> [-Term <string>] [-Type <string>]
 [-IndexerIdFilter <int[]>] [-CategoryIdFilter <int[]>] [-Limit <int>] [-Offset <int>]
```

## DESCRIPTION

This function searches Prowlarr indexers without downloading releases.
A search can consume quotas, record history, and populate server caches.
If Term is absent, the function requests recent releases for the selected search type and indexers.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrSearch -InstanceName 'Main' -Term 'Example' -IndexerIdFilter 1,2
```

### EXAMPLE 2

```powershell
'
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with Prowlarr.

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

### -CategoryIdFilter

The Newznab category identifiers to include.

```yaml
Type: System.Int32[]
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

### -IndexerIdFilter

The indexer identifiers to search.

```yaml
Type: System.Int32[]
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

The saved Prowlarr instance name.
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

### -Limit

The requested maximum results; individual indexers may impose their own limits.

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

### -Offset

The zero-based result offset.

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

### -Term

The search text; omit to request recent releases.

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

### -Type

The indexer search type.
Omit to use the server default of search.

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

The absolute base URL of the Prowlarr instance.

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

PSStarr.Prowlarr.SearchResult\

This function returns deserialized Prowlarr response objects.

PSStarr.Prowlarr.SearchResult

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrSearch/](https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrSearch/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrSearch.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrSearch.ps1)
