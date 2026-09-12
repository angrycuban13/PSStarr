function Start-StarrSonarrSeriesSearch {
    <#
    .SYNOPSIS
        Starts a Sonarr search for selected series.

    .DESCRIPTION
        This function submits one typed SeriesSearch command to Sonarr API v3. A successful response means Sonarr accepted the asynchronous command, not that searching completed.

    .PARAMETER Name
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive identifier of the series to search.

    .EXAMPLE
        Start-StarrSonarrSeriesSearch -Name SonarrMain -SeriesId 42

    .EXAMPLE
        Start-StarrSonarrSeriesSearch -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the accepted Sonarr command resource.
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
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId
    )

    $target = "Sonarr series $SeriesId"

    if (-not $PSCmdlet.ShouldProcess($target, 'Start series search')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Sonarr'
        Body                = @{
            name     = 'SeriesSearch'
            seriesId = $SeriesId
        }
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
