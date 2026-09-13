function Get-StarrRadarrQueue {
    <#
    .SYNOPSIS
        Retrieves the Radarr download queue.

    .DESCRIPTION
        This function exposes only the queue parameters supported by Radarr and delegates the request to the shared queue implementation.

    .PARAMETER Name
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Page
        The one-based page number.

    .PARAMETER PageSize
        The number of queue records requested per page.

    .PARAMETER SortKey
        The Radarr queue field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER IncludeUnknownMovieItems
        Includes queue items that Radarr cannot associate with a movie.

    .PARAMETER IncludeMovie
        Includes movie resources in queue records.

    .PARAMETER MovieIdFilter
        Limits results to the supplied movie identifiers.

    .PARAMETER Protocol
        Limits results by download protocol.

    .PARAMETER Languages
        Limits results by language identifiers.

    .PARAMETER Quality
        Limits results by quality identifiers.

    .PARAMETER Status
        Limits results by queue status.

    .EXAMPLE
        Get-StarrRadarrQueue -Name RadarrMain

    .EXAMPLE
        Get-StarrRadarrQueue -Name RadarrMain -MovieIdFilter 42,43 -IncludeMovie $true

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the Radarr queue response.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
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
        [ValidateSet('ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter()]
        [System.Boolean]
        $IncludeUnknownMovieItems,

        [Parameter()]
        [System.Boolean]
        $IncludeMovie,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter()]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String]
        $Protocol,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Languages,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Quality,

        [Parameter()]
        [ValidateSet('unknown', 'queued', 'paused', 'downloading', 'completed', 'failed', 'warning', 'delay', 'downloadClientUnavailable', 'fallback')]
        [System.String[]]
        $Status
    )

    $parameters = @{
        Application = 'Radarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrQueue @parameters
}
