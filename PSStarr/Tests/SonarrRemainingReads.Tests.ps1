BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> remaining Sonarr GET routing' -ForEach @(
        @{ Command = 'Get-StarrSonarrCalendarEntry'; EndpointPath = 'calendar/42'; Arguments = @{ EpisodeId = 42 } }
        @{ Command = 'Get-StarrSonarrSeriesFolder'; EndpointPath = 'series/42/folder'; Arguments = @{ SeriesId = 42 } }
        @{ Command = 'Get-StarrSonarrNamingExample'; EndpointPath = 'config/naming/examples'; Arguments = @{} }
        @{ Command = 'Get-StarrSonarrParse'; EndpointPath = 'parse'; Arguments = @{ Title = 'Example.S01E01' } }
        @{ Command = 'Get-StarrSonarrRenamePreview'; EndpointPath = 'rename'; Arguments = @{ SeriesId = 42 } }
        @{ Command = 'Get-StarrSonarrRelease'; EndpointPath = 'release'; Arguments = @{ EpisodeId = 42 } }
        @{ Command = 'Get-StarrSonarrManualImport'; EndpointPath = 'manualimport'; Arguments = @{ Folder = '/downloads/example' } }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ marker = 'fixture' } }
        }

        It 'routes a named connection and returns the response' {
            (& $Command -Name Main @Arguments).marker | Should -Be 'fixture'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $EndpointPath -and $Method -eq 'GET' -and
                $ExpectedApplication -eq 'Sonarr' -and $Name -eq 'Main'
            }
        }

        It 'routes an explicit connection' {
            & $Command -Url 'http://localhost:8989/base' -ApiKey fixture-key @Arguments

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $EndpointPath -and $ExpectedApplication -eq 'Sonarr' -and
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key'
            }
        }

        It 'allows inferred connections' {
            & $Command @Arguments

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($Name) -and $ExpectedApplication -eq 'Sonarr'
            }
        }

        It 'validates credentials before transport' {
            { & $Command -Name ' ' @Arguments } | Should -Throw
            { & $Command -Url 'ftp://localhost' -ApiKey fixture-key @Arguments } | Should -Throw
            { & $Command -Url 'http://localhost:8989' -ApiKey ' ' @Arguments } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Sonarr GET query semantics' {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ id = 1 }
                [pscustomobject]@{ id = 2 }
            }
        }

        It 'preserves episode search results and selects only the episode' {
            @(Get-StarrSonarrRelease -EpisodeId 42).Count | Should -Be 2

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.episodeId -eq 42 -and $Query.Count -eq 1
            }
        }

        It 'sends a complete season search including specials' {
            Get-StarrSonarrRelease -SeriesId 42 -SeasonNumber 0

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.seriesId -eq 42 -and $Query.seasonNumber -eq 0 -and $Query.Count -eq 2
            }
        }

        It 'requests RSS without manufacturing search filters' {
            Get-StarrSonarrRelease

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'release' -and $null -eq $Query
            }
        }

        It 'passes title and path without rewriting server paths' {
            Get-StarrSonarrParse -Title 'Example.S01E01' -Path '/media/Example.S01E01.mkv'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.title -eq 'Example.S01E01' -and $Query.path -eq '/media/Example.S01E01.mkv' -and $Query.Count -eq 2
            }
        }

        It 'preserves false during folder inspection' {
            Get-StarrSonarrManualImport -Folder '/downloads/example' -DownloadId fixture-download -FilterExistingFiles $false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.folder -eq '/downloads/example' -and $Query.downloadId -eq 'fixture-download' -and
                $Query.filterExistingFiles -eq $false -and $Query.Count -eq 3
            }
        }

        It 'leaves the server default for file filtering untouched' {
            Get-StarrSonarrManualImport -Folder '/downloads/example'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.Count -eq 1 -and $Query.folder -eq '/downloads/example'
            }
        }

        It 'inspects series specials without folder-only options' {
            Get-StarrSonarrManualImport -SeriesId 42 -SeasonNumber 0

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.seriesId -eq 42 -and $Query.seasonNumber -eq 0 -and $Query.Count -eq 2
            }
        }

        It 'previews renames for all seasons when omitted' {
            Get-StarrSonarrRenamePreview -SeriesId 42

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'rename' -and $Query.seriesId -eq 42 -and $Query.Count -eq 1
            }
        }

        It 'previews special episode renames' {
            Get-StarrSonarrRenamePreview -SeriesId 42 -SeasonNumber 0

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'rename' -and $Query.seasonNumber -eq 0 -and $Query.Count -eq 2
            }
        }

        It 'does not add query data to path lookups or saved naming examples' {
            Get-StarrSonarrCalendarEntry -EpisodeId 42
            Get-StarrSonarrSeriesFolder -SeriesId 42
            Get-StarrSonarrNamingExample

            Should -Invoke Invoke-StarrApiRequest -Times 3 -Exactly -ParameterFilter { $null -eq $Query }
        }

        It 'passes custom naming options only with a positive config identifier' {
            Get-StarrSonarrNamingExample -NamingConfigId 1 -RenameEpisodes $false -MultiEpisodeStyle 0 -StandardEpisodeFormat '{Series Title}' -CustomColonReplacementFormat ''

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'config/naming/examples' -and $Query.id -eq 1 -and
                $Query.renameEpisodes -eq $false -and $Query.multiEpisodeStyle -eq 0 -and
                $Query.standardEpisodeFormat -eq '{Series Title}' -and $Query.customColonReplacementFormat -eq '' -and $Query.Count -eq 5
            }
        }

        It 'rejects invalid and conflicting selectors before transport' {
            { Get-StarrSonarrNamingExample -NamingConfigId 0 } | Should -Throw
            { Get-StarrSonarrNamingExample -NamingConfigId 1 -MultiEpisodeStyle 6 } | Should -Throw
            { Get-StarrSonarrCalendarEntry -EpisodeId 0 } | Should -Throw
            { Get-StarrSonarrSeriesFolder -SeriesId -1 } | Should -Throw
            { Get-StarrSonarrParse -Title ' ' } | Should -Throw
            { Get-StarrSonarrRenamePreview -SeriesId 42 -SeasonNumber -1 } | Should -Throw
            { Get-StarrSonarrRelease -EpisodeId 42 -SeriesId 2 -SeasonNumber 1 } | Should -Throw
            { Get-StarrSonarrManualImport -SeriesId 42 -Folder '/downloads' } | Should -Throw
            { Get-StarrSonarrManualImport -SeriesId 42 -FilterExistingFiles $false } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
