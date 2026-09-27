---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrApplicationSchema
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrApplicationSchema

## SYNOPSIS

Retrieves supported Prowlarr application-integration definitions.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrApplicationSchema [-InstanceName <string>]
```

### Explicit

```
Get-StarrProwlarrApplicationSchema -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves definitions for Prowlarr application providers.
It redacts provider secrets.
Do not use returned objects for updates.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrApplicationSchema -InstanceName Main
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

PSStarr.Prowlarr.ProviderSchema

This function returns deserialized Prowlarr ApplicationSchema resources with provider secrets redacted.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrApplicationSchema/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrApplicationSchema/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrApplicationSchema.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrApplicationSchema.ps1)
