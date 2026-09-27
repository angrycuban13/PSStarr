---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrAppProfileSchema
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrAppProfileSchema

## SYNOPSIS

Retrieves the Prowlarr application-profile schema.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrAppProfileSchema [-InstanceName <string>]
```

### Explicit

```
Get-StarrProwlarrAppProfileSchema -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves the schema for Prowlarr application profiles.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrAppProfileSchema -InstanceName Main
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

This function returns deserialized Prowlarr AppProfileSchema resources.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrAppProfileSchema/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrAppProfileSchema/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrAppProfileSchema.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrAppProfileSchema.ps1)
