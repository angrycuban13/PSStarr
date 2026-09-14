function Get-StarrSonarrRelease {
    <#
    .SYNOPSIS
        Retrieves Sonarr release search results.

    .DESCRIPTION
        This function retrieves RSS release results when no selector is given, or searches indexers for one episode or a complete series/season pair. This GET can contact indexers, consume quotas, take time, and populate server caches. It does not download releases.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER EpisodeId
        The episode to search. Cannot be combined with season selection. This parameter accepts an Id property from the pipeline.

    .PARAMETER SeriesId
        The series to search. SeasonNumber must also be supplied.

    .PARAMETER SeasonNumber
        The season to search, including zero for specials. SeriesId must also be supplied.

    .EXAMPLE
        Get-StarrSonarrRelease -InstanceName Main -EpisodeId 42

    .EXAMPLE
        Get-StarrSonarrRelease -Url 'http://localhost:8989' -ApiKey '<api-key>' -EpisodeId 42

    .EXAMPLE
        Get-StarrSonarrRelease -InstanceName Main

        Fetches RSS release results from the configured indexers without downloading.

    .EXAMPLE
        Get-StarrSonarrRelease -InstanceName Main -SeriesId 42 -SeasonNumber 0

        Searches indexers for the specials season of series 42.

    .EXAMPLE
        Get-StarrSonarrEpisode -EpisodeId 42 | Get-StarrSonarrRelease

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Sonarr episode.

    .OUTPUTS
        [PSStarr.Sonarr.Release]

        This function returns response objects retrieved from the Sonarr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedRss')]
    [OutputType('PSStarr.Sonarr.Release')]
    param(
        [Parameter(ParameterSetName = 'NamedRss')]
        [Parameter(ParameterSetName = 'NamedEpisode')]
        [Parameter(ParameterSetName = 'NamedSeason')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitRss')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitEpisode')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeason')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitRss')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitEpisode')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeason')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedEpisode', ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitEpisode', ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $EpisodeId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeason')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeason')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeason')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeason')]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber
    )

    process {
        $request = @{
            Endpoint            = 'release'
            Method              = 'GET'
            ExpectedApplication = 'Sonarr'
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            EpisodeId    = 'episodeId'
            SeriesId     = 'seriesId'
            SeasonNumber = 'seasonNumber'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }

        if ($PSCmdlet.ParameterSetName -like 'Explicit*') {
            $request.Url = $Url
            $request.ApiKey = $ApiKey
        }
        elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
            $request.InstanceName = $InstanceName
        }

        Invoke-StarrApiRequest @request
    }
}
