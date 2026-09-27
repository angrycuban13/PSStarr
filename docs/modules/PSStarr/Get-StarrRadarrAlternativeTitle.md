---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrAlternativeTitle
---
<!-- markdownlint-disable -->

# Get-StarrRadarrAlternativeTitle

## SYNOPSIS

Retrieves Radarr alternative titles.

## SYNTAX

### NamedList (Default)

```
Get-StarrRadarrAlternativeTitle [-InstanceName <string>] [-MovieId <int>] [-MovieMetadataId <int>]
```

### NamedId

```
Get-StarrRadarrAlternativeTitle -AlternativeTitleId <int> [-InstanceName <string>]
```

### ExplicitId

```
Get-StarrRadarrAlternativeTitle -Url <string> -ApiKey <string> -AlternativeTitleId <int>
```

### ExplicitList

```
Get-StarrRadarrAlternativeTitle -Url <string> -ApiKey <string> [-MovieId <int>]
 [-MovieMetadataId <int>]
```

## DESCRIPTION

This function retrieves Radarr alternative titles.
AlternativeTitleId selects one title.
Movie filters select a list.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrAlternativeTitle -InstanceName 'Main' -MovieId 42
```

### EXAMPLE 2

```powershell
Get-StarrRadarrAlternativeTitle -InstanceName 'Main' -AlternativeTitleId 7
```

### EXAMPLE 3

```powershell
' -MovieId 42
```

### EXAMPLE 4

```powershell
Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrAlternativeTitle
```

## PARAMETERS

### -AlternativeTitleId

The positive internal alternative-title identifier used for an individual lookup.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ApiKey

The API key used to authenticate with the instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitList
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

The saved Radarr instance name.
When omitted, the only matching instance is used.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: NamedId
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedList
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -MovieId

The positive Radarr movie identifier used to filter records.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: ExplicitList
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: NamedList
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -MovieMetadataId

The positive Radarr movie metadata identifier used to filter records.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitList
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedList
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
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitList
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

PSStarr.Radarr.AlternativeTitle\

This function accepts objects with an Id property representing a Radarr movie.

System.Int32

## OUTPUTS

System.Object\

This function returns deserialized alternative titles.

PSStarr.Radarr.AlternativeTitle

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrAlternativeTitle/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrAlternativeTitle/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrAlternativeTitle.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrAlternativeTitle.ps1)
