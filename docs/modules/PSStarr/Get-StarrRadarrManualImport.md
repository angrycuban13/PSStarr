---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
ms.date: 09/26/2026
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrManualImport
---
<!-- markdownlint-disable -->

# Get-StarrRadarrManualImport

## SYNOPSIS

Retrieves Radarr manual import results.

## SYNTAX

### Named (Default)

```
Get-StarrRadarrManualImport [-InstanceName <string>] [-Folder <string>] [-DownloadId <string>]
 [-MovieId <int>] [-FilterExistingFiles <bool>]
```

### Explicit

```
Get-StarrRadarrManualImport -Url <string> -ApiKey <string> [-Folder <string>] [-DownloadId <string>]
 [-MovieId <int>] [-FilterExistingFiles <bool>]
```

## DESCRIPTION

This function inspects Radarr import candidates without importing them.
Inspection can scan server disks and read media files.
Folder identifies a server path.
MovieId without DownloadId selects existing movie files.
Radarr then ignores Folder and FilterExistingFiles.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrManualImport -InstanceName 'Main' -Folder '/downloads/movies'
```

### EXAMPLE 2

```powershell
Get-StarrRadarrManualImport -InstanceName 'Main' -MovieId 42
```

### EXAMPLE 3

```powershell
' -Folder '/downloads/movies'
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

### -DownloadId

The download-client identifier to inspect.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -FilterExistingFiles

Whether to omit existing files; omitted values retain the server default of true.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -Folder

The folder on the Radarr server to inspect.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -MovieId

The movie identifier to inspect.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Explicit
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None.

You cannot pipe objects to this function.

## OUTPUTS

PSStarr.Radarr.ManualImportItem\

This function returns deserialized Radarr response objects.

PSStarr.Radarr.ManualImportItem

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrManualImport/](https://psstarr.xyz/modules/PSStarr/Get-StarrRadarrManualImport/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrManualImport.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrManualImport.ps1)
