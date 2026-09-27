---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Set-PSStarrInstance
---
<!-- markdownlint-disable -->

# Set-PSStarrInstance

## SYNOPSIS

Creates or updates a saved PSStarr instance.

## SYNTAX

### All

```
Set-PSStarrInstance [-Name] <string> [[-Application] <string>] [[-Url] <string>]
 [[-ApiKey] <string>] [-EncryptionMode <string>] [-WhatIf] [-Confirm]
```

## DESCRIPTION

This function creates or updates a saved Starr instance.
A new instance requires Application, Url, and ApiKey.
An update can change one or more values, including the encryption mode.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey 'example-api-key'
```

### EXAMPLE 2

```powershell
Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey 'example-api-key' -EncryptionMode Aes256
```

### EXAMPLE 3

```powershell
Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey 'example-api-key' -EncryptionMode None
```

### EXAMPLE 4

```powershell
Set-PSStarrInstance -Name 'RadarrMain' -Url 'http://localhost:7879'
```

### EXAMPLE 5

```powershell
Set-PSStarrInstance -Name 'RadarrMain' -EncryptionMode Aes256
```

## PARAMETERS

### -ApiKey

The API key used to authenticate with the Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Application

The Starr application type.
Valid values are Radarr, Sonarr, and Prowlarr.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
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

### -EncryptionMode

The API-key storage mode.
The default is Dpapi on Windows and None on other platforms.
Aes256 requires PSSTARR_AES_KEY to contain exactly 32 Base64-encoded bytes.

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

### -Name

The name of the saved Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Url

The absolute base URL of the Starr instance.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
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

PSStarr.Instance

This function returns a redacted saved-instance configuration object.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Set-PSStarrInstance/](https://psstarr.xyz/command-reference/commands/Set-PSStarrInstance/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Set-PSStarrInstance.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Set-PSStarrInstance.ps1)
