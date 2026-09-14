function Start-StarrSonarrSeasonSearch {
    <#
    .SYNOPSIS
        Starts a Sonarr search for one season.

    .DESCRIPTION
        This function submits the typed SeasonSearch command to Sonarr API v3. The search contacts configured indexers and can consume provider quotas; a successful response means Sonarr accepted the asynchronous command, not that releases were found or downloaded.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER SeriesId
        The positive identifier of the Sonarr series to search.

    .PARAMETER SeasonNumber
        The non-negative season number to search. Season zero represents specials.

    .EXAMPLE
        Start-StarrSonarrSeasonSearch -InstanceName SonarrMain -SeriesId 42 -SeasonNumber 1

    .EXAMPLE
        Start-StarrSonarrSeasonSearch -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -SeasonNumber 0 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.Command]

        This function returns the accepted Sonarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'High')]
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
        $SeriesId,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber
    )

    $target = "Sonarr series $SeriesId season $SeasonNumber"

    if (-not $PSCmdlet.ShouldProcess($target, 'Search season')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Sonarr'
        Body                = @{
            name         = 'SeasonSearch'
            seriesId     = $SeriesId
            seasonNumber = $SeasonNumber
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
