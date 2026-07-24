BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Documented GET query parameters' {
    InModuleScope PSStarr {
        BeforeEach {
            $script:lastRequest = $null

            Mock Invoke-StarrApiRequest {
                $script:lastRequest = @{
                    Endpoint = $Endpoint
                    ExpectedApplication = $ExpectedApplication
                    Query = $Query
                }

                [PSCustomObject]@{ ok = $true }
            }
        }

        It '<Command> maps documented parameters' -ForEach @(
            @{ Command='Get-StarrCalendar'; Parameters=@{ Name='Main'; Start=[datetime]'2026-01-01'; IncludeSeries=$true }; Expected=@{ start=([datetime]'2026-01-01'); includeSeries=$true }; Application='Sonarr' }
            @{ Command='Get-StarrBlocklist'; Parameters=@{ Name='Main'; Page=2; MovieIds=@(12,34); Protocols=@('usenet','torrent') }; Expected=@{ page=2; movieIds=@(12,34); protocols=@('usenet','torrent') }; Application='Radarr' }
            @{ Command='Get-StarrQueue'; Parameters=@{ Name='Main'; PageSize=50; SeriesIds=@(7); IncludeEpisode=$true }; Expected=@{ pageSize=50; seriesIds=@(7); includeEpisode=$true }; Application='Sonarr' }
            @{ Command='Get-StarrQueueDetail'; Parameters=@{ Name='Main'; MovieId=12; IncludeMovie=$true }; Expected=@{ movieId=12; includeMovie=$true }; Application='Radarr' }
            @{ Command='Get-StarrHistory'; Parameters=@{ Name='Main'; SeriesId=7; SeasonNumber=2; IncludeEpisode=$true }; Expected=@{ seriesId=7; seasonNumber=2; includeEpisode=$true }; Application='Sonarr'; Endpoint='history/series' }
            @{ Command='Get-StarrRadarrCollection'; Parameters=@{ Name='Main'; TmdbId=100 }; Expected=@{ tmdbId=100 }; Application='Radarr' }
            @{ Command='Get-StarrRadarrCredit'; Parameters=@{ Name='Main'; MovieId=12; MovieMetadataId=44 }; Expected=@{ movieId=12; movieMetadataId=44 }; Application='Radarr' }
            @{ Command='Get-StarrRadarrCutoff'; Parameters=@{ Name='Main'; Page=2; Monitored=$false }; Expected=@{ page=2; monitored=$false }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMissing'; Parameters=@{ Name='Main'; SortDirection='descending' }; Expected=@{ sortDirection='descending' }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMovie'; Parameters=@{ Name='Main'; TmdbId=100; ExcludeLocalCovers=$true }; Expected=@{ tmdbId=100; excludeLocalCovers=$true }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMovieFile'; Parameters=@{ Name='Main'; MovieIds=@(12,34) }; Expected=@{ movieId=@(12,34) }; Application='Radarr' }
            @{ Command='Get-StarrSonarrCutoff'; Parameters=@{ Name='Main'; PageSize=25; IncludeEpisodeFile=$true }; Expected=@{ pageSize=25; includeEpisodeFile=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisode'; Parameters=@{ Name='Main'; SeriesId=7; SeasonNumber=0; IncludeImages=$true }; Expected=@{ seriesId=7; seasonNumber=0; includeImages=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisodeFile'; Parameters=@{ Name='Main'; SeriesId=7; EpisodeFileIds=@(8,9) }; Expected=@{ seriesId=7; episodeFileIds=@(8,9) }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrMissing'; Parameters=@{ Name='Main'; Monitored=$false; IncludeImages=$true }; Expected=@{ monitored=$false; includeImages=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrSeries'; Parameters=@{ Name='Main'; TvdbId=123; IncludeSeasonImages=$true }; Expected=@{ tvdbId=123; includeSeasonImages=$true }; Application='Sonarr' }
        ) {
            $expectedQuery = $Expected
            $expectedApplication = $Application
            $expectedEndpoint = Get-Variable -Name Endpoint -ValueOnly -ErrorAction SilentlyContinue

            & $Command @Parameters

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly

            $script:lastRequest.ExpectedApplication | Should -Be $expectedApplication

            if (-not [System.String]::IsNullOrWhiteSpace($expectedEndpoint)) {
                $script:lastRequest.Endpoint | Should -Be $expectedEndpoint
            }

            $script:lastRequest.Query.Count | Should -Be $expectedQuery.Count

            foreach ($key in $expectedQuery.Keys) {
                @($script:lastRequest.Query[$key]) -join ',' |
                    Should -Be (@($expectedQuery[$key]) -join ',')
            }
        }

        It 'does not expose raw Query parameters on GET wrappers' {
            $commandsWithRawQuery = @(
                Get-Command -Module PSStarr -Name 'Get-Starr*' |
                    Where-Object { $_.Parameters.ContainsKey('Query') }
            )

            $commandsWithRawQuery.Count | Should -Be 0
        }

        It 'validates positive resource identifiers' {
            { Get-StarrSonarrEpisode -Name Main -SeriesId 0 } | Should -Throw

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects mixed Radarr and Sonarr queue filters' {
            { Get-StarrQueue -Name Main -MovieIds 1 -SeriesIds 2 } | Should -Throw '*cannot be combined*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
