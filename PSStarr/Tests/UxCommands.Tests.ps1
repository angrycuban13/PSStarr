BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Shared Prowlarr-compatible command routing' {
    BeforeAll {
        $sharedProwlarrCommands = @(
            'Get-StarrBackup'
            'Get-StarrCommand'
            'Get-StarrCustomFilter'
            'Get-StarrDownloadClient'
            'Get-StarrDownloadClientSchema'
            'Get-StarrHealth'
            'Get-StarrIndexer'
            'Get-StarrIndexerSchema'
            'Get-StarrLogEntry'
            'Get-StarrNotification'
            'Get-StarrNotificationSchema'
            'Get-StarrSystemStatus'
            'Get-StarrTag'
            'Get-StarrTagDetail'
            'Get-StarrTagUsage'
            'Get-StarrTask'
            'Get-StarrUpdate'
        )
    }

    It 'passes an explicit Prowlarr application discriminator to the transport' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedProwlarrCommands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                & $command -Url 'http://localhost:9696' -ApiKey 'test-key' -Application Prowlarr
            }

            Should -Invoke Invoke-StarrApiRequest -Times $Commands.Count -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr'
            }
        }
    }

    It 'keeps the application discriminator optional for existing explicit calls' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedProwlarrCommands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                { & $command -Url 'http://localhost:7878' -ApiKey 'test-key' } | Should -Not -Throw
            }
        }
    }
}

Describe 'Discoverable Prowlarr and tag reads' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ ok = $true } }
        }

        It 'retrieves all configured Prowlarr indexers through API v1' {
            Get-StarrProwlarrIndexer -Name ProwlarrMain

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'ProwlarrMain' -and $Endpoint -eq 'indexer' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'retrieves one configured Prowlarr indexer explicitly' {
            Get-StarrProwlarrIndexer -Url 'http://localhost:9696' -ApiKey fixture -IndexerId 4

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:9696' -and $Endpoint -eq 'indexer/4' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'retrieves tag usage with the descriptive command name' {
            Get-StarrTagUsage -Name Main -TagId 3

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Main' -and $Endpoint -eq 'tag/detail/3'
            }
        }
    }
}

Describe 'Typed consumer commands' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 9 } }
        }

        It 'starts a Radarr movie search with a typed body' {
            Start-StarrRadarrMovieSearch -Name RadarrMain -MovieId 42,43 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'RadarrMain' -and $Endpoint -eq 'command' -and
                $Method -eq 'POST' -and $ExpectedApplication -eq 'Radarr' -and
                $Body.name -eq 'MoviesSearch' -and @($Body.movieIds).Count -eq 2
            }
        }

        It 'starts a Sonarr series search with a typed body' {
            Start-StarrSonarrSeriesSearch -Name SonarrMain -SeriesId 42 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'SonarrMain' -and $ExpectedApplication -eq 'Sonarr' -and
                $Body.name -eq 'SeriesSearch' -and $Body.seriesId -eq 42
            }
        }

        It 'starts a Radarr movie rename with a typed body' {
            Start-StarrRadarrMovieRename -Name RadarrMain -MovieId 42 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and $Body.name -eq 'RenameMovie' -and
                @($Body.movieIds).Count -eq 1 -and $Body.movieIds[0] -eq 42
            }
        }

        It 'starts a Sonarr episode-file rename with a typed body' {
            Start-StarrSonarrEpisodeFileRename -Name SonarrMain -SeriesId 42 -EpisodeFileId 100,101 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and $Body.name -eq 'RenameFiles' -and
                $Body.seriesId -eq 42 -and @($Body.files).Count -eq 2
            }
        }

        It '<Command> does not contact an application under WhatIf' -ForEach @(
            @{ Command = 'Start-StarrRadarrMovieSearch'; Parameters = @{ Name = 'RadarrMain'; MovieId = @(42) } }
            @{ Command = 'Start-StarrRadarrMovieRename'; Parameters = @{ Name = 'RadarrMain'; MovieId = @(42) } }
            @{ Command = 'Start-StarrSonarrSeriesSearch'; Parameters = @{ Name = 'SonarrMain'; SeriesId = 42 } }
            @{ Command = 'Start-StarrSonarrEpisodeFileRename'; Parameters = @{ Name = 'SonarrMain'; SeriesId = 42; EpisodeFileId = @(100) } }
        ) {
            & $Command @Parameters -WhatIf

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}

Describe 'Application-specific queue commands' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Get-StarrQueue { [pscustomobject]@{ ok = $true } }
        }

        It 'forwards only Radarr queue parameters with a Radarr discriminator' {
            Get-StarrRadarrQueue -Name RadarrMain -MovieIdFilter 42,43 -IncludeMovie $true

            Should -Invoke Get-StarrQueue -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'RadarrMain' -and $Application -eq 'Radarr' -and
                @($MovieIdFilter).Count -eq 2 -and $IncludeMovie
            }
        }

        It 'forwards only Sonarr queue parameters with a Sonarr discriminator' {
            Get-StarrSonarrQueue -Name SonarrMain -SeriesIdFilter 42,43 -IncludeEpisode $true

            Should -Invoke Get-StarrQueue -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'SonarrMain' -and $Application -eq 'Sonarr' -and
                @($SeriesIdFilter).Count -eq 2 -and $IncludeEpisode
            }
        }

        It 'does not expose Sonarr-only parameters on the Radarr command' {
            (Get-Command Get-StarrRadarrQueue).Parameters.Keys | Should -Not -Contain 'SeriesIdFilter'
            (Get-Command Get-StarrRadarrQueue).Parameters.Keys | Should -Not -Contain 'IncludeEpisode'
        }

        It 'does not expose Radarr-only parameters on the Sonarr command' {
            (Get-Command Get-StarrSonarrQueue).Parameters.Keys | Should -Not -Contain 'MovieIdFilter'
            (Get-Command Get-StarrSonarrQueue).Parameters.Keys | Should -Not -Contain 'IncludeMovie'
        }
    }
}

Describe 'Application-specific calendar commands' {
    InModuleScope PSStarr {
        It 'serializes typed tag IDs for the shared calendar route' {
            Mock Invoke-StarrApiRequest { @() }

            Get-StarrCalendar -Name RadarrMain -Application Radarr -TagIdFilter 2,5

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and $Query.tags -eq '2,5'
            }
        }

        It 'rejects both calendar tag-filter forms together' {
            Mock Invoke-StarrApiRequest { @() }

            { Get-StarrCalendar -Name RadarrMain -Tags '2,5' -TagIdFilter 2,5 } |
                Should -Throw -ErrorId 'StarrCalendarTagFilterConflict,Get-StarrCalendar'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'forwards the Radarr calendar surface with a Radarr discriminator' {
            Mock Get-StarrCalendar { @() }

            Get-StarrRadarrCalendar -Name RadarrMain -TagIdFilter 2,5

            Should -Invoke Get-StarrCalendar -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Radarr' -and @($TagIdFilter).Count -eq 2
            }
        }

        It 'forwards the Sonarr calendar surface with a Sonarr discriminator' {
            Mock Get-StarrCalendar { @() }

            Get-StarrSonarrCalendar -Name SonarrMain -IncludeSeries $true

            Should -Invoke Get-StarrCalendar -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Sonarr' -and $IncludeSeries
            }
        }

        It 'does not expose Sonarr-only calendar parameters on the Radarr command' {
            (Get-Command Get-StarrRadarrCalendar).Parameters.Keys | Should -Not -Contain 'IncludeSeries'
            (Get-Command Get-StarrRadarrCalendar).Parameters.Keys | Should -Not -Contain 'IncludeEpisodeFile'
        }
    }
}

Describe 'Application-specific queue-detail and blocklist commands' {
    InModuleScope PSStarr {
        It 'forwards Radarr queue-detail parameters without Sonarr fields' {
            Mock Get-StarrQueueDetail { @() }

            Get-StarrRadarrQueueDetail -Name RadarrMain -MovieId 42

            Should -Invoke Get-StarrQueueDetail -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Radarr' -and $MovieId -eq 42
            }
            (Get-Command Get-StarrRadarrQueueDetail).Parameters.Keys | Should -Not -Contain 'SeriesId'
        }

        It 'forwards Sonarr queue-detail parameters without Radarr fields' {
            Mock Get-StarrQueueDetail { @() }

            Get-StarrSonarrQueueDetail -Name SonarrMain -SeriesId 42 -EpisodeIdFilter 10,11

            Should -Invoke Get-StarrQueueDetail -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Sonarr' -and $SeriesId -eq 42 -and @($EpisodeIdFilter).Count -eq 2
            }
            (Get-Command Get-StarrSonarrQueueDetail).Parameters.Keys | Should -Not -Contain 'MovieId'
        }

        It 'forwards Radarr blocklist parameters without Sonarr fields' {
            Mock Get-StarrBlocklist { @() }

            Get-StarrRadarrBlocklist -Name RadarrMain -MovieIdFilter 42,43

            Should -Invoke Get-StarrBlocklist -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Radarr' -and @($MovieIdFilter).Count -eq 2
            }
            (Get-Command Get-StarrRadarrBlocklist).Parameters.Keys | Should -Not -Contain 'SeriesIdFilter'
        }

        It 'forwards Sonarr blocklist parameters without Radarr fields' {
            Mock Get-StarrBlocklist { @() }

            Get-StarrSonarrBlocklist -Name SonarrMain -SeriesIdFilter 42,43

            Should -Invoke Get-StarrBlocklist -Times 1 -Exactly -ParameterFilter {
                $Application -eq 'Sonarr' -and @($SeriesIdFilter).Count -eq 2
            }
            (Get-Command Get-StarrSonarrBlocklist).Parameters.Keys | Should -Not -Contain 'MovieIdFilter'
        }

        It 'rejects an explicit application that contradicts queue-detail parameters' {
            Mock Invoke-StarrApiRequest { @() }

            { Get-StarrQueueDetail -Name Main -Application Radarr -SeriesId 42 } |
                Should -Throw -ErrorId 'StarrApplicationParameterMismatch,Get-StarrQueueDetail'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects an explicit application that contradicts blocklist parameters' {
            Mock Invoke-StarrApiRequest { @() }

            { Get-StarrBlocklist -Name Main -Application Sonarr -MovieIdFilter 42 } |
                Should -Throw -ErrorId 'StarrApplicationParameterMismatch,Get-StarrBlocklist'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'routes shared history by an explicit application discriminator' {
            Mock Invoke-StarrApiRequest { @() }

            Get-StarrHistory -Name Main -Application Sonarr -Page 1

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and $Endpoint -eq 'history'
            }
        }

        It 'rejects an explicit application that contradicts history parameters' {
            Mock Invoke-StarrApiRequest { @() }

            { Get-StarrHistory -Name Main -Application Radarr -SeriesIdFilter 42 } |
                Should -Throw -ErrorId 'StarrApplicationParameterMismatch,Get-StarrHistory'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
