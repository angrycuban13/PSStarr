function Get-StarrSonarrHistory {
    <#
    .SYNOPSIS
        Retrieves Sonarr history.

    .DESCRIPTION
        This function retrieves paged Sonarr history, history since a timestamp, or history for one series without exposing Radarr-only parameters.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER Since
        Uses the history/since route beginning at this timestamp.

    .PARAMETER SeriesId
        Uses the history/series route for this series identifier.

    .PARAMETER SeasonNumber
        Limits series-scoped history to one season number.

    .PARAMETER Page
        The one-based page for paged history.

    .PARAMETER PageSize
        The number of history records requested per page.

    .PARAMETER SortKey
        The history field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER EventTypeId
        The numeric event-type identifiers used by paged history.

    .PARAMETER EventType
        The named event type used by timestamp- or series-scoped history.

    .PARAMETER DownloadId
        Limits paged history to one download identifier.

    .PARAMETER SeriesIdFilter
        Limits paged history to the supplied series identifiers.

    .PARAMETER EpisodeId
        Limits paged history to one episode identifier.

    .PARAMETER LanguageIdFilter
        Limits paged history to the supplied language identifiers.

    .PARAMETER QualityIdFilter
        Limits paged history to the supplied quality identifiers.

    .PARAMETER IncludeSeries
        Includes series resources in history records.

    .PARAMETER IncludeEpisode
        Includes episode resources in history records.

    .EXAMPLE
        Get-StarrSonarrHistory -InstanceName SonarrMain -Page 1 -PageSize 50

    .EXAMPLE
        Get-StarrSonarrHistory -InstanceName SonarrMain -SeriesId 42 -SeasonNumber 2

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.PagedResult], [PSStarr.Sonarr.History]

        This function returns Sonarr history responses.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Sonarr.PagedResult', 'PSStarr.Sonarr.History')]
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

        [Parameter()]
        [System.DateTime]
        $Since,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter()]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 0 }).Count -eq 0 })]
        [System.Int32[]]
        $EventTypeId,

        [Parameter()]
        [ValidateSet('unknown', 'grabbed', 'downloadFolderImported', 'downloadFailed', 'seriesFolderImported', 'episodeFileDeleted', 'episodeFileRenamed', 'downloadIgnored')]
        [System.String]
        $EventType,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $SeriesIdFilter,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $EpisodeId,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [Alias('Languages')]
        [System.Int32[]]
        $LanguageIdFilter,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [Alias('Quality')]
        [System.Int32[]]
        $QualityIdFilter,

        [Parameter()]
        [System.Boolean]
        $IncludeSeries,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisode
    )

    $parameters = @{
        Application = 'Sonarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrHistory @parameters
}
