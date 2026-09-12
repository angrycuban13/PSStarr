function Start-StarrCommand {
    <#
    .SYNOPSIS
        Starts an application command in Radarr or Sonarr.

    .DESCRIPTION
        This function submits a command to run asynchronously through API v3 using the shared transport. It supports confirmation and WhatIf. Command names and arguments are application-specific; the server validates them. A successful response means accepted, not completed.

    .PARAMETER Name
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr or Sonarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER CommandName
        The application command name, such as RefreshMovie or RefreshSeries.

    .PARAMETER Arguments
        Additional command body properties. The reserved name property cannot be supplied here; use CommandName.

    .EXAMPLE
        Start-StarrCommand -Name Main -CommandName 'RefreshMovie' -Arguments @{ movieIds = @(42) }

    .EXAMPLE
        Start-StarrCommand -Url 'http://localhost:8989' -ApiKey '<api-key>' -CommandName 'RefreshSeries' -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the deserialized accepted command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $CommandName,

        [Parameter()]
        [ValidateNotNull()]
        [ValidateScript({
            foreach ($key in $_.Keys) {
                if ([System.String]$key -ieq 'name') {
                    throw 'Arguments cannot contain the reserved name property. Use CommandName.'
                }
            }

            $true
        })]
        [System.Collections.Hashtable]
        $Arguments
    )

    $target = if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $Url
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $Name
    }
    else {
        'the inferred Starr instance'
    }

    if (-not $PSCmdlet.ShouldProcess($target, 'Start command')) {
        return
    }

    $body = @{
        name = $CommandName
    }

    if ($PSBoundParameters.ContainsKey('Arguments')) {
        foreach ($key in $Arguments.Keys) {
            $body[$key] = $Arguments[$key]
        }
    }

    $request = @{
        Endpoint   = 'command'
        Method     = 'POST'
        ApiVersion = 'v3'
        Body       = $body
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
