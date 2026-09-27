---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrApplicationConfiguration
---
<!-- markdownlint-disable -->

# Get-StarrApplicationConfiguration

## SYNOPSIS

Retrieves application configuration from a Starr application.

## SYNTAX

### Named (Default)

```
Get-StarrApplicationConfiguration -Section <string> [-InstanceName <string>] [-Application <string>]
 [-ConfigurationId <int>]
```

### Explicit

```
Get-StarrApplicationConfiguration -Url <string> -ApiKey <string> -Section <string>
 [-Application <string>] [-ConfigurationId <int>]
```

## DESCRIPTION

This function retrieves a supported application configuration section.
It does not retrieve saved PSStarr connections.
Host credentials are redacted.
Do not use returned host settings in an update.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrApplicationConfiguration -InstanceName Main -Section Naming
```

### EXAMPLE 2

```powershell
Get-StarrApplicationConfiguration -InstanceName Main -Section Host -ConfigurationId 1
```

### EXAMPLE 3

```powershell
' -Section Metadata
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

### -Application

The expected application type.
This selects Prowlarr API v1 when required and validates section compatibility.

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

### -ConfigurationId

The positive identifier for the configuration resource.
Omit this to retrieve the current section.

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

The saved instance name.
When omitted, the only configured instance is used.

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

### -Section

The application configuration section.
Metadata is available only in Radarr.

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

PSStarr.ApplicationConfiguration

This function returns deserialized application configuration with host secrets redacted.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrApplicationConfiguration/](https://psstarr.xyz/command-reference/commands/Get-StarrApplicationConfiguration/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrApplicationConfiguration.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Get-StarrApplicationConfiguration.ps1)
