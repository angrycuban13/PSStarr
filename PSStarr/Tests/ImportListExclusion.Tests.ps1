BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Application> exclusion GET requests' -ForEach @(
        @{ Application = 'Radarr'; Command = 'Get-StarrRadarrImportListExclusion'; Resource = 'exclusions'; SortField = 'movieTitle' }
        @{ Application = 'Sonarr'; Command = 'Get-StarrSonarrImportListExclusion'; Resource = 'importlistexclusion'; SortField = 'title' }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{
                    page = 2
                    totalRecords = 1
                    records = @([pscustomobject]@{ id = 7 })
                }
            }
        }

        It 'selects the paged route and preserves metadata' {
            $result = & $Command -InstanceName Main -Page 2 -PageSize 20 -SortKey $SortField -SortDirection descending

            $result.page | Should -Be 2
            $result.records[0].id | Should -Be 7
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Resource/paged" -and $ExpectedApplication -eq $Application -and
                $Method -eq 'GET' -and $InstanceName -eq 'Main' -and $Query.page -eq 2 -and
                $Query.pageSize -eq 20 -and $Query.sortKey -eq $SortField -and
                $Query.sortDirection -eq 'descending'
            }
        }

        It 'leaves paging defaults and instance inference to the server and transport' {
            & $Command

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Resource/paged" -and $null -eq $Query -and
                [string]::IsNullOrEmpty($InstanceName) -and $ExpectedApplication -eq $Application
            }
        }

        It 'looks up an internal exclusion ID with explicit credentials' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 7 } }

            $result = & $Command -Url 'http://localhost:8989/base' -ApiKey fixture-key -ExclusionId 7

            $result.id | Should -Be 7
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Resource/7" -and $null -eq $Query -and
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and
                $ExpectedApplication -eq $Application -and $Method -eq 'GET'
            }
        }

        It 'supports named ID lookup' {
            & $Command -InstanceName Main -ExclusionId 7

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Resource/7" -and $InstanceName -eq 'Main'
            }
        }

        It 'supports explicit page requests' {
            & $Command -Url 'http://localhost:8989' -ApiKey fixture-key -Page 1

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Resource/paged" -and $Query.page -eq 1 -and $ApiKey -eq 'fixture-key'
            }
        }

        It 'rejects mixing ID and page arguments' {
            { & $Command -InstanceName Main -ExclusionId 7 -Page 2 } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects invalid identifiers, paging, and sorting' {
            { & $Command -InstanceName Main -ExclusionId 0 } | Should -Throw
            { & $Command -InstanceName Main -Page 0 } | Should -Throw
            { & $Command -InstanceName Main -PageSize -1 } | Should -Throw
            { & $Command -InstanceName Main -SortKey notAField } | Should -Throw
            { & $Command -InstanceName Main -SortDirection sideways } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
