---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrDevelopmentConfiguration
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrDevelopmentConfiguration

## SYNOPSIS

Retrieves Prowlarr development settings.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrDevelopmentConfiguration [-InstanceName <string>] [-ConfigurationId <int>]
```

### Explicit

```
Get-StarrProwlarrDevelopmentConfiguration -Url <string> -ApiKey <string> [-ConfigurationId <int>]
```

## DESCRIPTION

This function retrieves Prowlarr development settings.
It can retrieve settings for one configuration identifier.
Treat returned settings as private application configuration.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrDevelopmentConfiguration -InstanceName Main
```

### EXAMPLE 2

```powershell
' -ConfigurationId 1
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

### -ConfigurationId

The positive configuration identifier.
Omit to read the current configuration.

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

### -InstanceName

The optional saved Prowlarr instance name.
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

The absolute Prowlarr base URL.

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

PSStarr.Prowlarr.ApplicationConfiguration\

This function returns Prowlarr development configuration.

PSStarr.Prowlarr.ApplicationConfiguration

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrDevelopmentConfiguration/](https://psstarr.xyz/modules/PSStarr/Get-StarrProwlarrDevelopmentConfiguration/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrDevelopmentConfiguration.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrDevelopmentConfiguration.ps1)
