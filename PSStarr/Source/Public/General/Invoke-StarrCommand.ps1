function Invoke-StarrCommand {
    <#
    .SYNOPSIS
        Submits an application command to Radarr or Sonarr.

    .DESCRIPTION
        This function is the canonical advanced command-submission interface for Radarr and Sonarr API v3. Command names and arguments are application-specific, and the server validates them. A successful response means the asynchronous command was accepted, not completed.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only compatible configured instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr or Sonarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER CommandName
        The application command name, such as RefreshMovie or RefreshSeries.

    .PARAMETER Arguments
        Additional command body properties. The reserved name property cannot be supplied here; use CommandName.

    .EXAMPLE
        Invoke-StarrCommand -InstanceName Main -CommandName RefreshMovie -Arguments @{ movieIds = @(42) }

    .EXAMPLE
        Invoke-StarrCommand -Url 'http://localhost:8989' -ApiKey '<api-key>' -CommandName RefreshSeries -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Command]

        This function returns the accepted command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Command')]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

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
                    if ([System.String]$key -ieq 'Name') {
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
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $InstanceName
    }
    else {
        'the inferred Starr instance'
    }

    if (-not $PSCmdlet.ShouldProcess($target, 'Invoke command')) {
        return
    }

    $parameters = @{
        CommandName = $CommandName
        Confirm     = $false
    }

    if ($PSBoundParameters.ContainsKey('Arguments')) {
        $parameters.Arguments = $Arguments
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $parameters.Url = $Url
        $parameters.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $parameters.InstanceName = $InstanceName
    }

    Start-StarrCommand @parameters
}
