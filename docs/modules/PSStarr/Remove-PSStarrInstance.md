---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Remove-PSStarrInstance
---
<!-- markdownlint-disable -->

# Remove-PSStarrInstance

## SYNOPSIS

Removes a saved Starr instance.

## SYNTAX

### All

```
Remove-PSStarrInstance [-Name] <string> [-WhatIf] [-Confirm]
```

## DESCRIPTION

This function removes a saved Starr instance and its empty configuration directories.

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-PSStarrInstance -Name 'RadarrMain' -Confirm:$false
```

## PARAMETERS

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

None.

This function does not return objects to the pipeline.

System.Void

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Remove-PSStarrInstance/](https://psstarr.xyz/modules/PSStarr/Remove-PSStarrInstance/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Remove-PSStarrInstance.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Remove-PSStarrInstance.ps1)
