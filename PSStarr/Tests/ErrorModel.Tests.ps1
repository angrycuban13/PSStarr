BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Structured Starr error behavior' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-RestMethod { [PSCustomObject]@{ ok = $true } }
            Mock Write-PSStarrLogEntry
        }

        It 'emits but does not log a missing named instance error' {
            Mock Get-StarrConfiguration { @{ Instances = @{} } }

            $errorOutput = @(Invoke-StarrApiRequest -Name Missing -Endpoint health -ErrorAction Continue 2>&1)
            $errorRecords = @($errorOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })

            $errorRecords.Count | Should -Be 1
            $errorRecords[0].FullyQualifiedErrorId | Should -Match '^StarrInstanceNotFound'
            Should -Invoke Write-PSStarrLogEntry -Times 0
            Should -Invoke Invoke-RestMethod -Times 0
        }

        It 'emits but does not log an application mismatch error' {
            Mock Get-StarrConfiguration {
                @{
                    Instances = @{
                        Main = @{
                            Application = 'Sonarr'
                            Url         = 'http://localhost:8989'
                            ApiKey      = 'fake'
                        }
                    }
                }
            }

            $errorOutput = @(Invoke-StarrApiRequest -Name Main -Endpoint movie -ExpectedApplication Radarr -ErrorAction Continue 2>&1)
            $errorRecords = @($errorOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })

            $errorRecords.Count | Should -Be 1
            $errorRecords[0].FullyQualifiedErrorId | Should -Match '^StarrApplicationMismatch'
            Should -Invoke Write-PSStarrLogEntry -Times 0
            Should -Invoke Invoke-RestMethod -Times 0
        }

        It 'logs a configuration loading failure' {
            Mock Get-StarrConfiguration { throw 'configuration failed' }

            $null = @(Invoke-StarrApiRequest -Name Main -Endpoint health -ErrorAction Continue 2>&1)

            Should -Invoke Write-PSStarrLogEntry -Times 1
            Should -Invoke Invoke-RestMethod -Times 0
        }

        It 'does not log successful API requests' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health

            Should -Invoke Write-PSStarrLogEntry -Times 0
            Should -Invoke Invoke-RestMethod -Times 1
        }

        It 'uses parameter binding to reject conflicting history selectors' {
            Mock Invoke-StarrApiRequest

            { Get-StarrHistory -Name Main -MovieId 1 -SeriesId 2 } | Should -Throw

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}

Describe 'Configuration operation error behavior' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Write-PSStarrLogEntry
        }

        It 'sanitizes and logs instance persistence failures' {
            Mock Import-Configuration { @{ Instances = @{} } }
            Mock Export-Configuration { throw 'write failed with secret-key' }

            $errorOutput = @(Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey secret-key -ErrorAction Continue 2>&1)
            $errorRecords = @($errorOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })

            $errorRecords.Count | Should -Be 1
            $errorRecords[0].Exception.Message | Should -Not -Match 'secret-key'
            $errorRecords[0].Exception.Message | Should -Match '\[REDACTED\]'
            Should -Invoke Write-PSStarrLogEntry -Times 1 -ParameterFilter {
                $Message -notmatch 'secret-key'
            }
        }

        It 'logs instance removal persistence failures' {
            Mock Import-Configuration {
                @{
                    Instances = @{
                        Main  = @{
                            Application = 'Radarr'
                            Url         = 'http://localhost:7878'
                            ApiKey      = 'secret'
                        }
                        Other = @{
                            Application = 'Sonarr'
                            Url         = 'http://localhost:8989'
                            ApiKey      = 'secret'
                        }
                    }
                }
            }
            Mock Export-Configuration { throw 'write failed' }

            $errorOutput = @(Remove-PSStarrInstance -Name Main -Confirm:$false -ErrorAction Continue 2>&1)
            $errorRecords = @($errorOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })

            $errorRecords.Count | Should -Be 1
            $errorRecords[0].FullyQualifiedErrorId | Should -Match '^StarrConfigurationWriteFailed'
            Should -Invoke Write-PSStarrLogEntry -Times 1
        }
    }
}

Describe 'Error log formatting' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-RestMethod { throw 'unique request failure' }
            Mock Write-PSStarrLogEntry
        }

        It 'does not duplicate an exception message in the log entry' {
            try {
                Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction Stop
            }
            catch {
            }

            Should -Invoke Write-PSStarrLogEntry -Times 1 -ParameterFilter {
                ([System.Text.RegularExpressions.Regex]::Matches($Message, 'unique request failure')).Count -eq 1
            }
        }
    }
}
