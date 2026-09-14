BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Consistent filter and range parameters' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { @() }
        }

        It 'exposes ID-specific language and quality filter names on queue commands' {
            Get-StarrRadarrQueue -Name RadarrMain -LanguageIdFilter 1, 2 -QualityIdFilter 3, 4 -SortDirection default

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Radarr' -and @($Query.languages).Count -eq 2 -and
                @($Query.quality).Count -eq 2 -and $Query.sortDirection -eq 'default'
            }
        }

        It 'retains the legacy queue filter names as aliases' {
            Get-StarrSonarrQueue -Name SonarrMain -Languages 1 -Quality 3

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                @($Query.languages)[0] -eq 1 -and @($Query.quality)[0] -eq 3
            }
        }

        It 'exposes ID-specific language and quality filter names on history commands' {
            Get-StarrSonarrHistory -Name SonarrMain -LanguageIdFilter 1, 2 -QualityIdFilter 3, 4

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Sonarr' -and @($Query.languages).Count -eq 2 -and @($Query.quality).Count -eq 2
            }
        }

        It 'accepts non-date Prowlarr history sort keys allowed by the API contract' {
            Get-StarrProwlarrHistory -Name ProwlarrMain -SortKey indexerId

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr' -and $Query.sortKey -eq 'indexerId'
            }
        }

        It 'accepts the complete Prowlarr download-protocol enum' {
            Get-StarrProwlarrIndexerStatistic -Name ProwlarrMain -Protocol Unknown

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr' -and $Query.protocols -eq 'Unknown'
            }
        }

        It 'rejects reversed calendar date ranges before transport' {
            { Get-StarrCalendar -Name RadarrMain -Start ([datetime]'2026-09-14') -End ([datetime]'2026-09-13') } |
                Should -Throw -ErrorId 'StarrDateRangeInvalid,Get-StarrCalendar'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects reversed Prowlarr statistics date ranges before transport' {
            { Get-StarrProwlarrIndexerStatistic -Name ProwlarrMain -StartDate ([datetime]'2026-09-14') -EndDate ([datetime]'2026-09-13') } |
                Should -Throw -ErrorId 'StarrDateRangeInvalid,Get-StarrProwlarrIndexerStatistic'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
