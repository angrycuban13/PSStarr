function Start-StarrSonarrSeriesRescan {
    <#
    .SYNOPSIS
        Starts rescanning a Sonarr series folder.

    .DESCRIPTION
        This function submits the typed RescanSeries command to Sonarr API v3. A successful response means Sonarr accepted the asynchronous command, not that the rescan completed.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER SeriesId
        The positive identifier of the Sonarr series to rescan.

    .EXAMPLE
        Start-StarrSonarrSeriesRescan -InstanceName SonarrMain -SeriesId 42

    .EXAMPLE
        Start-StarrSonarrSeriesRescan -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.Command]

        This function returns the accepted Sonarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Sonarr.Command')]
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
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId
    )

    $target = "Sonarr series $SeriesId"

    if (-not $PSCmdlet.ShouldProcess($target, 'Rescan series folder')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Sonarr'
        Body                = @{
            name     = 'RescanSeries'
            seriesId = $SeriesId
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
