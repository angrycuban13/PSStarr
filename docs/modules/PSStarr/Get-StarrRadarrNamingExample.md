---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrNamingExample
---
<!-- markdownlint-disable -->

# Get-StarrRadarrNamingExample

## SYNOPSIS

Retrieves Radarr naming example results.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrNamingExample [-InstanceName <string>]
```

### NamedCustom

```
Get-StarrRadarrNamingExample -NamingConfigId <int> [-InstanceName <string>] [-RenameMovies <bool>]
 [-ReplaceIllegalCharacters <bool>] [-ColonReplacementFormat <string>]
 [-StandardMovieFormat <string>] [-MovieFolderFormat <string>] [-ResourceName <string>]
```

### ExplicitCustom

```
Get-StarrRadarrNamingExample -Url <string> -ApiKey <string> -NamingConfigId <int>
 [-RenameMovies <bool>] [-ReplaceIllegalCharacters <bool>] [-ColonReplacementFormat <string>]
 [-StandardMovieFormat <string>] [-MovieFolderFormat <string>] [-ResourceName <string>]
```

### Explicit

```
Get-StarrRadarrNamingExample -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function previews movie and folder names without saving settings.
Radarr uses saved settings when no custom parameters are present.
Custom previews require NamingConfigId.
Supply all relevant custom settings.
Radarr applies default values to omitted fields instead of saved values.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrNamingExample -InstanceName 'Main' -NamingConfigId 1 -StandardMovieFormat '{Movie Title} ({Release Year})' -MovieFolderFormat '{Movie Title} ({Release Year})'
```

### EXAMPLE 2

```powershell
'
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
- Name: ExplicitCustom
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -ColonReplacementFormat

The colon replacement style.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
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

The saved Radarr instance name.
When omitted, the only matching instance is used.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Name
ParameterSets:
- Name: NamedCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -MovieFolderFormat

The custom movie folder format.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NamingConfigId

The positive naming configuration identifier required to activate custom previews.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -RenameMovies

Whether the custom naming configuration enables renaming.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ReplaceIllegalCharacters

Whether custom naming replaces illegal characters.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceName

The naming configuration resource name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -StandardMovieFormat

The custom movie filename format.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedCustom
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

The absolute base URL of the Radarr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitCustom
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

PSStarr.Radarr.ApplicationConfiguration\

This function returns deserialized Radarr response objects.

PSStarr.Radarr.ApplicationConfiguration

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrNamingExample/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrNamingExample/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrNamingExample.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrNamingExample.ps1)
