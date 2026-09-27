---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Start-StarrCommand
---
<!-- markdownlint-disable -->

# Start-StarrCommand

## SYNOPSIS

Submits an application command using the legacy command name.

## SYNTAX

### Named (Default)

```
Start-StarrCommand -CommandName <string> [-InstanceName <string>] [-Arguments <hashtable>] [-WhatIf]
 [-Confirm]
```

### Explicit

```
Start-StarrCommand -Url <string> -ApiKey <string> -CommandName <string> [-Arguments <hashtable>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION

This function submits a command to Radarr or Sonarr.
The command name remains available for compatibility.
Use Invoke-StarrCommand in new code.

## EXAMPLES

### EXAMPLE 1

```powershell
Start-StarrCommand -InstanceName Main -CommandName 'RefreshMovie' -Arguments @{ movieIds = @(42) }
```

### EXAMPLE 2

```powershell
Start-StarrCommand -Url 'http://localhost:8989' -ApiKey 'example-api-key' -CommandName 'RefreshSeries' -WhatIf
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

### -Arguments

Additional command body properties.
The reserved name property cannot be supplied here; use CommandName.

```yaml
Type: System.Collections.Hashtable
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

### -CommandName

The application command name, such as RefreshMovie or RefreshSeries.

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

### -Url

The absolute base URL of the Radarr or Sonarr instance.

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

PSStarr.Command

This function returns the deserialized accepted command resource.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Start-StarrCommand/](https://psstarr.xyz/command-reference/commands/Start-StarrCommand/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Start-StarrCommand.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Start-StarrCommand.ps1)
