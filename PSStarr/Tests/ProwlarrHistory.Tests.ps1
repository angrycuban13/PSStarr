BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe 'Prowlarr history GET routing' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ records = @([pscustomobject]@{ id = 42 }); totalRecords = 1 } }
        }

        It 'preserves the paging envelope without fetching additional pages' {
            $result = Get-StarrProwlarrHistory -Name Main -Page 2 -PageSize 50 -SortKey date -SortDirection descending -EventTypeId 0,2 -Successful $false -DownloadId fixture-download -IndexerIdFilter 3,4

            $result.totalRecords | Should -Be 1
            $result.records[0].id | Should -Be 42
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'history' -and $Method -eq 'GET' -and $ExpectedApplication -eq 'Prowlarr' -and
                $ApiVersion -eq 'v1' -and $Name -eq 'Main' -and $Query.page -eq 2 -and $Query.pageSize -eq 50 -and
                $Query.sortKey -eq 'date' -and $Query.sortDirection -eq 'descending' -and
                ($Query.eventType -join ',') -eq '0,2' -and $Query.successful -eq $false -and
                $Query.downloadId -eq 'fixture-download' -and ($Query.indexerIds -join ',') -eq '3,4' -and $Query.Count -eq 8
            }
        }

        It 'leaves server defaults untouched for inferred connections' {
            Get-StarrProwlarrHistory

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'history' -and $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr' -and
                $null -eq $Query -and [string]::IsNullOrEmpty($Name)
            }
        }

        It 'serializes since timestamps and named event types' {
            $timestamp = [datetime]'2026-01-01T00:00:00Z'
            Get-StarrProwlarrHistory -Name Main -Since $timestamp -EventType indexerQuery

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'history/since' -and $Query.date -eq $timestamp.ToString('o') -and
                $Query.eventType -eq 'indexerQuery' -and $Query.Count -eq 2 -and $ApiVersion -eq 'v1'
            }
        }

        It 'passes indexer history limits and preserves lists' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 }; [pscustomobject]@{ id = 2 } }
            @(Get-StarrProwlarrHistory -Url 'http://localhost:9696/base' -ApiKey fixture-key -IndexerId 7 -EventType releaseGrabbed -Limit 20).Count | Should -Be 2

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'history/indexer' -and $Query.indexerId -eq 7 -and $Query.limit -eq 20 -and
                $Query.eventType -eq 'releaseGrabbed' -and $Query.Count -eq 3 -and
                $Url -eq 'http://localhost:9696/base' -and $ApiKey -eq 'fixture-key' -and $ApiVersion -eq 'v1'
            }
        }

        It 'rejects invalid and incompatible filters before transport' {
            { Get-StarrProwlarrHistory -Page 0 } | Should -Throw
            { Get-StarrProwlarrHistory -IndexerId 0 } | Should -Throw
            { Get-StarrProwlarrHistory -IndexerId 1 -Limit 0 } | Should -Throw
            { Get-StarrProwlarrHistory -EventTypeId -1 } | Should -Throw
            { Get-StarrProwlarrHistory -EventTypeId @() } | Should -Throw
            { Get-StarrProwlarrHistory -IndexerIdFilter 1,0 } | Should -Throw
            { Get-StarrProwlarrHistory -SortKey title } | Should -Throw
            { Get-StarrProwlarrHistory -Since ([datetime]::UtcNow) -Page 1 } | Should -Throw
            { Get-StarrProwlarrHistory -Since ([datetime]::UtcNow) -IndexerId 1 } | Should -Throw
            { Get-StarrProwlarrHistory -IndexerId 1 -Successful $false } | Should -Throw
            { Get-StarrProwlarrHistory -IndexerId 1 -EventType grabbed } | Should -Throw
            { Get-StarrProwlarrHistory -Name ' ' } | Should -Throw
            { Get-StarrProwlarrHistory -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
            { Get-StarrProwlarrHistory -Url 'http://localhost:9696' -ApiKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Prowlarr development configuration GET routing' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
        }

        It 'reads current settings without a query' {
            (Get-StarrProwlarrDevelopmentConfiguration -Name Main).id | Should -Be 1

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'config/development' -and $Method -eq 'GET' -and
                $ExpectedApplication -eq 'Prowlarr' -and $ApiVersion -eq 'v1' -and $Name -eq 'Main' -and $null -eq $Query
            }
        }

        It 'reads settings by identifier using explicit credentials' {
            Get-StarrProwlarrDevelopmentConfiguration -Url 'http://localhost:9696' -ApiKey fixture-key -ConfigurationId 1

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'config/development/1' -and $ApiVersion -eq 'v1' -and
                $Url -eq 'http://localhost:9696' -and $ApiKey -eq 'fixture-key' -and $null -eq $Query
            }
        }

        It 'allows inference and rejects invalid settings identifiers' {
            Get-StarrProwlarrDevelopmentConfiguration
            { Get-StarrProwlarrDevelopmentConfiguration -ConfigurationId 0 } | Should -Throw
            { Get-StarrProwlarrDevelopmentConfiguration -Name ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter { [string]::IsNullOrEmpty($Name) }
        }
    }
}
