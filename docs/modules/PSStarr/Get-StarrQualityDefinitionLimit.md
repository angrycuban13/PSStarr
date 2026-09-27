---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrQualityDefinitionLimit
---
<!-- markdownlint-disable -->

# Get-StarrQualityDefinitionLimit

## SYNOPSIS

Retrieves quality definition limits from Radarr or Sonarr.

## SYNTAX

### Named (Default)

```
Get-StarrQualityDefinitionLimit [-InstanceName <string>] [-Application <string>]
```

### Explicit

```
Get-StarrQualityDefinitionLimit -Url <string> -ApiKey <string> [-Application <string>]
```

## DESCRIPTION

This function retrieves quality-definition limits.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrQualityDefinitionLimit -InstanceName 'Main'
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

### -Application

The expected application type.
This filters inferred instances and validates named or explicit targets.

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

The saved instance name.
When omitted, the only configured instance is used.

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

PSStarr.QualityDefinitionLimit\

This function returns deserialized quality definition limits.

PSStarr.QualityDefinitionLimit

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrQualityDefinitionLimit/](https://psstarr.xyz/modules/PSStarr/Get-StarrQualityDefinitionLimit/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrQualityDefinitionLimit.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrQualityDefinitionLimit.ps1)
