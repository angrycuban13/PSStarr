---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrRenamePreview
---
<!-- markdownlint-disable -->

# Get-StarrSonarrRenamePreview

## SYNOPSIS

Retrieves Sonarr episode-file rename previews.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrRenamePreview -SeriesId <int> [-InstanceName <string>] [-SeasonNumber <int>]
```

### Explicit

```
Get-StarrSonarrRenamePreview -Url <string> -ApiKey <string> -SeriesId <int> [-SeasonNumber <int>]
```

## DESCRIPTION

This function returns proposed episode-file names for a series and optional season.
It does not rename files.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrRenamePreview -InstanceName Main -SeriesId 42
```

### EXAMPLE 2

```powershell
' -SeriesId 42
```

### EXAMPLE 3

```powershell
Get-StarrSonarrRenamePreview -InstanceName Main -SeriesId 42 -SeasonNumber 0
```

Previews renames for specials only.

### EXAMPLE 4

```powershell
Get-StarrSonarrSeries -SeriesId 42 | Get-StarrSonarrRenamePreview
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

### -SeasonNumber

The season to inspect, including zero for specials.
Omit to inspect all seasons.

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

PSStarr.Sonarr.RenamePreview

This function returns response objects retrieved from the Sonarr API.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrSonarrRenamePreview/](https://psstarr.xyz/command-reference/commands/Get-StarrSonarrRenamePreview/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrRenamePreview.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrRenamePreview.ps1)
