---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrIndexerCategory
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrIndexerCategory

## SYNOPSIS

Retrieves categories exposed by configured Prowlarr indexers.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrIndexerCategory [-InstanceName <string>]
```

### Explicit

```
Get-StarrProwlarrIndexerCategory -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves the category hierarchy from configured Prowlarr indexers.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrIndexerCategory -InstanceName Main
```

### EXAMPLE 2

```powershell
Get-StarrProwlarrIndexerCategory -Url 'http://localhost:9696' -ApiKey 'example-api-key'
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

PSStarr.Prowlarr.IndexerCategory

This function returns deserialized Prowlarr IndexerCategory resources.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerCategory/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrIndexerCategory/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerCategory.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrIndexerCategory.ps1)
