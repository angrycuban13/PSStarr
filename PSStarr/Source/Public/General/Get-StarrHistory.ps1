function Get-StarrHistory {
    <#
    .SYNOPSIS
        Retrieves history from a Starr instance.

    .DESCRIPTION
        This function retrieves paged history or history scoped by date, Radarr movie, or Sonarr series using documented filters.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Application
        The expected application type. Use an application-specific history command for a narrower parameter surface.

    .PARAMETER Since
        Uses the history/since endpoint beginning at this timestamp.

    .PARAMETER MovieId
        Uses the Radarr history/movie endpoint for this movie identifier.

    .PARAMETER SeriesId
        Uses the Sonarr history/series endpoint for this series identifier.

    .PARAMETER SeasonNumber
        Filters Sonarr series history by season number.

    .PARAMETER Page
        The one-based result page for paged history.

    .PARAMETER PageSize
        The maximum number of records returned per page.

    .PARAMETER SortKey
        The field used to sort paged history.

    .PARAMETER SortDirection
        The paged-history sort direction.

    .PARAMETER EventTypeId
        The numeric event type identifiers used by the paged history endpoint.

    .PARAMETER EventType
        The named event type used by movie, series, or since history endpoints.

    .PARAMETER DownloadId
        The download identifier used to filter paged history.

    .PARAMETER MovieIdFilter
        The Radarr movie identifiers used to filter paged history.

    .PARAMETER SeriesIdFilter
        The Sonarr series identifiers used to filter paged history.

    .PARAMETER EpisodeId
        The Sonarr episode identifier used to filter paged history.

    .PARAMETER Languages
        The language identifiers used to filter paged history.

    .PARAMETER Quality
        The quality identifiers used to filter paged history.

    .PARAMETER IncludeMovie
        Includes Radarr movie data when true.

    .PARAMETER IncludeSeries
        Includes Sonarr series data when true.

    .PARAMETER IncludeEpisode
        Includes Sonarr episode data when true.

    .EXAMPLE
        Get-StarrHistory

    .EXAMPLE
        Get-StarrHistory -Name 'RadarrMain' -MovieId 42 -EventType grabbed

    .EXAMPLE
        Get-StarrHistory -Name 'SonarrMain' -SeriesId 7 -SeasonNumber 2

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns history response objects retrieved from the Starr API.
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
        [ValidateSet('Radarr', 'Sonarr')]
        [System.String]
        $Application,

        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $Since,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber,

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
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 0 }).Count -eq 0 })]
        [System.Int32[]]
        $EventTypeId,

        [Parameter(Mandatory = $false)]
        [ValidateSet('unknown', 'grabbed', 'downloadFolderImported', 'downloadFailed', 'movieFileDeleted', 'movieFolderImported', 'movieFileRenamed', 'seriesFolderImported', 'episodeFileDeleted', 'episodeFileRenamed', 'downloadIgnored')]
        [System.String]
        $EventType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $SeriesIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $EpisodeId,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Languages,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $Quality,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeMovie,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisode
    )

    $selectors = @('Since', 'MovieId', 'SeriesId') | Where-Object { $PSBoundParameters.ContainsKey($_) }

    if (@($selectors).Count -gt 1) {
        $message = 'Specify only one of Since, MovieId, or SeriesId.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrHistorySelectorConflict' -TargetObject $selectors -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $hasRadarrParameters = $PSBoundParameters.ContainsKey('MovieId') -or $PSBoundParameters.ContainsKey('MovieIdFilter') -or $PSBoundParameters.ContainsKey('IncludeMovie')
    $hasSonarrParameters = @('SeriesId', 'SeriesIdFilter', 'SeasonNumber', 'EpisodeId', 'IncludeSeries', 'IncludeEpisode') | Where-Object { $PSBoundParameters.ContainsKey($_) }

    if ($hasRadarrParameters -and @($hasSonarrParameters).Count -gt 0) {
        $message = 'Radarr-specific and Sonarr-specific history parameters cannot be combined.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterConflict' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if (($Application -eq 'Radarr' -and @($hasSonarrParameters).Count -gt 0) -or ($Application -eq 'Sonarr' -and $hasRadarrParameters)) {
        $message = "$Application does not support the supplied application-specific history parameters."
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterMismatch' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $route = if ($PSBoundParameters.ContainsKey('Since')) {
        'Since'
    }
    elseif ($PSBoundParameters.ContainsKey('MovieId')) {
        'Movie'
    }
    elseif ($PSBoundParameters.ContainsKey('SeriesId')) {
        'Series'
    }
    else {
        'Paged'
    }

    $allowedParameters = @{
        Paged = @(
            'Name', 'Url', 'ApiKey', 'Application', 'Page', 'PageSize', 'SortKey',
            'SortDirection', 'EventTypeId', 'DownloadId', 'MovieIdFilter',
            'SeriesIdFilter', 'EpisodeId', 'Languages', 'Quality',
            'IncludeMovie', 'IncludeSeries', 'IncludeEpisode'
        )
        Since = @(
            'Name', 'Url', 'ApiKey', 'Application', 'Since', 'EventType', 'IncludeMovie',
            'IncludeSeries', 'IncludeEpisode'
        )
        Movie = @(
            'Name', 'Url', 'ApiKey', 'Application', 'MovieId', 'EventType', 'IncludeMovie'
        )
        Series = @(
            'Name', 'Url', 'ApiKey', 'Application', 'SeriesId', 'SeasonNumber', 'EventType',
            'IncludeSeries', 'IncludeEpisode'
        )
    }

    $commonParameters = @(
        'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction',
        'ProgressAction', 'ErrorVariable', 'WarningVariable',
        'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    )

    $unsupportedParameters = @(
        $PSBoundParameters.Keys |
            Where-Object { $_ -notin $allowedParameters[$route] -and $_ -notin $commonParameters }
    )

    if ($unsupportedParameters.Count -gt 0) {
        $message = "$route history does not support: $($unsupportedParameters -join ', ')."
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrHistoryParameterNotSupported' -TargetObject $unsupportedParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $request = @{
        Endpoint = 'history'
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page           = 'page'
        PageSize       = 'pageSize'
        SortKey        = 'sortKey'
        SortDirection  = 'sortDirection'
        EventTypeId    = 'eventType'
        DownloadId     = 'downloadId'
        MovieIdFilter  = 'movieIds'
        SeriesIdFilter = 'seriesIds'
        EpisodeId      = 'episodeId'
        Languages      = 'languages'
        Quality        = 'quality'
        IncludeMovie   = 'includeMovie'
        IncludeSeries  = 'includeSeries'
        IncludeEpisode = 'includeEpisode'
        SeasonNumber   = 'seasonNumber'
        EventType      = 'eventType'
    }

    if ($PSBoundParameters.ContainsKey('Since')) {
        $request.Endpoint = 'history/since'
        $query.date = $Since.ToString('o')
    }
    elseif ($PSBoundParameters.ContainsKey('MovieId')) {
        $request.Endpoint = 'history/movie'
        $query.movieId = $MovieId
    }
    elseif ($PSBoundParameters.ContainsKey('SeriesId')) {
        $request.Endpoint = 'history/series'
        $query.seriesId = $SeriesId
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($Application -eq 'Radarr' -or $hasRadarrParameters) {
        $request.ExpectedApplication = 'Radarr'
    }
    elseif ($Application -eq 'Sonarr' -or @($hasSonarrParameters).Count -gt 0) {
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
