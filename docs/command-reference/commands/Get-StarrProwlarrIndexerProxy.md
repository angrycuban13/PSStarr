---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrIndexerProxy
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrIndexerProxy

## SYNOPSIS

Retrieves Prowlarr IndexerProxy resources.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrIndexerProxy [-InstanceName <string>] [-IndexerProxyId <int>]
```

### Explicit

```
Get-StarrProwlarrIndexerProxy -Url <string> -ApiKey <string> [-IndexerProxyId <int>]
```

## DESCRIPTION

This function retrieves Prowlarr indexer proxies.
It redacts provider secrets.
Do not use returned objects for updates.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrIndexerProxy -InstanceName Main
```

### EXAMPLE 2

```powershell
Get-StarrProwlarrIndexerProxy -InstanceName Main -IndexerProxyId 1
```

### EXAMPLE 3

```powershell
Get-StarrProwlarrIndexerProxy -Url 'http://localhost:9696' -ApiKey 'example-api-key'
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

### -IndexerProxyId

The positive resource identifier for an individual lookup.

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

PSStarr.Prowlarr.IndexerProxy

This function returns deserialized Prowlarr IndexerProxy resources with provider secrets redacted.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerProxy/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerProxy/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerProxy.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerProxy.ps1)
