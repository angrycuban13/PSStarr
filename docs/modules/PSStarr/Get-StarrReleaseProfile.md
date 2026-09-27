---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrReleaseProfile
---
<!-- markdownlint-disable -->

# Get-StarrReleaseProfile

## SYNOPSIS

Retrieves release profile settings from Radarr or Sonarr.

## SYNTAX

### Named (Default)

```
Get-StarrReleaseProfile [-InstanceName <string>] [-Application <string>] [-ReleaseProfileId <int>]
```

### Explicit

```
Get-StarrReleaseProfile -Url <string> -ApiKey <string> [-Application <string>]
 [-ReleaseProfileId <int>]
```

## DESCRIPTION

This function retrieves release-profile settings.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrReleaseProfile -InstanceName 'Main'
```

### EXAMPLE 2

```powershell
Get-StarrReleaseProfile -InstanceName 'Main' -ReleaseProfileId 1
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

### -ReleaseProfileId

The positive resource identifier for an individual release profile.

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

PSStarr.ReleaseProfile\

This function returns deserialized release profile objects.

PSStarr.ReleaseProfile

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrReleaseProfile/](https://psstarr.xyz/modules/PSStarr/Get-StarrReleaseProfile/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrReleaseProfile.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrReleaseProfile.ps1)
