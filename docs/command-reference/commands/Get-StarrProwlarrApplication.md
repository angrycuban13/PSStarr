---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrProwlarrApplication
---
<!-- markdownlint-disable -->

# Get-StarrProwlarrApplication

## SYNOPSIS

Retrieves applications configured for synchronization from Prowlarr.

## SYNTAX

### Named (Default)

```
Get-StarrProwlarrApplication [-InstanceName <string>] [-ApplicationId <int>]
```

### Explicit

```
Get-StarrProwlarrApplication -Url <string> -ApiKey <string> [-ApplicationId <int>]
```

## DESCRIPTION

This function retrieves configured applications that Prowlarr synchronizes with.
It redacts provider secrets.
Do not use returned objects for updates.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrProwlarrApplication -InstanceName Main
```

### EXAMPLE 2

```powershell
Get-StarrProwlarrApplication -InstanceName Main -ApplicationId 1
```

### EXAMPLE 3

```powershell
'
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

### -ApplicationId

The positive resource identifier for an individual lookup.

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

The saved Prowlarr instance name.
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

### -Url

The absolute base URL of the instance.

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

PSStarr.Prowlarr.Application

This function returns deserialized Prowlarr Application resources with provider secrets redacted.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrApplication/](https://psstarr.xyz/command-reference/commands/Get-StarrProwlarrApplication/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrApplication.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Prowlarr/Get-StarrProwlarrApplication.ps1)
