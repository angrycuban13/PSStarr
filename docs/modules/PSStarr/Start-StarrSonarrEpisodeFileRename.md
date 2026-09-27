---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Start-StarrSonarrEpisodeFileRename
---
<!-- markdownlint-disable -->

# Start-StarrSonarrEpisodeFileRename

## SYNOPSIS

Starts renaming selected Sonarr episode files.

## SYNTAX

### Named (Default)

```
Start-StarrSonarrEpisodeFileRename -SeriesId <int> -EpisodeFileId <int[]> [-InstanceName <string>]
 [-WhatIf] [-Confirm]
```

### Explicit

```
Start-StarrSonarrEpisodeFileRename -Url <string> -ApiKey <string> -SeriesId <int>
 -EpisodeFileId <int[]> [-WhatIf] [-Confirm]
```

## DESCRIPTION

This function starts an asynchronous rename of selected episode files.
Use Get-StarrSonarrRenamePreview first to inspect the proposed names.
A successful response means Sonarr accepted the command, not that the rename completed.

## EXAMPLES

### EXAMPLE 1

```powershell
Start-StarrSonarrEpisodeFileRename -InstanceName SonarrMain -SeriesId 42 -EpisodeFileId 100,101
```

### EXAMPLE 2

```powershell
' -SeriesId 42 -EpisodeFileId 100 -WhatIf
```

## PARAMETERS

### -ApiKey

The API key used to authenticate.

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

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
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

### -EpisodeFileId

One or more positive episode-file identifiers to rename.

```yaml
Type: System.Int32[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
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

The optional saved Sonarr instance name.
The matching instance is inferred when omitted.

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

### -SeriesId

The positive identifier of the series that owns the files.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None.

You cannot pipe objects to this function.

## OUTPUTS

PSStarr.Sonarr.Command\

This function returns the accepted Sonarr command resource.

PSStarr.Sonarr.Command

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Start-StarrSonarrEpisodeFileRename/](https://psstarr.xyz/modules/PSStarr/Start-StarrSonarrEpisodeFileRename/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Start-StarrSonarrEpisodeFileRename.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Start-StarrSonarrEpisodeFileRename.ps1)
