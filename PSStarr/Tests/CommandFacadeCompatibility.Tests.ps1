BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Command facade compatibility' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 9 } }
        }

        It 'starts a Radarr movie search with a typed body' {
            Start-StarrRadarrMovieSearch -Name RadarrMain -MovieId 42, 43 -Confirm:$false

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
            Start-StarrSonarrEpisodeFileRename -Name SonarrMain -SeriesId 42 -EpisodeFileId 100, 101 -Confirm:$false

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
