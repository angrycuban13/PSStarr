BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Invoke-StarrApiRequest' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Write-PSStarrLogEntry
            Mock Invoke-RestMethod { [pscustomobject]@{ ok = $true } }
        }

        It 'uses an explicit instance and constructs normalized URL and header' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878/' -ApiKey fake -Endpoint '/system/status/'
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'http://localhost:7878/api/v3/system/status' -and
                $Headers['X-Api-Key'] -eq 'fake' -and $Method -eq 'GET'
            }
        }

        It 'resolves a named instance' {
            Mock Get-StarrConfiguration { @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878/'; ApiKey = 'fake' } } } }
            Invoke-StarrApiRequest -InstanceName Main -Endpoint system/status
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'http://localhost:7878/api/v3/system/status' }
        }

        It 'constructs an unversioned endpoint URL' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878/base/' -ApiKey fake -Endpoint api -Unversioned
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'http://localhost:7878/base/api' }
        }

        It 'rejects a named instance of the wrong application' {
            Mock Get-StarrConfiguration { @{ Instances = @{ Main = @{ Application = 'Sonarr'; Url = 'http://localhost:8989'; ApiKey = 'fake' } } } }
            { Invoke-StarrApiRequest -InstanceName Main -Endpoint movie -ExpectedApplication Radarr -ErrorAction Stop } | Should -Throw "*not 'Radarr'*"
            Should -Invoke Invoke-RestMethod -Times 0
        }

        It 'supports an API version override' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint system/status -ApiVersion v1
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'http://localhost:7878/api/v1/system/status' }
        }

        It 'serializes and escapes query values deterministically' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint queue -Query @{ page = 2; include = 'a b' }
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'http://localhost:7878/api/v3/queue?include=a%20b&page=2' }
        }

        It 'serializes object bodies for non-GET methods' {
            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint tag -Method POST -Body @{ label = 'test' }
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Method -eq 'POST' -and $Body -match '"label"' -and $ContentType -eq 'application/json' }
        }

        It 'returns the deserialized response' {
            (Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint system/status).ok | Should -BeTrue
        }

        It 'enumerates collection responses on the pipeline' {
            Mock Invoke-RestMethod {
                Write-Output -NoEnumerate @(
                    [pscustomobject]@{
                        id = 1
                    }
                    [pscustomobject]@{
                        id = 2
                    }
                )
            }

            $firstResult = Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint episodefile |
                Select-Object -First 1

            $firstResult.id | Should -Be 1
            @($firstResult).Count | Should -Be 1
        }

        It 'sanitizes API keys in terminating errors' {
            Mock Invoke-RestMethod { throw 'request failed with key secret-key' }
            $message = try { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint system/status -ErrorAction Stop } catch { $_.Exception.Message }
            $message | Should -Not -Match 'secret-key'
            $message | Should -Match '\[REDACTED\]'
            $message | Should -Not -Match "property 'Message'"
        }
    }
}

Describe 'Invoke-StarrApiRequest instance inference' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Write-PSStarrLogEntry
            Mock Invoke-RestMethod { [PSCustomObject]@{ ok = $true } }
        }

        It 'uses the only configured instance when Name is omitted' {
            Mock Get-StarrConfiguration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'fake' } } }
            }

            Invoke-StarrApiRequest -Endpoint health

            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'http://localhost:7878/api/v3/health'
            }
        }

        It 'uses the only application-compatible instance' {
            Mock Get-StarrConfiguration {
                @{
                    Instances = @{
                        RadarrMain = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'radarr-key' }
                        SonarrMain = @{ Application = 'Sonarr'; Url = 'http://localhost:8989'; ApiKey = 'sonarr-key' }
                    }
                }
            }

            Invoke-StarrApiRequest -Endpoint series -ExpectedApplication Sonarr

            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'http://localhost:8989/api/v3/series' -and
                $Headers['X-Api-Key'] -eq 'sonarr-key'
            }
        }

        It 'uses the only instance compatible with multiple supported applications' {
            Mock Get-StarrConfiguration {
                @{
                    Instances = @{
                        RadarrMain   = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'radarr-key' }
                        ProwlarrMain = @{ Application = 'Prowlarr'; Url = 'http://localhost:9696'; ApiKey = 'prowlarr-key' }
                    }
                }
            }

            Invoke-StarrApiRequest -Endpoint diskspace -ExpectedApplication Radarr, Sonarr

            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'http://localhost:7878/api/v3/diskspace' -and
                $Headers['X-Api-Key'] -eq 'radarr-key'
            }
        }

        It 'rejects ambiguous inferred instances' {
            Mock Get-StarrConfiguration {
                @{
                    Instances = @{
                        Main  = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'fake' }
                        FourK = @{ Application = 'Radarr'; Url = 'http://localhost:7879'; ApiKey = 'fake' }
                    }
                }
            }

            { Invoke-StarrApiRequest -Endpoint movie -ExpectedApplication Radarr -ErrorAction Stop } | Should -Throw '*Multiple Starr instances*Specify InstanceName*'

            Should -Invoke Invoke-RestMethod -Times 0
            Should -Invoke Write-PSStarrLogEntry -Times 0
        }

        It 'rejects inference when no compatible instance exists' {
            Mock Get-StarrConfiguration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'fake' } } }
            }

            { Invoke-StarrApiRequest -Endpoint series -ExpectedApplication Sonarr -ErrorAction Stop } | Should -Throw '*No Starr instances for Sonarr*'

            Should -Invoke Invoke-RestMethod -Times 0
            Should -Invoke Write-PSStarrLogEntry -Times 0
        }
    }
}
