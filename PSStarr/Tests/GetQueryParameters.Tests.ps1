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
            @{ Command='Get-StarrCalendar'; Parameters=@{ Name='Main'; Start=[datetime]'2026-01-01'; IncludeSeries=$true }; Expected=@{ start=([datetime]'2026-01-01').ToString('o'); includeSeries=$true }; Application='Sonarr' }
            @{ Command='Get-StarrBlocklist'; Parameters=@{ Name='Main'; Page=2; MovieIdFilter=@(12,34); Protocols=@('usenet','torrent') }; Expected=@{ page=2; movieIds=@(12,34); protocols=@('usenet','torrent') }; Application='Radarr' }
            @{ Command='Get-StarrBlocklist'; Parameters=@{ Name='Main'; SeriesIdFilter=@(7,8) }; Expected=@{ seriesIds=@(7,8) }; Application='Sonarr' }
            @{ Command='Get-StarrQueue'; Parameters=@{ Name='Main'; PageSize=50; SeriesIdFilter=@(7); IncludeEpisode=$true }; Expected=@{ pageSize=50; seriesIds=@(7); includeEpisode=$true }; Application='Sonarr' }
            @{ Command='Get-StarrQueue'; Parameters=@{ Name='Main'; MovieIdFilter=@(12,34); IncludeMovie=$true }; Expected=@{ movieIds=@(12,34); includeMovie=$true }; Application='Radarr' }
            @{ Command='Get-StarrQueueDetail'; Parameters=@{ Name='Main'; MovieId=12; IncludeMovie=$true }; Expected=@{ movieId=12; includeMovie=$true }; Application='Radarr' }
            @{ Command='Get-StarrQueueDetail'; Parameters=@{ Name='Main'; EpisodeIdFilter=@(8,9); IncludeEpisode=$true }; Expected=@{ episodeIds=@(8,9); includeEpisode=$true }; Application='Sonarr' }
            @{ Command='Get-StarrHistory'; Parameters=@{ Name='Main'; SeriesId=7; SeasonNumber=2; IncludeEpisode=$true }; Expected=@{ seriesId=7; seasonNumber=2; includeEpisode=$true }; Application='Sonarr'; Endpoint='history/series' }
            @{ Command='Get-StarrHistory'; Parameters=@{ Name='Main'; MovieIdFilter=@(12,34); IncludeMovie=$true }; Expected=@{ movieIds=@(12,34); includeMovie=$true }; Application='Radarr'; Endpoint='history' }
            @{ Command='Get-StarrHistory'; Parameters=@{ Name='Main'; SeriesIdFilter=@(7,8); IncludeSeries=$true }; Expected=@{ seriesIds=@(7,8); includeSeries=$true }; Application='Sonarr'; Endpoint='history' }
            @{ Command='Get-StarrRadarrCollection'; Parameters=@{ Name='Main'; TmdbId=100 }; Expected=@{ tmdbId=100 }; Application='Radarr' }
            @{ Command='Get-StarrRadarrCredit'; Parameters=@{ Name='Main'; MovieId=12; MovieMetadataId=44 }; Expected=@{ movieId=12; movieMetadataId=44 }; Application='Radarr' }
            @{ Command='Get-StarrRadarrCutoff'; Parameters=@{ Name='Main'; Page=2; Monitored=$false }; Expected=@{ page=2; monitored=$false }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMissing'; Parameters=@{ Name='Main'; SortDirection='descending' }; Expected=@{ sortDirection='descending' }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMovie'; Parameters=@{ Name='Main'; TmdbId=100; ExcludeLocalCovers=$true }; Expected=@{ tmdbId=100; excludeLocalCovers=$true }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMovieFile'; Parameters=@{ Name='Main'; MovieIdFilter=@(12,34) }; Expected=@{ movieId=@(12,34) }; Application='Radarr' }
            @{ Command='Get-StarrRadarrMovieFile'; Parameters=@{ Name='Main'; MovieFileIdFilter=@(44,45) }; Expected=@{ movieFileIds=@(44,45) }; Application='Radarr' }
            @{ Command='Get-StarrSonarrCutoff'; Parameters=@{ Name='Main'; PageSize=25; IncludeEpisodeFile=$true }; Expected=@{ pageSize=25; includeEpisodeFile=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisode'; Parameters=@{ Name='Main'; SeriesId=7; SeasonNumber=0; IncludeImages=$true }; Expected=@{ seriesId=7; seasonNumber=0; includeImages=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisode'; Parameters=@{ Name='Main'; EpisodeIdFilter=@(8,9); IncludeImages=$true }; Expected=@{ episodeIds=@(8,9); includeImages=$true }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisodeFile'; Parameters=@{ Name='Main'; SeriesId=7 }; Expected=@{ seriesId=7 }; Application='Sonarr' }
            @{ Command='Get-StarrSonarrEpisodeFile'; Parameters=@{ Name='Main'; EpisodeFileIdFilter=@(8,9) }; Expected=@{ episodeFileIds=@(8,9) }; Application='Sonarr' }
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
            { Get-StarrSonarrEpisode -InstanceName Main -SeriesId 0 } | Should -Throw

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects mixed Radarr and Sonarr queue filters' {
            { Get-StarrQueue -InstanceName Main -MovieIdFilter 1 -SeriesIdFilter 2 } | Should -Throw '*cannot be combined*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'serializes calendar date ranges as ISO 8601 values' {
            Get-StarrCalendar -InstanceName Main -Start ([datetime]'2026-01-01T01:02:03') -End ([datetime]'2026-01-02T04:05:06')

            $script:lastRequest.Query.start | Should -Be ([datetime]'2026-01-01T01:02:03').ToString('o')
            $script:lastRequest.Query.end | Should -Be ([datetime]'2026-01-02T04:05:06').ToString('o')
        }

        It 'rejects paged-only parameters on since history' {
            { Get-StarrHistory -InstanceName Main -Since ([datetime]'2026-01-01') -Page 2 } | Should -Throw '*Since history does not support: Page*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects named event types on paged history' {
            { Get-StarrHistory -InstanceName Main -EventType grabbed } | Should -Throw '*Paged history does not support: EventType*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects paged filters on movie history' {
            { Get-StarrHistory -InstanceName Main -MovieId 42 -DownloadId fixture } | Should -Throw '*Movie history does not support: DownloadId*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
