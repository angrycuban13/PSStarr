function Get-StarrSonarrEpisode {
    <#
    .SYNOPSIS
        Retrieves Sonarr episodes from a Starr instance.

    .DESCRIPTION
        This function retrieves Sonarr episodes from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER EpisodeId
        The positive Episode resource identifier used for an individual lookup.

    .PARAMETER SeriesId
        The Sonarr series identifier used to filter results. This parameter accepts an Id property from the pipeline.

    .PARAMETER SeasonNumber
        The Sonarr season number used to filter results.

    .PARAMETER EpisodeIdFilter
        The Sonarr episode identifiers used to filter results.

    .PARAMETER EpisodeFileId
        The Sonarr episode-file identifier used to filter results.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file data when true.

    .PARAMETER IncludeImages
        Includes image data when true.

    .EXAMPLE
        Get-StarrSonarrEpisode

    .EXAMPLE
        Get-StarrSonarrEpisode -Name 'Main'

    .EXAMPLE
        Get-StarrSonarrEpisode -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .EXAMPLE
        Get-StarrSonarrSeries -SeriesId 123 | Get-StarrSonarrEpisode

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Sonarr series.

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
        $EpisodeId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $EpisodeIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $EpisodeFileId,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisodeFile,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeImages
    )

    process {
        $endpoint = 'episode'

        $request = @{
            Endpoint = $endpoint
        }

        if ($PSBoundParameters.ContainsKey('EpisodeId')) {
            $request.Endpoint = "$endpoint/$EpisodeId"
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            SeriesId = 'seriesId'
            SeasonNumber = 'seasonNumber'
            EpisodeIdFilter = 'episodeIds'
            EpisodeFileId = 'episodeFileId'
            IncludeSeries = 'includeSeries'
            IncludeEpisodeFile = 'includeEpisodeFile'
            IncludeImages = 'includeImages'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }

        $request.ExpectedApplication = 'Sonarr'

        if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
            $request.Url = $Url
            $request.ApiKey = $ApiKey
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $request.Name = $Name
        }

        Invoke-StarrApiRequest @request
    }
}
