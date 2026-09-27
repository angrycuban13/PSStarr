---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrIndexer
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrIndexer

## SYNOPSIS

Retrieves every configured Prowlarr indexer or one indexer by ID.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrIndexer [-InstanceName <string>] [-IndexerId <int>]
```

### Explicit

```
Get-StarrProwlarrIndexer -Url <string> -ApiKey <string> [-IndexerId <int>]
```

## DESCRIPTION

This function retrieves configured Prowlarr indexers, regardless of failure state.
Use Get-StarrProwlarrIndexerStatus to retrieve failure states.
Recognizable provider credentials are redacted.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrIndexer -InstanceName ProwlarrMain
```

### EXAMPLE 2

```powershell
' -IndexerId 4
```

## PARAMETERS

### -ApiKey

The API key used to authenticate.

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

### -IndexerId

The positive identifier of one configured indexer.

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

The optional saved Prowlarr instance name.
The matching instance is inferred when omitted.

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

The absolute Prowlarr base URL.

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

PSStarr.Prowlarr.Indexer\

This function returns sanitized Prowlarr indexer resources.

PSStarr.Prowlarr.Indexer

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrIndexer/](https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrIndexer/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexer.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexer.ps1)
