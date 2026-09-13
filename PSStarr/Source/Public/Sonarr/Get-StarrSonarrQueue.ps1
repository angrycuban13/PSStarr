function Get-StarrSonarrQueue {
    <#
    .SYNOPSIS
        Retrieves the Sonarr download queue.

    .DESCRIPTION
        This function exposes only the queue parameters supported by Sonarr and delegates the request to the shared queue implementation.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER Page
        The one-based page number.

    .PARAMETER PageSize
        The number of queue records requested per page.

    .PARAMETER SortKey
        The Sonarr queue field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER IncludeUnknownSeriesItems
        Includes queue items that Sonarr cannot associate with a series.

    .PARAMETER IncludeSeries
        Includes series resources in queue records.

    .PARAMETER IncludeEpisode
        Includes episode resources in queue records.

    .PARAMETER SeriesIdFilter
        Limits results to the supplied series identifiers.

    .PARAMETER Protocol
        Limits results by download protocol.

    .PARAMETER LanguageIdFilter
        Limits results by language identifiers.

    .PARAMETER QualityIdFilter
        Limits results by quality identifiers.

    .PARAMETER Status
        Limits results by queue status.

    .EXAMPLE
        Get-StarrSonarrQueue -InstanceName SonarrMain

    .EXAMPLE
        Get-StarrSonarrQueue -InstanceName SonarrMain -SeriesIdFilter 42,43 -IncludeEpisode $true

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the Sonarr queue response.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
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
        [System.Boolean]
        $IncludeUnknownSeriesItems,

        [Parameter()]
        [System.Boolean]
        $IncludeSeries,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisode,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $SeriesIdFilter,

        [Parameter()]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String]
        $Protocol,

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
        [ValidateSet('unknown', 'queued', 'paused', 'downloading', 'completed', 'failed', 'warning', 'delay', 'downloadClientUnavailable', 'fallback')]
        [System.String[]]
        $Status
    )

    $parameters = @{
        Application = 'Sonarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrQueue @parameters
}
