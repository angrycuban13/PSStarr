---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrNamingExample
---
<!-- markdownlint-disable -->

# Get-StarrSonarrNamingExample

## SYNOPSIS

Retrieves Sonarr filename examples.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrNamingExample [-InstanceName <string>]
```

### NamedCustom

```
Get-StarrSonarrNamingExample -NamingConfigId <int> [-InstanceName <string>] [-RenameEpisodes <bool>]
 [-ReplaceIllegalCharacters <bool>] [-ColonReplacementFormat <int>]
 [-CustomColonReplacementFormat <string>] [-MultiEpisodeStyle <int>]
 [-StandardEpisodeFormat <string>] [-DailyEpisodeFormat <string>] [-AnimeEpisodeFormat <string>]
 [-SeriesFolderFormat <string>] [-SeasonFolderFormat <string>] [-SpecialsFolderFormat <string>]
```

### ExplicitCustom

```
Get-StarrSonarrNamingExample -Url <string> -ApiKey <string> -NamingConfigId <int>
 [-RenameEpisodes <bool>] [-ReplaceIllegalCharacters <bool>] [-ColonReplacementFormat <int>]
 [-CustomColonReplacementFormat <string>] [-MultiEpisodeStyle <int>]
 [-StandardEpisodeFormat <string>] [-DailyEpisodeFormat <string>] [-AnimeEpisodeFormat <string>]
 [-SeriesFolderFormat <string>] [-SeasonFolderFormat <string>] [-SpecialsFolderFormat <string>]
```

### Explicit

```
Get-StarrSonarrNamingExample -Url <string> -ApiKey <string>
```

## DESCRIPTION

This function returns filename examples from saved naming settings or a supplied configuration.
Custom fields require a NamingConfigId greater than zero.
Sonarr does not merge supplied fields with saved settings.
This function does not save settings or rename files.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrNamingExample -InstanceName Main
```

### EXAMPLE 2

```powershell
'
```

### EXAMPLE 3

```powershell
Get-StarrSonarrNamingExample -InstanceName Main -NamingConfigId 1 -RenameEpisodes $true -ReplaceIllegalCharacters $true -ColonReplacementFormat 0 -MultiEpisodeStyle 0 -StandardEpisodeFormat '{Series Title} - S{season:00}E{episode:00}' -DailyEpisodeFormat '{Series Title} - {Air-Date}' -AnimeEpisodeFormat '{Series Title} - S{season:00}E{episode:00}' -SeriesFolderFormat '{Series Title}' -SeasonFolderFormat 'Season {season:00}' -SpecialsFolderFormat 'Specials'
```

Previews a supplied configuration without saving it.
Sonarr uses its model defaults for omitted fields, not the saved configuration.

## PARAMETERS

### -AnimeEpisodeFormat

The AnimeEpisodeFormat template used in the preview.

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

### -ApiKey

The API key used to authenticate.

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

The colon replacement mode accepted by Sonarr.

```yaml
Type: System.Int32
DefaultValue: 0
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

### -CustomColonReplacementFormat

The custom colon replacement text.

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

### -DailyEpisodeFormat

The DailyEpisodeFormat template used in the preview.

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

The optional saved instance name.
When omitted, the matching instance is inferred.

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

### -MultiEpisodeStyle

The Sonarr multi-episode naming style, from zero through five.

```yaml
Type: System.Int32
DefaultValue: 0
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

A positive configuration identifier that tells Sonarr to use supplied fields instead of saved settings.
Supply the complete desired configuration; fields are not merged with saved settings.

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

### -RenameEpisodes

Whether episode renaming is enabled in the preview.

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

Whether illegal filename characters are replaced.

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

### -SeasonFolderFormat

The SeasonFolderFormat template used in the preview.

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

### -SeriesFolderFormat

The SeriesFolderFormat template used in the preview.

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

### -SpecialsFolderFormat

The SpecialsFolderFormat template used in the preview.

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

### -StandardEpisodeFormat

The StandardEpisodeFormat template used in the preview.

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

The absolute Sonarr base URL.

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

PSStarr.Sonarr.ApplicationConfiguration\

This function returns response objects retrieved from the Sonarr API.

PSStarr.Sonarr.ApplicationConfiguration

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrNamingExample/](https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrNamingExample/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrNamingExample.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrNamingExample.ps1)
