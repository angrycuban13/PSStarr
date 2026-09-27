---
document type: cmdlet
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Get-StarrRadarrImportListExclusion
---
<!-- markdownlint-disable -->

# Get-StarrRadarrImportListExclusion

## SYNOPSIS

Retrieves Radarr import-list exclusions.

## SYNTAX

### NamedPage (Default)

```
Get-StarrRadarrImportListExclusion [-InstanceName <string>] [-Page <int>] [-PageSize <int>]
 [-SortKey <string>] [-SortDirection <string>]
```

### NamedId

```
Get-StarrRadarrImportListExclusion -ExclusionId <int> [-InstanceName <string>]
```

### ExplicitId

```
Get-StarrRadarrImportListExclusion -Url <string> -ApiKey <string> -ExclusionId <int>
```

### ExplicitPage

```
Get-StarrRadarrImportListExclusion -Url <string> -ApiKey <string> [-Page <int>] [-PageSize <int>]
 [-SortKey <string>] [-SortDirection <string>]
```

## DESCRIPTION

This function retrieves one page of Radarr import-list exclusions or one exclusion by identifier.
Paged results include paging metadata.
It does not retrieve all pages.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-StarrRadarrImportListExclusion -InstanceName 'Main' -Page 2 -PageSize 20
```

### EXAMPLE 2

```powershell
Get-StarrRadarrImportListExclusion -InstanceName 'Main' -ExclusionId 7
```

### EXAMPLE 3

```powershell
Get-StarrRadarrImportListExclusion -Url 'http://localhost:7878' -ApiKey 'example-api-key'
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
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitPage
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ExclusionId

The positive internal exclusion ID, not a movie or series database ID.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedId
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

The saved instance name.
When omitted, the only matching Radarr instance is used.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Name
ParameterSets:
- Name: NamedId
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Page

The one-based page to retrieve.
When omitted, the server default applies.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageSize

The maximum records per page.
When omitted, the server default applies.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SortDirection

The result sort direction.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SortKey

The resource field used to sort the page.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ExplicitPage
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NamedPage
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
- Name: ExplicitId
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ExplicitPage
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

PSStarr.Radarr.PagedResult, [PSStarr.Radarr.ImportListExclusion]

This function returns a paging object containing records, or an individual exclusion.

## NOTES

## RELATED LINKS

[https://psstarr.xyz/command-reference/commands/Get-StarrRadarrImportListExclusion/](https://psstarr.xyz/command-reference/commands/Get-StarrRadarrImportListExclusion/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrImportListExclusion.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/Radarr/Get-StarrRadarrImportListExclusion.ps1)
