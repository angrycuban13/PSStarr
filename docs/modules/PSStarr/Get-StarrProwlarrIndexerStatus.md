---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrIndexerStatus
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrIndexerStatus

## SYNOPSIS

Retrieves Prowlarr indexer failure and backoff records.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrIndexerStatus [-InstanceName <string>]
```

### Explicit

```
Get-StarrProwlarrIndexerStatus -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves Prowlarr indexer failures and temporary disablements.
Use Get-StarrProwlarrIndexer to retrieve all configured indexers.
An empty result normally means that Prowlarr has no recorded indexer failures or disablements.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrIndexerStatus -InstanceName Main
```

### EXAMPLE 2

```powershell
'
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

PSStarr.Prowlarr.IndexerStatus\

This function returns indexer failure and backoff records.

PSStarr.Prowlarr.IndexerStatus

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrIndexerStatus/](https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrIndexerStatus/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerStatus.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerStatus.ps1)
