BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> Radarr supplemental reads' -ForEach @(
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
