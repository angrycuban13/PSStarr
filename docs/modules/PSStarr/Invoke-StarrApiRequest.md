---
document type: cmdlet
external help file: PSStarr-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSStarr
PlatyPS schema version: 2024-05-01
title: Invoke-StarrApiRequest
---
<!-- markdownlint-disable -->

# Invoke-StarrApiRequest

## SYNOPSIS

Sends an authenticated request to a Starr application API.

## SYNTAX

### Named (Default)

```
Invoke-StarrApiRequest -Endpoint <string> [-InstanceName <string>] [-ApiVersion <string>]
 [-Method <string>] [-Query <hashtable>] [-Body <Object>] [-ContentType <string>]
 [-ExpectedApplication <string[]>] [-Unversioned]
```

### Explicit

```
Invoke-StarrApiRequest -Url <string> -ApiKey <string> -Endpoint <string> [-ApiVersion <string>]
 [-Method <string>] [-Query <hashtable>] [-Body <Object>] [-ContentType <string>]
 [-ExpectedApplication <string[]>] [-Unversioned]
```

## DESCRIPTION

This function sends an authenticated request to a Starr API and returns the response.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-StarrApiRequest -InstanceName 'RadarrMain' -Endpoint 'health'
```

### EXAMPLE 2

```powershell
' -Endpoint 'health'
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

### -ApiVersion

The version segment used in versioned API URLs.
When omitted, saved Prowlarr instances and explicit requests with ExpectedApplication Prowlarr use v1; other requests use v3.

```yaml
Type: System.String
DefaultValue: v3
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

### -Body

The request body.
Non-string values are serialized as JSON.

```yaml
Type: System.Object
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

### -ContentType

The request body content type.

```yaml
Type: System.String
DefaultValue: application/json
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

### -Endpoint

The relative API endpoint path.

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

### -ExpectedApplication

One or more application types supported by the calling wrapper.

```yaml
Type: System.String[]
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

### -InstanceName

The name of the saved Starr instance.

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

### -Method

The HTTP method used for the request.

```yaml
Type: System.String
DefaultValue: GET
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

### -Query

Query-string keys and values appended to the request URL.

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

### -Unversioned

Builds the request without an API version segment.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
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

### -Url

The absolute base URL of the Starr instance.

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

System.Object\

This function returns response objects retrieved from the Starr API.

System.Object

## NOTES

## RELATED LINKS

[https://psstarr.xyz/modules/PSStarr/Invoke-StarrApiRequest/](https://psstarr.xyz/modules/PSStarr/Invoke-StarrApiRequest/)

[https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Invoke-StarrApiRequest.ps1](https://github.com/angrycuban13/PSStarr/blob/main/PSStarr/Source/Public/General/Invoke-StarrApiRequest.ps1)
