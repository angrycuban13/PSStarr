---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrQueueDetail
---
<!-- markdownlint-disable -->

# Get-StarrRadarrQueueDetail

## SYNOPSIS

Retrieves Radarr queue details.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrQueueDetail [-InstanceName <string>] [-MovieId <int>] [-IncludeMovie <bool>]
```

### Explicit

```
Get-StarrRadarrQueueDetail -Url <string> -ApiKey <string> [-MovieId <int>] [-IncludeMovie <bool>]
```

## DESCRIPTION

This function retrieves Radarr queue details.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrQueueDetail -InstanceName RadarrMain
```

### EXAMPLE 2

```powershell
Get-StarrRadarrQueueDetail -InstanceName RadarrMain -MovieId 42 -IncludeMovie $true
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

### -IncludeMovie

Includes movie resources in queue-detail records.

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

### -MovieId

Limits results to one movie identifier.

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

PSStarr.Radarr.QueueDetail\

This function returns Radarr queue-detail records.

PSStarr.Radarr.QueueDetail

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrQueueDetail/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrQueueDetail/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrQueueDetail.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrQueueDetail.ps1)
