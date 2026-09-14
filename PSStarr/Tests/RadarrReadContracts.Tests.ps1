BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> Radarr route and query contract' -ForEach @(
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
                $result = @(& $Command -InstanceName Main @Arguments)
    
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
                    $ExpectedApplication -eq 'Radarr' -and $InstanceName -eq 'Main' -and $matchesQuery
                }
            }
    
        }

    Describe 'Radarr read connection contract' {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
            }
    
            It 'supports explicit connections and inferred instances' {
                Get-StarrRadarrParse -Url 'http://localhost:7878/base' -ApiKey fixture-key -Title Fixture
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $ExpectedApplication -eq 'Radarr' -and $Url -eq 'http://localhost:7878/base' -and $ApiKey -eq 'fixture-key'
                }
    
                Get-StarrRadarrParse -Title Fixture
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
                }
            }
    
            It 'rejects invalid connection inputs before transport' {
                { Get-StarrRadarrParse -Title Fixture -InstanceName ' ' } | Should -Throw
                { Get-StarrRadarrParse -Title Fixture -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
                { Get-StarrRadarrParse -Title Fixture -Url 'http://localhost:7878' -ApiKey ' ' } | Should -Throw
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
    
            It 'preserves an empty response' {
                Mock Invoke-StarrApiRequest {}
    
                @(Get-StarrRadarrParse -InstanceName Main -Title Fixture).Count | Should -Be 0
            }
        }

    Describe 'Radarr GET defaults and validation' {
            BeforeEach {
                Mock Invoke-StarrApiRequest {}
            }
    
            It 'leaves optional filters and saved naming settings to the server' {
                Get-StarrRadarrImportListMovie -InstanceName Main
                Get-StarrRadarrManualImport -InstanceName Main
                Get-StarrRadarrRelease -InstanceName Main
                Get-StarrRadarrNamingExample -InstanceName Main
    
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
                { Get-StarrRadarrRenamePreview -MovieIdFilter 42, 0 } | Should -Throw
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

    Describe '<Command> Radarr related-resource reads' -ForEach @(
            @{ Command = 'Get-StarrRadarrAlternativeTitle'; Resource = 'alttitle' }
            @{ Command = 'Get-StarrRadarrExtraFile'; Resource = 'extrafile' }
        ) {
            BeforeEach {
                Mock Invoke-StarrApiRequest {
                    [pscustomobject]@{ id = 1 }
                    [pscustomobject]@{ id = 2 }
                }
            }
    
            It 'passes a movie filter and preserves list results' {
                $result = @(& $Command -InstanceName Main -MovieId 42)
    
                $result.Count | Should -Be 2
                $result[1].id | Should -Be 2
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq $Resource -and $Method -eq 'GET' -and
                    $ExpectedApplication -eq 'Radarr' -and $InstanceName -eq 'Main' -and
                    $Query.movieId -eq 42 -and $Query.Count -eq 1
                }
            }
    
            It 'supports explicit connections' {
                & $Command -Url 'http://localhost:7878/base' -ApiKey fixture-key -MovieId 42
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Url -eq 'http://localhost:7878/base' -and $ApiKey -eq 'fixture-key' -and
                    $ExpectedApplication -eq 'Radarr' -and $Endpoint -eq $Resource
                }
            }
    
            It 'does not invent a filter when none is supplied' {
                & $Command
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $null -eq $Query -and [string]::IsNullOrEmpty($InstanceName) -and $ExpectedApplication -eq 'Radarr'
                }
            }
    
            It 'rejects invalid input before sending requests' {
                { & $Command -InstanceName Main -MovieId 0 } | Should -Throw
                { & $Command -InstanceName ' ' } | Should -Throw
                { & $Command -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
                { & $Command -Url 'http://localhost:7878' -ApiKey ' ' } | Should -Throw
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }

    Describe 'Radarr alternative-title selectors' {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 7 } }
            }
    
            It 'retrieves an individual title without query filters' {
                (Get-StarrRadarrAlternativeTitle -InstanceName Main -AlternativeTitleId 7).id | Should -Be 7
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq 'alttitle/7' -and $null -eq $Query -and $ExpectedApplication -eq 'Radarr'
                }
            }
    
            It 'supports explicit ID lookup' {
                Get-StarrRadarrAlternativeTitle -Url 'http://localhost:7878' -ApiKey fixture-key -AlternativeTitleId 7
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq 'alttitle/7' -and $ApiKey -eq 'fixture-key'
                }
            }
    
            It 'maps the movie metadata filter' {
                Get-StarrRadarrAlternativeTitle -InstanceName Main -MovieMetadataId 12
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq 'alttitle' -and $Query.movieMetadataId -eq 12 -and $Query.Count -eq 1
                }
            }
    
            It 'rejects conflicting selectors and invalid IDs' {
                { Get-StarrRadarrAlternativeTitle -InstanceName Main -AlternativeTitleId 7 -MovieId 42 } | Should -Throw
                { Get-StarrRadarrAlternativeTitle -InstanceName Main -AlternativeTitleId 7 -MovieMetadataId 12 } | Should -Throw
                { Get-StarrRadarrAlternativeTitle -InstanceName Main -AlternativeTitleId 0 } | Should -Throw
                { Get-StarrRadarrAlternativeTitle -InstanceName Main -MovieMetadataId -1 } | Should -Throw
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }
}
