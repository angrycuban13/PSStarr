BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> typed command facade' -ForEach @(
        @{
            Command      = 'Start-StarrRadarrCollectionRefresh'
            Application  = 'Radarr'
            Arguments    = @{ CollectionId = @(7, 8) }
            CommandName  = 'RefreshCollections'
            ExpectedBody = @{ collectionIds = @(7, 8) }
        }
        @{
            Command      = 'Start-StarrRadarrMovieRefresh'
            Application  = 'Radarr'
            Arguments    = @{ MovieId = @(42, 43) }
            CommandName  = 'RefreshMovie'
            ExpectedBody = @{ movieIds = @(42, 43) }
        }
        @{
            Command      = 'Start-StarrRadarrMovieRescan'
            Application  = 'Radarr'
            Arguments    = @{ MovieId = 42 }
            CommandName  = 'RescanMovie'
            ExpectedBody = @{ movieId = 42 }
        }
        @{
            Command      = 'Start-StarrRadarrMovieFolderRename'
            Application  = 'Radarr'
            Arguments    = @{ MovieId = @(42, 43) }
            CommandName  = 'RenameMovieFolder'
            ExpectedBody = @{ movieIds = @(42, 43) }
        }
        @{
            Command      = 'Start-StarrSonarrEpisodeSearch'
            Application  = 'Sonarr'
            Arguments    = @{ EpisodeId = @(101, 102) }
            CommandName  = 'EpisodeSearch'
            ExpectedBody = @{ episodeIds = @(101, 102) }
        }
        @{
            Command      = 'Start-StarrSonarrSeasonSearch'
            Application  = 'Sonarr'
            Arguments    = @{ SeriesId = 42; SeasonNumber = 1 }
            CommandName  = 'SeasonSearch'
            ExpectedBody = @{ seriesId = 42; seasonNumber = 1 }
        }
        @{
            Command      = 'Start-StarrSonarrSeriesFolderRename'
            Application  = 'Sonarr'
            Arguments    = @{ SeriesId = @(42, 43) }
            CommandName  = 'RenameSeries'
            ExpectedBody = @{ seriesIds = @(42, 43) }
        }
        @{
            Command      = 'Start-StarrSonarrSeriesRescan'
            Application  = 'Sonarr'
            Arguments    = @{ SeriesId = 42 }
            CommandName  = 'RescanSeries'
            ExpectedBody = @{ seriesId = 42 }
        }
        @{
            Command      = 'Start-StarrSonarrSeriesRefresh'
            Application  = 'Sonarr'
            Arguments    = @{ SeriesId = @(42, 43) }
            CommandName  = 'RefreshSeries'
            ExpectedBody = @{ seriesIds = @(42, 43) }
        }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42; status = 'queued' } }
            Mock Get-StarrConfiguration { throw 'Unexpected configuration read.' }
        }

        It 'submits the exact typed command body' {
            $invokeArguments = @{
                InstanceName = 'Main'
                Confirm      = $false
            }

            foreach ($entry in $Arguments.GetEnumerator()) {
                $invokeArguments[$entry.Key] = $entry.Value
            }

            $result = & $Command @invokeArguments

            $result.status | Should -Be 'queued'
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                if ($Endpoint -ne 'command' -or $Method -ne 'POST' -or
                    $ExpectedApplication -ne $Application -or $Body.name -ne $CommandName -or
                    $Body.Count -ne ($ExpectedBody.Count + 1) -or $InstanceName -ne 'Main') {
                    return $false
                }

                foreach ($entry in $ExpectedBody.GetEnumerator()) {
                    if (@($Body[$entry.Key]).Count -ne @($entry.Value).Count -or
                        (@($Body[$entry.Key]) -join ',') -ne (@($entry.Value) -join ',')) {
                        return $false
                    }
                }

                return $true
            }
        }

        It 'does not invoke transport or configuration under WhatIf' {
            $invokeArguments = @{ WhatIf = $true }

            foreach ($entry in $Arguments.GetEnumerator()) {
                $invokeArguments[$entry.Key] = $entry.Value
            }

            @(& $Command @invokeArguments).Count | Should -Be 0
            Should -Invoke Invoke-StarrApiRequest -Times 0
            Should -Invoke Get-StarrConfiguration -Times 0
        }
    }

    Describe 'Start-StarrRadarrMovieFileRename typed command facade' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42; status = 'queued' } }
        }

        It 'submits movieId and files using the upstream property names' {
            Start-StarrRadarrMovieFileRename -InstanceName Main -MovieId 42 -MovieFileId 101, 102 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and $Body.name -eq 'RenameFiles' -and
                $Body.movieId -eq 42 -and ($Body.files -join ',') -eq '101,102' -and $Body.Count -eq 3
            }
        }
    }

    Describe 'Typed command facade shared connection contract' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42; status = 'queued' } }
        }

        It 'supports explicit credentials' {
            Start-StarrSonarrSeriesRescan -Url 'http://localhost:8989/base' -ApiKey fixture-key -SeriesId 42 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and
                $ExpectedApplication -eq 'Sonarr'
            }
        }
    }

    Describe 'Selected command validation' {
        BeforeEach {
            Mock Invoke-StarrApiRequest
        }

        It 'accepts season zero for specials' {
            Start-StarrSonarrSeasonSearch -InstanceName Main -SeriesId 42 -SeasonNumber 0 -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.seasonNumber -eq 0
            }
        }

        It 'rejects non-positive resource identifiers' -ForEach @(
            @{ Command = 'Start-StarrRadarrCollectionRefresh'; Arguments = @{ CollectionId = 0 } }
            @{ Command = 'Start-StarrRadarrMovieRefresh'; Arguments = @{ MovieId = 0 } }
            @{ Command = 'Start-StarrRadarrMovieFileRename'; Arguments = @{ MovieId = 42; MovieFileId = 0 } }
            @{ Command = 'Start-StarrRadarrMovieRescan'; Arguments = @{ MovieId = 0 } }
            @{ Command = 'Start-StarrRadarrMovieFolderRename'; Arguments = @{ MovieId = 0 } }
            @{ Command = 'Start-StarrSonarrEpisodeSearch'; Arguments = @{ EpisodeId = 0 } }
            @{ Command = 'Start-StarrSonarrSeasonSearch'; Arguments = @{ SeriesId = 0; SeasonNumber = 1 } }
            @{ Command = 'Start-StarrSonarrSeriesFolderRename'; Arguments = @{ SeriesId = 0 } }
            @{ Command = 'Start-StarrSonarrSeriesRescan'; Arguments = @{ SeriesId = 0 } }
            @{ Command = 'Start-StarrSonarrSeriesRefresh'; Arguments = @{ SeriesId = 0 } }
        ) {
            { & $Command @Arguments -InstanceName Main -Confirm:$false } | Should -Throw

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}

