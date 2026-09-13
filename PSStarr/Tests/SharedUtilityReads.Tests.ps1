BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> shared utility reads' -ForEach @(
        @{ Command = 'Get-StarrIndexerFlag'; Resource = 'indexerflag'; IsUnversioned = $false }
        @{ Command = 'Get-StarrPing'; Resource = 'ping'; IsUnversioned = $true }
        @{ Command = 'Get-StarrLogEntry'; Resource = 'log'; IsUnversioned = $false }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ ok = $true } }
        }

        It 'delegates the correct named GET request' {
            (& $Command -InstanceName Main).ok | Should -BeTrue

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $Resource -and $InstanceName -eq 'Main' -and
                $Method -eq 'GET' -and [bool]$Unversioned -eq $IsUnversioned
            }
        }

        It 'supports explicit credentials and inference' {
            & $Command -Url 'http://localhost:8989/base' -ApiKey fixture-key
            & $Command

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key'
            }
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
            }
        }
    }

    Describe 'Application log paging' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ page = 2; records = @(); totalRecords = 0 } }
        }

        It 'maps filters and preserves the paging envelope' {
            $result = Get-StarrLogEntry -InstanceName Main -Page 2 -PageSize 25 -SortKey time -SortDirection descending -Level error

            $result.page | Should -Be 2
            $result.records.Count | Should -Be 0
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'log' -and $Query.page -eq 2 -and $Query.pageSize -eq 25 -and
                $Query.sortKey -eq 'time' -and $Query.sortDirection -eq 'descending' -and $Query.level -eq 'error'
            }
        }

        It 'does not pass omitted filters' {
            Get-StarrLogEntry -InstanceName Main

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter { $null -eq $Query }
        }

        It 'rejects invalid paging and blank filters' {
            { Get-StarrLogEntry -InstanceName Main -Page 0 } | Should -Throw
            { Get-StarrLogEntry -InstanceName Main -PageSize -1 } | Should -Throw
            { Get-StarrLogEntry -InstanceName Main -Level ' ' } | Should -Throw
            { Get-StarrLogEntry -InstanceName Main -SortKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Transport sanitizes returned application logs' {
        BeforeEach {
            Mock Write-PSStarrLogEntry
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    page = 1
                    totalRecords = 1
                    records = @(
                        [pscustomobject]@{
                            id = 7
                            message = 'Request used fixture-key'
                            exception = 'Error fixture-key'
                            time = '2026-09-10'
                        }
                    )
                }
            }
        }

        It 'redacts the resolved named connection key while preserving the log shape' {
            Mock Get-StarrConfiguration {
                @{ Instances = @{ Main = @{ Application = 'Sonarr'; Url = 'http://localhost:8989'; ApiKey = 'fixture-key' } } }
            }

            $result = Invoke-StarrApiRequest -InstanceName Main -Endpoint log

            $result.page | Should -Be 1
            $result.records.Count | Should -Be 1
            $result.records[0].id | Should -Be 7
            $result.records[0].message | Should -Be 'Request used [REDACTED]'
            $result.records[0].exception | Should -Be 'Error [REDACTED]'
            $result.records[0].time | Should -Be '2026-09-10'
            Should -Invoke Write-PSStarrLogEntry -Times 0
        }

        It 'redacts explicit connection keys' {
            $result = Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey fixture-key -Endpoint /log/

            $result.records[0].message | Should -Not -Match 'fixture-key'
        }

        It 'preserves empty log pages' {
            Mock Invoke-RestMethod { [pscustomobject]@{ page = 1; totalRecords = 0; records = @() } }

            $result = Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey fixture-key -Endpoint log

            $result.page | Should -Be 1
            $result.totalRecords | Should -Be 0
            $result.records.Count | Should -Be 0
        }

        It 'handles null log responses without fabricating output' {
            Mock Invoke-RestMethod { $null }

            @(Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey fixture-key -Endpoint log).Count | Should -Be 0
        }

        It 'preserves responses without records' {
            Mock Invoke-RestMethod { [pscustomobject]@{ page = 1 } }

            (Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey fixture-key -Endpoint log).page | Should -Be 1
        }

        It 'handles null records within a page' {
            Mock Invoke-RestMethod { [pscustomobject]@{ records = @($null, [pscustomobject]@{ message = 'fixture-key' }) } }

            $result = Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey fixture-key -Endpoint log

            $result.records.Count | Should -Be 2
            $result.records[1].message | Should -Be '[REDACTED]'
        }

        It 'constructs the unversioned ping path under a base URL' {
            Invoke-StarrApiRequest -Url 'http://localhost:8989/base' -ApiKey fixture-key -Endpoint ping -Unversioned

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'http://localhost:8989/base/ping' -and $Method -eq 'GET'
            }
        }
    }
}
