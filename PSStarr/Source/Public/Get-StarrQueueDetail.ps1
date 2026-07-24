function Get-StarrQueueDetail {
    <#
    .SYNOPSIS
        Retrieves queue details from a Starr instance.

    .DESCRIPTION
        This function retrieves queue details from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER MovieId
        The Radarr movie identifier used to filter results.

    .PARAMETER IncludeMovie
        Includes movie data when true.

    .PARAMETER SeriesId
        The Sonarr series identifier used to filter results.

    .PARAMETER EpisodeIds
        The Sonarr episode identifiers used to filter results.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisode
        Includes episode data when true.

    .EXAMPLE
        Get-StarrQueueDetail

    .EXAMPLE
        Get-StarrQueueDetail -Name 'Main'

    .EXAMPLE
        Get-StarrQueueDetail -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        $MovieId,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeMovie,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $EpisodeIds,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisode
    )

    $hasRadarrParameters = @('MovieId', 'IncludeMovie') | Where-Object { $PSBoundParameters.ContainsKey($_) }
    $hasSonarrParameters = @('SeriesId', 'EpisodeIds', 'IncludeSeries', 'IncludeEpisode') | Where-Object { $PSBoundParameters.ContainsKey($_) }

    if (@($hasRadarrParameters).Count -gt 0 -and @($hasSonarrParameters).Count -gt 0) {
        $message = 'Radarr-specific and Sonarr-specific queue parameters cannot be combined.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterConflict' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $endpoint = 'queue/details'

    $request = @{
        Endpoint = $endpoint
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        MovieId = 'movieId'
        IncludeMovie = 'includeMovie'
        SeriesId = 'seriesId'
        EpisodeIds = 'episodeIds'
        IncludeSeries = 'includeSeries'
        IncludeEpisode = 'includeEpisode'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    if ($PSBoundParameters.ContainsKey('MovieId') -or $PSBoundParameters.ContainsKey('IncludeMovie')) {
        $request.ExpectedApplication = 'Radarr'
    }

    if ($PSBoundParameters.ContainsKey('SeriesId') -or $PSBoundParameters.ContainsKey('EpisodeIds') -or $PSBoundParameters.ContainsKey('IncludeSeries') -or $PSBoundParameters.ContainsKey('IncludeEpisode')) {
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
