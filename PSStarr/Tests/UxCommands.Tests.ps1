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
