---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrCalendar
---
<!-- markdownlint-disable -->

# Get-StarrSonarrCalendar

## SYNOPSIS

Retrieves Sonarr calendar records.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrCalendar [-InstanceName <string>] [-Start <datetime>] [-End <datetime>]
 [-Unmonitored <bool>] [-TagIdFilter <int[]>] [-IncludeSeries <bool>] [-IncludeEpisodeFile <bool>]
 [-IncludeEpisodeImages <bool>]
```

### Explicit

```
Get-StarrSonarrCalendar -Url <string> -ApiKey <string> [-Start <datetime>] [-End <datetime>]
 [-Unmonitored <bool>] [-TagIdFilter <int[]>] [-IncludeSeries <bool>] [-IncludeEpisodeFile <bool>]
 [-IncludeEpisodeImages <bool>]
```

## DESCRIPTION

This function retrieves Sonarr calendar episodes.
You can select a date range and filter by monitoring state or tag identifier.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrCalendar -InstanceName SonarrMain
```

### EXAMPLE 2

```powershell
Get-StarrSonarrCalendar -InstanceName SonarrMain -Start (Get-Date) -IncludeSeries $true
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with Sonarr.

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

### -End

The end of the calendar range.

```yaml
Type: System.DateTime
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

Includes episode-file resources in calendar records.

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

### -IncludeEpisodeImages

Includes episode images in calendar records.

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

Includes series resources in calendar records.

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

The optional saved Sonarr instance name.

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

### -Start

The beginning of the calendar range.

```yaml
Type: System.DateTime
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

### -TagIdFilter

Limits results to the supplied tag identifiers.

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

### -Unmonitored

Includes unmonitored series when true.

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

None.

You cannot pipe objects to this function.

## OUTPUTS

PSStarr.Sonarr.CalendarEntry\

This function returns Sonarr calendar records.

PSStarr.Sonarr.CalendarEntry

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrCalendar/](https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrCalendar/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrCalendar.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrCalendar.ps1)
