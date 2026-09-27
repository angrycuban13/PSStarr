---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrMovieFile
---
<!-- markdownlint-disable -->

# Get-StarrRadarrMovieFile

## SYNOPSIS

Retrieves Radarr movie files from a Starr instance.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrMovieFile [-InstanceName <string>] [-MovieFileId <int>] [-MovieIdFilter <int[]>]
 [-MovieFileIdFilter <int[]>]
```

### Explicit

```
Get-StarrRadarrMovieFile -Url <string> -ApiKey <string> [-MovieFileId <int>]
 [-MovieIdFilter <int[]>] [-MovieFileIdFilter <int[]>]
```

## DESCRIPTION

This function retrieves Radarr movie-file records.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrMovieFile -MovieFileId 456
```

### EXAMPLE 2

```powershell
Get-StarrRadarrMovieFile -InstanceName 'Main' -MovieIdFilter 123
```

### EXAMPLE 3

```powershell
Get-StarrRadarrMovieFile -Url 'http://localhost:7878' -ApiKey 'example-api-key' -MovieFileIdFilter 456,789
```

### EXAMPLE 4

```powershell
Get-StarrRadarrMovie -MovieId 123 | Get-StarrRadarrMovieFile
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

### -MovieFileId

The positive MovieFile resource identifier used for an individual lookup.

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

### -MovieFileIdFilter

The Radarr movie-file identifiers used to filter results.

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

### -MovieIdFilter

The Radarr movie identifiers used to filter results.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32[]
DefaultValue: ''
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

This function accepts objects with an Id property representing a Radarr movie.

## OUTPUTS

PSStarr.Radarr.MovieFile

This function returns response objects retrieved from the Starr API.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrMovieFile/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrMovieFile/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrMovieFile.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrMovieFile.ps1)
