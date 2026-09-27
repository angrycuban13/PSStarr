---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Set-StarrRadarrCollectionMonitoring
---
<!-- markdownlint-disable -->

# Set-StarrRadarrCollectionMonitoring

## SYNOPSIS

Changes Radarr collection monitoring.

## SYNTAX

### Named (Default)

```
Set-StarrRadarrCollectionMonitoring -CollectionId <int[]> -Monitored <bool> [-InstanceName <string>]
 [-WhatIf] [-Confirm]
```

### Explicit

```
Set-StarrRadarrCollectionMonitoring -Url <string> -ApiKey <string> -CollectionId <int[]>
 -Monitored <bool> [-WhatIf] [-Confirm]
```

## DESCRIPTION

This function changes monitoring for selected collections.
It does not directly change movie monitoring or other collection settings.
Radarr queues a collection refresh after the update.
Enabling monitoring can start configured automation.
WhatIf prevents the update.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-StarrRadarrCollectionMonitoring -InstanceName 'Main' -CollectionId 42,43 -Monitored $true
```

### EXAMPLE 2

```powershell
' -CollectionId 42 -Monitored $false -WhatIf
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

### -CollectionId

One or more positive Radarr collection identifiers to update.

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

The saved Radarr instance name.
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

### -Monitored

The explicit monitoring state to apply to the selected collections.

```yaml
Type: System.Boolean
DefaultValue: False
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

The absolute base URL of the Radarr instance.

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

PSStarr.Radarr.Collection\

This function returns deserialized updated collection objects from Radarr.

PSStarr.Radarr.Collection

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Set-StarrRadarrCollectionMonitoring/](https://psstarr.xyz/modules/PSStarr/Set-StarrRadarrCollectionMonitoring/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Set-StarrRadarrCollectionMonitoring.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Set-StarrRadarrCollectionMonitoring.ps1)
