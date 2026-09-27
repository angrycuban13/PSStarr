---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrIndexerProxySchema
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrIndexerProxySchema

## SYNOPSIS

Retrieves Prowlarr IndexerProxySchema resources.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrIndexerProxySchema [-InstanceName <string>]
```

### Explicit

```
Get-StarrProwlarrIndexerProxySchema -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves schemas for Prowlarr indexer proxies.
It redacts provider secrets.
Do not use returned objects for updates.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrIndexerProxySchema -InstanceName Main
```

### EXAMPLE 2

```powershell
Get-StarrProwlarrIndexerProxySchema -Url 'http://localhost:9696' -ApiKey 'example-api-key'
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

PSStarr.Prowlarr.ProviderSchema

This function returns deserialized Prowlarr IndexerProxySchema resources with provider secrets redacted.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerProxySchema/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerProxySchema/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerProxySchema.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerProxySchema.ps1)
