---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrCalendar
---
<!-- markdownlint-disable -->

# Get-StarrRadarrCalendar

## SYNOPSIS

Retrieves Radarr calendar records.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrCalendar [-InstanceName <string>] [-Start <datetime>] [-End <datetime>]
 [-Unmonitored <bool>] [-TagIdFilter <int[]>]
```

### Explicit

```
Get-StarrRadarrCalendar -Url <string> -ApiKey <string> [-Start <datetime>] [-End <datetime>]
 [-Unmonitored <bool>] [-TagIdFilter <int[]>]
```

## DESCRIPTION

This function retrieves Radarr calendar entries.
It can filter entries by date, monitoring state, and tag.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrCalendar -InstanceName RadarrMain
```

### EXAMPLE 2

```powershell
Get-StarrRadarrCalendar -InstanceName RadarrMain -Start (Get-Date) -TagIdFilter 2,5
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with Radarr.

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

### -InstanceName

The optional saved Radarr instance name.

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

Includes unmonitored movies when true.

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

The absolute Radarr base URL.

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

PSStarr.Radarr.CalendarEntry\

This function returns Radarr calendar records.

PSStarr.Radarr.CalendarEntry

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrCalendar/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrCalendar/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrCalendar.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrCalendar.ps1)
