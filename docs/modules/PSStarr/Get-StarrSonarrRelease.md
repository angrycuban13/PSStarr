---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrRelease
---
<!-- markdownlint-disable -->

# Get-StarrSonarrRelease

## SYNOPSIS

Retrieves Sonarr release search results.

## SYNTAX

### NamedRss (Default)

```
Get-StarrSonarrRelease [-InstanceName <string>]
```

### NamedSeason

```
Get-StarrSonarrRelease -SeriesId <int> -SeasonNumber <int> [-InstanceName <string>]
```

### NamedEpisode

```
Get-StarrSonarrRelease -EpisodeId <int> [-InstanceName <string>]
```

### ExplicitSeason

```
Get-StarrSonarrRelease -Url <string> -ApiKey <string> -SeriesId <int> -SeasonNumber <int>
```

### ExplicitEpisode

```
Get-StarrSonarrRelease -Url <string> -ApiKey <string> -EpisodeId <int>
```

### ExplicitRss

```
Get-StarrSonarrRelease -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function retrieves RSS releases when you omit selectors.
It searches indexers for an episode or a series and season when you supply selectors.
A search can consume provider quotas, take time, and populate server caches.
This function does not download releases.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrRelease -InstanceName Main -EpisodeId 42
```

### EXAMPLE 2

```powershell
' -EpisodeId 42
```

### EXAMPLE 3

```powershell
Get-StarrSonarrRelease -InstanceName Main
```

Fetches RSS release results from the configured indexers without downloading.

### EXAMPLE 4

```powershell
Get-StarrSonarrRelease -InstanceName Main -SeriesId 42 -SeasonNumber 0
```

Searches indexers for the specials season of series 42.

### EXAMPLE 5

```powershell
Get-StarrSonarrEpisode -EpisodeId 42 | Get-StarrSonarrRelease
```

## PARAMETERS

### -ApiKey

The API key used to authenticate.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitEpisode
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitRss
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EpisodeId

The episode to search.
Cannot be combined with season selection.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: ExplicitEpisode
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: NamedEpisode
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -InstanceName

The optional saved instance name.
When omitted, the matching instance is inferred.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Name
ParameterSets:
- Name: NamedSeason
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedEpisode
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedRss
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SeasonNumber

The season to search, including zero for specials.
SeriesId must also be supplied.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SeriesId

The series to search.
SeasonNumber must also be supplied.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Url

The absolute Sonarr base URL.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitSeason
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitEpisode
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitRss
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

System.Object\

This function accepts objects with an Id property representing a Sonarr episode.

System.Int32

## OUTPUTS

PSStarr.Sonarr.Release\

This function returns response objects retrieved from the Sonarr API.

PSStarr.Sonarr.Release

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrRelease/](https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrRelease/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrRelease.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrRelease.ps1)
