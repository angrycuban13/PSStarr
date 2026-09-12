BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> remaining Radarr GET routes' -ForEach @(
        @{ Command = 'Get-StarrRadarrImportListMovie'; Resource = 'importlist/movie'; Arguments = @{ IncludeRecommendations = $true; IncludeTrending = $false; IncludePopular = $true }; ExpectedQuery = @{ includeRecommendations = $true; includeTrending = $false; includePopular = $true } }
        @{ Command = 'Get-StarrRadarrManualImport'; Resource = 'manualimport'; Arguments = @{ Folder = '/downloads/movies'; DownloadId = 'fixture-download'; MovieId = 42; FilterExistingFiles = $false }; ExpectedQuery = @{ folder = '/downloads/movies'; downloadId = 'fixture-download'; movieId = 42; filterExistingFiles = $false } }
        @{ Command = 'Get-StarrRadarrMovieFolder'; Resource = 'movie/42/folder'; Arguments = @{ MovieId = 42 }; ExpectedQuery = @{} }
        @{ Command = 'Get-StarrRadarrParse'; Resource = 'parse'; Arguments = @{ Title = 'Example.Movie.2024' }; ExpectedQuery = @{ title = 'Example.Movie.2024' } }
        @{ Command = 'Get-StarrRadarrRelease'; Resource = 'release'; Arguments = @{ MovieId = 42 }; ExpectedQuery = @{ movieId = 42 } }
        @{ Command = 'Get-StarrRadarrRenamePreview'; Resource = 'rename'; Arguments = @{ MovieIdFilter = @(42, 43) }; ExpectedQuery = @{ movieId = @(42, 43) } }
        @{ Command = 'Get-StarrRadarrNamingExample'; Resource = 'config/naming/examples'; Arguments = @{ NamingConfigId = 1; RenameMovies = $false; ReplaceIllegalCharacters = $true; ColonReplacementFormat = 'smart'; StandardMovieFormat = '{Movie Title}'; MovieFolderFormat = '{Movie Title}'; ResourceName = 'fixture' }; ExpectedQuery = @{ id = 1; renameMovies = $false; replaceIllegalCharacters = $true; colonReplacementFormat = 'smart'; standardMovieFormat = '{Movie Title}'; movieFolderFormat = '{Movie Title}'; resourceName = 'fixture' } }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ id = 1 }
                [pscustomobject]@{ id = 2 }
            }
        }

        It 'maps the route and every supplied query parameter without altering results' {
            $result = @(& $Command -Name Main @Arguments)

            $result.Count | Should -Be 2
            $result[1].id | Should -Be 2
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $matchesQuery = $true

                if ($ExpectedQuery.Count -eq 0) {
                    $matchesQuery = $null -eq $Query
                }
                else {
                    $matchesQuery = $null -ne $Query -and $Query.Count -eq $ExpectedQuery.Count

                    foreach ($key in $ExpectedQuery.Keys) {
                        if (($Query[$key] -join ',') -cne ($ExpectedQuery[$key] -join ',')) {
                            $matchesQuery = $false
                        }
                    }
                }

                $Endpoint -eq $Resource -and $Method -eq 'GET' -and
                $ExpectedApplication -eq 'Radarr' -and $Name -eq 'Main' -and $matchesQuery
            }
        }

        It 'supports explicit connections and inferred instances' {
            & $Command -Url 'http://localhost:7878/base' -ApiKey fixture-key @Arguments

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $Resource -and $Method -eq 'GET' -and $ExpectedApplication -eq 'Radarr' -and
                $Url -eq 'http://localhost:7878/base' -and $ApiKey -eq 'fixture-key'
            }

            & $Command @Arguments

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($Name) -and [string]::IsNullOrEmpty($Url) -and $ExpectedApplication -eq 'Radarr'
            }
        }

        It 'rejects invalid connection inputs before transport' {
            { & $Command -Name ' ' @Arguments } | Should -Throw
            { & $Command -Url 'ftp://localhost' -ApiKey fixture-key @Arguments } | Should -Throw
            { & $Command -Url 'http://localhost:7878' -ApiKey ' ' @Arguments } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'preserves empty responses' {
            Mock Invoke-StarrApiRequest {}

            @(& $Command -Name Main @Arguments).Count | Should -Be 0
        }
    }

    Describe 'Radarr GET defaults and validation' {
        BeforeEach {
            Mock Invoke-StarrApiRequest {}
        }

        It 'leaves optional filters and saved naming settings to the server' {
            Get-StarrRadarrImportListMovie -Name Main
            Get-StarrRadarrManualImport -Name Main
            Get-StarrRadarrRelease -Name Main
            Get-StarrRadarrNamingExample -Name Main

            Should -Invoke Invoke-StarrApiRequest -Times 4 -Exactly -ParameterFilter {
                $null -eq $Query -and $Method -eq 'GET'
            }
        }

        It 'rejects invalid identifiers, formats and titles' {
            { Get-StarrRadarrMovieFolder -MovieId 0 } | Should -Throw
            { Get-StarrRadarrRelease -MovieId -1 } | Should -Throw
            { Get-StarrRadarrManualImport -MovieId 0 } | Should -Throw
            { Get-StarrRadarrManualImport -Folder ' ' } | Should -Throw
            { Get-StarrRadarrParse -Title ' ' } | Should -Throw
            { Get-StarrRadarrRenamePreview -MovieIdFilter 42,0 } | Should -Throw
            { Get-StarrRadarrNamingExample -NamingConfigId 0 } | Should -Throw
            { Get-StarrRadarrNamingExample -NamingConfigId 1 -ColonReplacementFormat unknown } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'requires the configuration identifier for custom naming parameter sets' {
            $sets = (Get-Command Get-StarrRadarrNamingExample).ParameterSets | Where-Object Name -Like '*Custom'

            @($sets).Count | Should -Be 2

            foreach ($set in $sets) {
                ($set.Parameters | Where-Object Name -EQ 'NamingConfigId').IsMandatory | Should -BeTrue
            }
        }
    }
}
