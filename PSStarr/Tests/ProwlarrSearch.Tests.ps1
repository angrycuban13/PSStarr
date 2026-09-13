BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> Prowlarr GET connection handling' -ForEach @(
        @{ Command = 'Get-StarrProwlarrSearch'; Resource = 'search' }
        @{ Command = 'Get-StarrProwlarrIndexerStatistic'; Resource = 'indexerstats' }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ marker = 'fixture' } }
        }

        It 'uses Prowlarr API v1 and leaves omitted filters to the server' {
            (& $Command -InstanceName Main).marker | Should -Be fixture

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $Resource -and $Method -eq 'GET' -and $ApiVersion -eq 'v1' -and
                $ExpectedApplication -eq 'Prowlarr' -and $InstanceName -eq 'Main' -and $null -eq $Query
            }
        }

        It 'supports explicit and inferred connections' {
            & $Command -Url 'http://localhost:9696/base' -ApiKey fixture-key

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:9696/base' -and $ApiKey -eq 'fixture-key' -and
                $ExpectedApplication -eq 'Prowlarr' -and $ApiVersion -eq 'v1'
            }

            & $Command

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
            }
        }

        It 'rejects invalid connections before transport' {
            { & $Command -InstanceName ' ' } | Should -Throw
            { & $Command -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
            { & $Command -Url 'http://localhost:9696' -ApiKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Prowlarr search query mapping' {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ title = 'First' }
                [pscustomobject]@{ title = 'Second' }
            }
        }

        It 'keeps array filters as arrays and preserves list responses' {
            $result = @(Get-StarrProwlarrSearch -Term example -Type search -IndexerIdFilter 1,2 -CategoryIdFilter 2000,2040 -Limit 25 -Offset 0)

            $result.Count | Should -Be 2
            $result[1].title | Should -Be Second
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.query -eq 'example' -and $Query.type -eq 'search' -and
                $Query.indexerIds -is [int[]] -and ($Query.indexerIds -join ',') -eq '1,2' -and
                ($Query.categories -join ',') -eq '2000,2040' -and $Query.limit -eq 25 -and
                $Query.offset -eq 0 -and $Query.Count -eq 6
            }
        }

        It 'preserves empty results' {
            Mock Invoke-StarrApiRequest {}

            @(Get-StarrProwlarrSearch).Count | Should -Be 0
        }

        It 'rejects invalid search values' {
            { Get-StarrProwlarrSearch -Term ' ' } | Should -Throw
            { Get-StarrProwlarrSearch -IndexerIdFilter 0 } | Should -Throw
            { Get-StarrProwlarrSearch -CategoryIdFilter -1 } | Should -Throw
            { Get-StarrProwlarrSearch -Limit 0 } | Should -Throw
            { Get-StarrProwlarrSearch -Offset -1 } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Prowlarr indexer statistics filters' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ indexers = @(); hosts = @(); userAgents = @() } }
        }

        It 'sends comma-separated filters and round-trip dates' {
            $start = [datetime]'2026-01-01T00:00:00Z'
            $end = [datetime]'2026-01-02T00:00:00Z'
            $result = Get-StarrProwlarrIndexerStatistic -StartDate $start -EndDate $end -IndexerIdFilter 1,2 -Protocol Usenet,Torrent -Tag movies,3

            @($result.indexers).Count | Should -Be 0
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Query.indexers -is [string] -and $Query.indexers -eq '1,2' -and
                $Query.protocols -eq 'Usenet,Torrent' -and $Query.tags -eq 'movies,3' -and
                $Query.startDate -eq $start.ToString('o') -and $Query.endDate -eq $end.ToString('o') -and
                $Query.Count -eq 5
            }
        }

        It 'rejects invalid filters before transport' {
            { Get-StarrProwlarrIndexerStatistic -IndexerIdFilter -1 } | Should -Throw
            { Get-StarrProwlarrIndexerStatistic -Protocol invalid } | Should -Throw
            { Get-StarrProwlarrIndexerStatistic -Tag ' ' } | Should -Throw
            { Get-StarrProwlarrIndexerStatistic -Tag 'movies,shows' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
