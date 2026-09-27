---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrRelease
---
<!-- markdownlint-disable -->

# Get-StarrRadarrRelease

## SYNOPSIS

Retrieves Radarr release results.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrRelease [-InstanceName <string>] [-MovieId <int>]
```

### Explicit

```
Get-StarrRadarrRelease -Url <string> -ApiKey <string> [-MovieId <int>]
```

## DESCRIPTION

This function retrieves available Radarr releases.
A movie identifier starts an indexer search.
Without it, the function retrieves RSS releases.
Requests can contact indexers and update server caches.
They do not download releases.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrRelease -InstanceName 'Main' -MovieId 42
```

### EXAMPLE 2

```powershell
Get-StarrRadarrRelease -Url 'http://localhost:7878' -ApiKey 'example-api-key' -MovieId 42
```

### EXAMPLE 3

```powershell
Get-StarrRadarrRelease -InstanceName 'Main'
```

Fetches RSS releases instead of searching for a specific movie.

### EXAMPLE 4

```powershell
Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrRelease
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

### -InstanceName

The saved Radarr instance name.
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

The movie identifier to search; omit to fetch RSS releases.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: Named
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

The absolute base URL of the Radarr instance.

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

This function accepts objects with an Id property representing a Radarr movie.

## OUTPUTS

PSStarr.Radarr.Release

This function returns deserialized Radarr response objects.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrRelease/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrRelease/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrRelease.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrRelease.ps1)
