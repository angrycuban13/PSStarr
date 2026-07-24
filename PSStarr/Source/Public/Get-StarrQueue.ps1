function Get-StarrQueue {
    <#
    .SYNOPSIS
        Retrieves queue records from a Starr instance.

    .DESCRIPTION
        This function retrieves queue records from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The maximum number of records returned per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER IncludeUnknownMovieItems
        Includes queue items without a matched movie when true.

    .PARAMETER IncludeMovie
        Includes movie data when true.

    .PARAMETER MovieIds
        The Radarr movie identifiers used to filter results.

    .PARAMETER IncludeUnknownSeriesItems
        Includes queue items without a matched series when true.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisode
        Includes episode data when true.

    .PARAMETER SeriesIds
        The Sonarr series identifiers used to filter results.

    .PARAMETER Protocol
        The download protocol used to filter results.

    .PARAMETER Languages
        The language identifiers used to filter results.

    .PARAMETER Quality
        The quality identifiers used to filter results.

    .PARAMETER Status
        The queue statuses used to filter results.

    .EXAMPLE
        Get-StarrQueue

    .EXAMPLE
        Get-StarrQueue -Name 'Main'

    .EXAMPLE
        Get-StarrQueue -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeUnknownMovieItems,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeMovie,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIds,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeUnknownSeriesItems,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisode,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $SeriesIds,

        [Parameter(Mandatory = $false)]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Languages,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Quality,

        [Parameter(Mandatory = $false)]
        [ValidateSet('unknown', 'queued', 'paused', 'downloading', 'completed', 'failed', 'warning', 'delay', 'downloadClientUnavailable', 'fallback')]
        [System.String[]]
        $Status
    )

    $hasRadarrParameters = @('IncludeUnknownMovieItems', 'IncludeMovie', 'MovieIds') | Where-Object { $PSBoundParameters.ContainsKey($_) }
    $hasSonarrParameters = @('IncludeUnknownSeriesItems', 'IncludeSeries', 'IncludeEpisode', 'SeriesIds') | Where-Object { $PSBoundParameters.ContainsKey($_) }

    if (@($hasRadarrParameters).Count -gt 0 -and @($hasSonarrParameters).Count -gt 0) {
        $message = 'Radarr-specific and Sonarr-specific queue parameters cannot be combined.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterConflict' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $endpoint = 'queue'

    $request = @{
        Endpoint = $endpoint
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page = 'page'
        PageSize = 'pageSize'
        SortKey = 'sortKey'
        SortDirection = 'sortDirection'
        IncludeUnknownMovieItems = 'includeUnknownMovieItems'
        IncludeMovie = 'includeMovie'
        MovieIds = 'movieIds'
        IncludeUnknownSeriesItems = 'includeUnknownSeriesItems'
        IncludeSeries = 'includeSeries'
        IncludeEpisode = 'includeEpisode'
        SeriesIds = 'seriesIds'
        Protocol = 'protocol'
        Languages = 'languages'
        Quality = 'quality'
        Status = 'status'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    if ($PSBoundParameters.ContainsKey('IncludeUnknownMovieItems') -or $PSBoundParameters.ContainsKey('IncludeMovie') -or $PSBoundParameters.ContainsKey('MovieIds')) {
        $request.ExpectedApplication = 'Radarr'
    }

    if ($PSBoundParameters.ContainsKey('IncludeUnknownSeriesItems') -or $PSBoundParameters.ContainsKey('IncludeSeries') -or $PSBoundParameters.ContainsKey('IncludeEpisode') -or $PSBoundParameters.ContainsKey('SeriesIds')) {
        $request.ExpectedApplication = 'Sonarr'
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
