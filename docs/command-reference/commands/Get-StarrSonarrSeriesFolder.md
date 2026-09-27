---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrSeriesFolder
---
<!-- markdownlint-disable -->

# Get-StarrSonarrSeriesFolder

## SYNOPSIS

Retrieves Sonarr calculated series folder name.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrSeriesFolder -SeriesId <int> [-InstanceName <string>]
```

### Explicit

```
Get-StarrSonarrSeriesFolder -Url <string> -ApiKey <string> -SeriesId <int>
```

## DESCRIPTION

This function returns the folder name that Sonarr calculates for a series.
It does not create or rename folders.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrSeriesFolder -InstanceName Main -SeriesId 42
```

### EXAMPLE 2

```powershell
' -SeriesId 42
```

### EXAMPLE 3

```powershell
Get-StarrSonarrSeries -SeriesId 42 | Get-StarrSonarrSeriesFolder
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

The optional saved instance name.
When omitted, the matching instance is inferred.

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

The positive Sonarr series identifier.
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
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
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

PSStarr.Sonarr.FolderPreview

This function returns response objects retrieved from the Sonarr API.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrSonarrSeriesFolder/](https://psstarr.xyz/command-reference/commands/Get-StarrSonarrSeriesFolder/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrSeriesFolder.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrSeriesFolder.ps1)
