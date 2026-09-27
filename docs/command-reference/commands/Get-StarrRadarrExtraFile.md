---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrExtraFile
---
<!-- markdownlint-disable -->

# Get-StarrRadarrExtraFile

## SYNOPSIS

Retrieves Radarr extra-file records.

## SYNTAX

### NamedList (Default)

```
Get-StarrRadarrExtraFile [-InstanceName <string>] [-MovieId <int>]
```

### ExplicitList

```
Get-StarrRadarrExtraFile -Url <string> -ApiKey <string> [-MovieId <int>]
```

## DESCRIPTION

This function retrieves Radarr extra-file information.
It does not return file contents.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrExtraFile -InstanceName 'Main' -MovieId 42
```

### EXAMPLE 2

```powershell
Get-StarrRadarrExtraFile -Url 'http://localhost:7878' -ApiKey 'example-api-key' -MovieId 42
```

### EXAMPLE 3

```powershell
Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrExtraFile
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with the instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitList
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
- Name: NamedList
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

The positive Radarr movie identifier used to filter records.
This parameter accepts an Id property from the pipeline.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: ExplicitList
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
- Name: NamedList
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

The absolute base URL of the instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitList
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

PSStarr.Radarr.ExtraFile

This function returns deserialized extra-file records.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrExtraFile/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrExtraFile/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrExtraFile.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrExtraFile.ps1)
