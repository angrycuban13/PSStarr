---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrSonarrParse
---
<!-- markdownlint-disable -->

# Get-StarrSonarrParse

## SYNOPSIS

Retrieves Sonarr parsed release information.

## SYNTAX

### Named (Default)

```
Get-StarrSonarrParse -Title <string> [-InstanceName <string>] [-Path <string>]
```

### Explicit

```
Get-StarrSonarrParse -Url <string> -ApiKey <string> -Title <string> [-Path <string>]
```

## DESCRIPTION

This function parses a release title or path.
Path takes precedence, but Title remains required.
This function does not import or download files.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrSonarrParse -InstanceName Main -Title 'Example.Show.S01E01.1080p'
```

### EXAMPLE 2

```powershell
' -Title 'Example.Show.S01E01.1080p'
```

### EXAMPLE 3

```powershell
Get-StarrSonarrParse -InstanceName Main -Title 'Example.Show.S01E01' -Path '/media/Example.Show.S01E01.mkv'
```

Parses a server path while retaining the required title in the response.

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

### -Path

The Path value sent to Sonarr.

```yaml
Type: System.String
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

### -Title

The Title value sent to Sonarr.

```yaml
Type: System.String
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None.

You cannot pipe objects to this function.

## OUTPUTS

PSStarr.Sonarr.ParseResult\

This function returns response objects retrieved from the Sonarr API.

PSStarr.Sonarr.ParseResult

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrParse/](https://psstarr.xyz/modules/PSStarr/Get-StarrSonarrParse/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrParse.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Sonarr/Get-StarrSonarrParse.ps1)
