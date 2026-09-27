---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrEpisode
---
<!-- markdownlint-disable -->

# Get-StarrSonarrEpisode

## SYNOPSIS

Retrieves Sonarr episodes from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrEpisode [-InstanceName <string>] [-EpisodeId <int>] [-SeriesId <int>]
 [-SeasonNumber <int>] [-EpisodeIdFilter <int[]>] [-EpisodeFileId <int>] [-IncludeSeries <bool>]
 [-IncludeEpisodeFile <bool>] [-IncludeImages <bool>]
```

### Explicit

```
Get-StarrSonarrEpisode -Url <string> -ApiKey <string> [-EpisodeId <int>] [-SeriesId <int>]
 [-SeasonNumber <int>] [-EpisodeIdFilter <int[]>] [-EpisodeFileId <int>] [-IncludeSeries <bool>]
 [-IncludeEpisodeFile <bool>] [-IncludeImages <bool>]
```

## DESCRIPTION

This function retrieves Sonarr episodes.
Specify EpisodeId, SeriesId, EpisodeIdFilter, or EpisodeFileId to select the episodes.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrEpisode -EpisodeId 456
```

### EXAMPLE 2

```powershell
Get-StarrSonarrEpisode -InstanceName 'Main' -SeriesId 123
```

### EXAMPLE 3

```powershell
' -EpisodeIdFilter 456,789
```

### EXAMPLE 4

```powershell
Get-StarrSonarrSeries -SeriesId 123 | Get-StarrSonarrEpisode
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with the Starr instance.

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

### -EpisodeFileId

The Sonarr episode-file identifier used to filter results.

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

### -EpisodeId

The positive Episode resource identifier used for an individual lookup.

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

### -EpisodeIdFilter

The Sonarr episode identifiers used to filter results.

```yaml
Type: System.Int32[]
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

### -IncludeEpisodeFile

Includes episode-file data when true.

```yaml
Type: System.Boolean
DefaultValue: False
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

### -IncludeImages

Includes image data when true.

```yaml
Type: System.Boolean
DefaultValue: False
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

### -IncludeSeries

Includes series data when true.

```yaml
Type: System.Boolean
DefaultValue: False
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

The optional name of a saved Starr instance.
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

### -SeasonNumber

The Sonarr season number used to filter results.

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

### -SeriesId

The Sonarr series identifier used to filter results.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Url

The absolute base URL of the Starr instance.

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

System.Object\

This function accepts objects with an Id property representing a Sonarr series.

System.Int32

## OUTPUTS

PSStarr.Sonarr.Episode\

This function returns response objects retrieved from the Starr API.

PSStarr.Sonarr.Episode

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrEpisode/](https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrEpisode/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrEpisode.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrEpisode.ps1)
