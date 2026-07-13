BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'GET endpoint wrappers' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ ok = $true } }
        }

        It '<Command> delegates to <Endpoint>' -ForEach @(
            @{ Command='Get-StarrHealth'; Endpoint='health' }
            @{ Command='Get-StarrTag'; Endpoint='tag' }
            @{ Command='Get-StarrTagDetail'; Endpoint='tag/detail' }
            @{ Command='Get-StarrQualityProfile'; Endpoint='qualityprofile' }
            @{ Command='Get-StarrQualityProfileSchema'; Endpoint='qualityprofile/schema' }
            @{ Command='Get-StarrRootFolder'; Endpoint='rootfolder' }
            @{ Command='Get-StarrQueue'; Endpoint='queue' }
            @{ Command='Get-StarrQueueDetail'; Endpoint='queue/details' }
            @{ Command='Get-StarrQueueStatus'; Endpoint='queue/status' }
            @{ Command='Get-StarrCommand'; Endpoint='command' }
            @{ Command='Get-StarrAutoTagging'; Endpoint='autotagging' }
            @{ Command='Get-StarrAutoTaggingSchema'; Endpoint='autotagging/schema' }
            @{ Command='Get-StarrDiskSpace'; Endpoint='diskspace' }
            @{ Command='Get-StarrBackup'; Endpoint='system/backup' }
            @{ Command='Get-StarrTask'; Endpoint='system/task' }
            @{ Command='Get-StarrUpdate'; Endpoint='update' }
            @{ Command='Get-StarrDownloadClient'; Endpoint='downloadclient' }
            @{ Command='Get-StarrDownloadClientSchema'; Endpoint='downloadclient/schema' }
            @{ Command='Get-StarrIndexer'; Endpoint='indexer' }
            @{ Command='Get-StarrIndexerSchema'; Endpoint='indexer/schema' }
            @{ Command='Get-StarrNotification'; Endpoint='notification' }
            @{ Command='Get-StarrNotificationSchema'; Endpoint='notification/schema' }
            @{ Command='Get-StarrRemotePathMapping'; Endpoint='remotepathmapping' }
            @{ Command='Get-StarrCustomFormat'; Endpoint='customformat' }
            @{ Command='Get-StarrCustomFormatSchema'; Endpoint='customformat/schema' }
            @{ Command='Get-StarrCalendar'; Endpoint='calendar' }
            @{ Command='Get-StarrRadarrMovie'; Endpoint='movie'; App='Radarr' }
            @{ Command='Get-StarrRadarrCollection'; Endpoint='collection'; App='Radarr' }
            @{ Command='Get-StarrRadarrMovieFile'; Endpoint='moviefile'; App='Radarr' }
            @{ Command='Get-StarrRadarrCredit'; Endpoint='credit'; App='Radarr' }
            @{ Command='Get-StarrRadarrMissing'; Endpoint='wanted/missing'; App='Radarr' }
            @{ Command='Get-StarrRadarrCutoff'; Endpoint='wanted/cutoff'; App='Radarr' }
            @{ Command='Get-StarrSonarrSeries'; Endpoint='series'; App='Sonarr' }
            @{ Command='Get-StarrSonarrEpisode'; Endpoint='episode'; App='Sonarr' }
            @{ Command='Get-StarrSonarrEpisodeFile'; Endpoint='episodefile'; App='Sonarr' }
            @{ Command='Get-StarrSonarrMissing'; Endpoint='wanted/missing'; App='Sonarr' }
            @{ Command='Get-StarrSonarrCutoff'; Endpoint='wanted/cutoff'; App='Sonarr' }
        ) {
            $expectedEndpoint = $Endpoint
            $expectedApp = Get-Variable -Name App -ValueOnly -ErrorAction SilentlyContinue
            & $Command -Name Main
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Name -eq 'Main' -and $Endpoint -eq $expectedEndpoint -and
                ([string]::IsNullOrEmpty($expectedApp) -or $ExpectedApplication -eq $expectedApp)
            }
        }

        It 'uses an ID path in resource wrappers' {
            Get-StarrTag -Name Main -Id 12
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter { $Endpoint -eq 'tag/12' }
        }

        It 'uses the Radarr movie blocklist subresource' {
            Get-StarrBlocklist -Name Main -MovieId 42
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Endpoint -eq 'blocklist/movie' -and $Query.MovieId -eq 42 -and $ExpectedApplication -eq 'Radarr'
            }
        }

        It 'uses application-specific history subresources' {
            Get-StarrHistory -Name Main -SeriesId 7
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Endpoint -eq 'history/series' -and $Query.SeriesId -eq 7 -and $ExpectedApplication -eq 'Sonarr'
            }
        }

        It 'uses the unversioned API info endpoint' {
            Get-StarrApiInfo -Name Main
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter { $Endpoint -eq 'api' -and $Unversioned }
        }

        It 'selects the Radarr IMDb lookup endpoint' {
            Get-StarrRadarrMovieLookup -Name Main -ImdbId tt1234567
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Endpoint -eq 'movie/lookup/imdb' -and $Query.ImdbId -eq 'tt1234567' -and $ExpectedApplication -eq 'Radarr'
            }
        }

        It 'delegates Sonarr series lookup' {
            Get-StarrSonarrSeriesLookup -Name Main -Term 'Example'
            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Endpoint -eq 'series/lookup' -and $Query.Term -eq 'Example' -and $ExpectedApplication -eq 'Sonarr'
            }
        }
    }
}

