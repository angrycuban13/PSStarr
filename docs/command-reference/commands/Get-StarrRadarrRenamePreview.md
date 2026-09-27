---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrRenamePreview
---
<!-- markdownlint-disable -->

# Get-StarrRadarrRenamePreview

## SYNOPSIS

Retrieves Radarr rename results.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrRenamePreview -MovieIdFilter <int[]> [-InstanceName <string>]
```

### Explicit

```
Get-StarrRadarrRenamePreview -Url <string> -ApiKey <string> -MovieIdFilter <int[]>
```

## DESCRIPTION

This function retrieves proposed movie-file names without renaming files.
Radarr inspects the selected movies to calculate the names.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrRenamePreview -InstanceName 'Main' -MovieIdFilter 42,43
```

### EXAMPLE 2

```powershell
Get-StarrRadarrRenamePreview -Url 'http://localhost:7878' -ApiKey 'example-api-key' -MovieIdFilter 42,43
```

### EXAMPLE 3

```powershell
Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrRenamePreview
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

### -MovieIdFilter

One or more movie identifiers whose rename previews are requested.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32[]
DefaultValue: ''
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

## OUTPUTS

PSStarr.Radarr.RenamePreview

This function returns deserialized Radarr response objects.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrRenamePreview/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrRenamePreview/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrRenamePreview.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrRenamePreview.ps1)
