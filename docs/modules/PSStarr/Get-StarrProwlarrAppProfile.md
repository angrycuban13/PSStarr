---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrAppProfile
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrAppProfile

## SYNOPSIS

Retrieves Prowlarr application profiles.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrAppProfile [-InstanceName <string>] [-AppProfileId <int>]
```

### Explicit

```
Get-StarrProwlarrAppProfile -Url <string> -ApiKey <string> [-AppProfileId <int>]
```

## DESCRIPTION

This function retrieves Prowlarr profiles that control indexer synchronization with connected applications.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrAppProfile -InstanceName Main
```

### EXAMPLE 2

```powershell
Get-StarrProwlarrAppProfile -InstanceName Main -AppProfileId 1
```

### EXAMPLE 3

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

### -AppProfileId

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

PSStarr.Prowlarr.ApplicationProfile\

This function returns deserialized Prowlarr AppProfile resources.

PSStarr.Prowlarr.ApplicationProfile

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrAppProfile/](https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrAppProfile/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrAppProfile.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrAppProfile.ps1)
