---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrCredit
---
<!-- markdownlint-disable -->

# Get-StarrRadarrCredit

## SYNOPSIS

Retrieves Radarr credits from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrCredit [-InstanceName <string>] [-CreditId <int>] [-MovieId <int>]
 [-MovieMetadataId <int>]
```

### Explicit

```
Get-StarrRadarrCredit -Url <string> -ApiKey <string> [-CreditId <int>] [-MovieId <int>]
 [-MovieMetadataId <int>]
```

## DESCRIPTION

This function retrieves Radarr credits.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrCredit
```

### EXAMPLE 2

```powershell
Get-StarrRadarrCredit -InstanceName 'Main'
```

### EXAMPLE 3

```powershell
'
```

### EXAMPLE 4

```powershell
Get-StarrRadarrMovie -MovieId 123 | Get-StarrRadarrCredit
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

### -CreditId

The positive Credit resource identifier used for an individual lookup.

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

### -MovieId

The Radarr movie identifier used to filter results.
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

### -MovieMetadataId

The Radarr movie metadata identifier used to filter results.

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

This function accepts objects with an Id property representing a Radarr movie.

System.Int32

## OUTPUTS

PSStarr.Radarr.Credit\

This function returns response objects retrieved from the Starr API.

PSStarr.Radarr.Credit

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrCredit/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrCredit/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrCredit.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrCredit.ps1)
