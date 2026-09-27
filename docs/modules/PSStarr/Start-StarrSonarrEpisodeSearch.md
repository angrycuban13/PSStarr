---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Start-StarrSonarrEpisodeSearch
---
<!-- markdownlint-disable -->

# Start-StarrSonarrEpisodeSearch

## SYNOPSIS

Starts a Sonarr search for selected episodes.

## SYNTAX

### Named (Default)

```
Start-StarrSonarrEpisodeSearch -EpisodeId <int[]> [-InstanceName <string>] [-WhatIf] [-Confirm]
```

### Explicit

```
Start-StarrSonarrEpisodeSearch -Url <string> -ApiKey <string> -EpisodeId <int[]> [-WhatIf]
 [-Confirm]
```

## DESCRIPTION

This function starts an asynchronous search for selected episodes.
The search contacts configured indexers and can consume provider quotas.
A successful response means Sonarr accepted the search, not that Sonarr found or downloaded releases.

## EXAMPLES

### EXAMPLE 1

```powershell
Start-StarrSonarrEpisodeSearch -InstanceName SonarrMain -EpisodeId 101,102
```

### EXAMPLE 2

```powershell
' -EpisodeId 101 -WhatIf
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with Sonarr.

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

### -EpisodeId

One or more positive Sonarr episode identifiers to search.

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

[https://psstarr.xyz/modules/PSStarr/Start-StarrSonarrEpisodeSearch/](https://psstarr.xyz/modules/PSStarr/Start-StarrSonarrEpisodeSearch/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Start-StarrSonarrEpisodeSearch.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Start-StarrSonarrEpisodeSearch.ps1)
