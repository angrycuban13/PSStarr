BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'GET endpoint pipeline support' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{
                    ok = $true
                }
            }
        }

        It 'accepts a Sonarr series when retrieving episodes' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrSonarrEpisode -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and
                $Endpoint -eq 'episode' -and
                $Query.seriesId -eq 123
            }
        }

        It 'accepts a Sonarr series when retrieving episode files' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrSonarrEpisodeFile -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and
                $Endpoint -eq 'episodefile' -and
                $Query.seriesId -eq 123
            }
        }

        It 'accepts a Radarr movie when retrieving movie files' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrMovieFile -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'moviefile' -and
                @($Query.movieId).Count -eq 1 -and
                @($Query.movieId)[0] -eq 123
            }
        }

        It 'accepts a Radarr movie when retrieving credits' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrCredit -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'credit' -and
                $Query.movieId -eq 123
            }
        }

        It 'accepts a Radarr movie when retrieving alternative titles' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrAlternativeTitle -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'alttitle' -and
                $Query.movieId -eq 123
            }
        }

        It 'accepts a Radarr movie when retrieving extra files' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrExtraFile -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'extrafile' -and
                $Query.movieId -eq 123
            }
        }

        It 'accepts a Radarr movie when calculating its folder' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrMovieFolder -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'movie/123/folder'
            }
        }

        It 'accepts a Radarr movie when previewing renames' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrRenamePreview -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'rename' -and
                @($Query.movieId).Count -eq 1 -and
                @($Query.movieId)[0] -eq 123
            }
        }

        It 'accepts a Radarr movie when searching releases' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrRadarrRelease -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and
                $Endpoint -eq 'release' -and
                $Query.movieId -eq 123
            }
        }

        It 'accepts a Sonarr series when calculating its folder' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrSonarrSeriesFolder -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and
                $Endpoint -eq 'series/123/folder'
            }
        }

        It 'accepts a Sonarr series when previewing renames' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrSonarrRenamePreview -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and
                $Endpoint -eq 'rename' -and
                $Query.seriesId -eq 123
            }
        }

        It 'accepts a Sonarr episode when searching releases' {
            [pscustomobject]@{
                Id = 123
            } | Get-StarrSonarrRelease -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and
                $Endpoint -eq 'release' -and
                $Query.episodeId -eq 123
            }
        }

        It 'makes one request for each pipeline object' {
            @(
                [pscustomobject]@{
                    Id = 123
                }
                [pscustomobject]@{
                    Id = 456
                }
            ) | Get-StarrSonarrEpisodeFile -InstanceName 'Main'

            Should -Invoke Invoke-StarrApiRequest -Times 2 -Exactly
        }
    }
}
