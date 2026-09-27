---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrMovieFolder
---
<!-- markdownlint-disable -->

# Get-StarrRadarrMovieFolder

## SYNOPSIS

Retrieves Radarr movie folder results.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrMovieFolder -MovieId <int> [-InstanceName <string>]
```

### Explicit

```
Get-StarrRadarrMovieFolder -Url <string> -ApiKey <string> -MovieId <int>
```

## DESCRIPTION

This function retrieves the folder name that Radarr calculates for a movie.
It does not list files, create folders, or move movies.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrMovieFolder -InstanceName 'Main' -MovieId 42
```

### EXAMPLE 2

```powershell
' -MovieId 42
```

### EXAMPLE 3

```powershell
Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrMovieFolder
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

The movie identifier whose folder name is calculated.
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
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: Named
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

System.Int32

## OUTPUTS

PSStarr.Radarr.FolderPreview

This function returns deserialized Radarr response objects.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrMovieFolder/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrMovieFolder/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrMovieFolder.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrMovieFolder.ps1)
