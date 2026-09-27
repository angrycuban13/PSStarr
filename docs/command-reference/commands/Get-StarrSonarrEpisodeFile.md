---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrEpisodeFile
---
<!-- markdownlint-disable -->

# Get-StarrSonarrEpisodeFile

## SYNOPSIS

Retrieves Sonarr episode files from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrEpisodeFile [-InstanceName <string>] [-EpisodeFileId <int>] [-SeriesId <int>]
 [-EpisodeFileIdFilter <int[]>]
```

### Explicit

```
Get-StarrSonarrEpisodeFile -Url <string> -ApiKey <string> [-EpisodeFileId <int>] [-SeriesId <int>]
 [-EpisodeFileIdFilter <int[]>]
```

## DESCRIPTION

This function retrieves Sonarr episode files.
Specify EpisodeFileId, SeriesId, or EpisodeFileIdFilter to select the files.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrEpisodeFile -EpisodeFileId 456
```

### EXAMPLE 2

```powershell
Get-StarrSonarrEpisodeFile -InstanceName 'Main' -SeriesId 123
```

### EXAMPLE 3

```powershell
Get-StarrSonarrEpisodeFile -Url 'http://localhost:8989' -ApiKey 'example-api-key' -EpisodeFileIdFilter 456,789
```

### EXAMPLE 4

```powershell
Get-StarrSonarrSeries -SeriesId 123 | Get-StarrSonarrEpisodeFile
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

The positive EpisodeFile resource identifier used for an individual lookup.

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

### -EpisodeFileIdFilter

The Sonarr episode-file identifiers used to filter results.

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

System.Object

This function accepts objects with an Id property representing a Sonarr series.

## OUTPUTS

PSStarr.Sonarr.EpisodeFile

This function returns response objects retrieved from the Starr API.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrSonarrEpisodeFile/](https://psstarr.xyz/command-reference/commands/Get-StarrSonarrEpisodeFile/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrEpisodeFile.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrEpisodeFile.ps1)
